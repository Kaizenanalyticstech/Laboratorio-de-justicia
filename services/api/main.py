import os
import io
import math
import json
import time
import uuid
import base64
import typing as t

import numpy as np
import requests
from fastapi import FastAPI, UploadFile, File, Form
from fastapi import Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import psycopg2
import psycopg2.extras
from pypdf import PdfReader

DATABASE_URL = os.environ.get("DATABASE_URL", "postgresql://postgres:postgres@postgres:5432/odr_chatbot")
FILES_DIR = os.environ.get("FILES_DIR", "/app/data/uploads")
CORS_ORIGINS = os.environ.get("CORS_ORIGINS", "*")

os.makedirs(FILES_DIR, exist_ok=True)

app = FastAPI(title="ODR Chatbot API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[CORS_ORIGINS] if CORS_ORIGINS != "*" else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db():
    try:
        conn = psycopg2.connect(DATABASE_URL)
        return conn
    except Exception as e:
        print(f"Error conectando a la base de datos: {e}")
        return None

def init_db():
    """Inicializar la base de datos con las tablas necesarias"""
    conn = get_db()
    if not conn:
        return False
    
    try:
        cur = conn.cursor()
        
        # Crear tabla de documentos
        cur.execute("""
            CREATE TABLE IF NOT EXISTS documents (
                id SERIAL PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)
        
        # Crear tabla de chunks
        cur.execute("""
            CREATE TABLE IF NOT EXISTS chunks (
                id SERIAL PRIMARY KEY,
                document_id INTEGER REFERENCES documents(id),
                page INTEGER,
                content TEXT,
                embedding REAL[],
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)
        
        # Crear extensión pgvector si no existe
        cur.execute("CREATE EXTENSION IF NOT EXISTS vector;")
        
        conn.commit()
        conn.close()
        return True
    except Exception as e:
        print(f"Error inicializando base de datos: {e}")
        return False

def chunk_text(text: str, chunk_size: int = 1200, overlap: int = 150) -> t.List[str]:
    """Simple token-agnostic chunking by characters."""
    chunks = []
    start = 0
    n = len(text)
    while start < n:
        end = min(n, start + chunk_size)
        chunk = text[start:end]
        chunks.append(chunk)
        start = end - overlap if end - overlap > start else end
    return chunks

def extract_text_from_file(file_path: str, file_type: str) -> list:
    """Extraer texto de diferentes tipos de archivos"""
    all_pages_text = []
    
    try:
        if file_type == "application/pdf":
            # Procesar PDF
            reader = PdfReader(file_path)
            for i, page in enumerate(reader.pages):
                try:
                    txt = page.extract_text() or ""
                except Exception:
                    txt = ""
                all_pages_text.append((i + 1, txt))
        else:
            # Procesar archivo de texto
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                all_pages_text.append((1, content))
    except Exception as e:
        print(f"Error extrayendo texto del archivo: {e}")
        # Si falla, crear un chunk con el nombre del archivo
        all_pages_text.append((1, f"Archivo: {os.path.basename(file_path)}"))
    
    return all_pages_text

class ChatRequest(BaseModel):
    query: str
    top_k: int = 4
    temperature: float = 0.2
    max_tokens: int = 512

@app.get("/health")
def health():
    return {"ok": True}

@app.post("/ingest")
def ingest(file: UploadFile = File(...), name: str = Form(None)):
    try:
        # Inicializar base de datos
        if not init_db():
            return JSONResponse({"error": "Error de base de datos"}, status_code=500)
        
        # Save file
        fname = name or file.filename
        path = os.path.join(FILES_DIR, fname)
        
        # Leer el contenido del archivo
        content = file.file.read()
        
        # Guardar el archivo
        with open(path, "wb") as f:
            f.write(content)

        # Extraer texto basado en el tipo de archivo
        file_type = file.content_type or "text/plain"
        all_pages_text = extract_text_from_file(path, file_type)

        # Create document in DB
        conn = get_db()
        cur = conn.cursor()
        cur.execute("INSERT INTO documents (name) VALUES (%s) RETURNING id;", (fname,))
        doc_id = cur.fetchone()[0]

        # Chunk text
        rows = []
        for page_no, page_text in all_pages_text:
            page_text = (page_text or "").strip()
            if not page_text:
                continue
            pieces = chunk_text(page_text)
            rows.extend([(page_no, p) for p in pieces if p.strip()])

        if not rows:
            conn.commit()
            conn.close()
            return {"document_id": doc_id, "chunks": 0, "message": "Archivo sin texto extraíble o vacío."}

        # Insert chunks (sin embeddings por ahora)
        insert_sql = "INSERT INTO chunks (document_id, page, content) VALUES (%s, %s, %s)"
        for page_no, content in rows:
            cur.execute(insert_sql, (doc_id, page_no, content))
        
        conn.commit()
        conn.close()
        
        return {"document_id": doc_id, "chunks": len(rows), "pages": len(all_pages_text)}
        
    except Exception as e:
        print(f"Error en ingest: {e}")
        return JSONResponse({"error": str(e)}, status_code=500)

@app.post("/chat")
def chat(req: ChatRequest):
    try:
        q = req.query.strip()
        if not q:
            return JSONResponse({"error": "Pregunta vacía"}, status_code=400)

        # Inicializar base de datos
        if not init_db():
            return JSONResponse({"error": "Error de base de datos"}, status_code=500)

        # Buscar chunks relevantes (sin embeddings por ahora)
        conn = get_db()
        cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        
        # Búsqueda simple por texto
        cur.execute(
            """
            SELECT c.id, c.content, c.page, d.name as document_name
            FROM chunks c
            JOIN documents d ON d.id = c.document_id
            WHERE c.content ILIKE %s
            ORDER BY c.page
            LIMIT %s;
            """,
            (f"%{q}%", req.top_k)
        )
        rows = cur.fetchall()
        conn.close()

        if not rows:
            # Respuesta cuando no hay información
            return {
                "answer": "No encontré información específica sobre tu pregunta en los documentos cargados. Por favor, asegúrate de haber subido un documento PDF relevante.",
                "sources": []
            }

        # Construir contexto
        context_parts = []
        sources = []
        for r in rows:
            context_parts.append(f"[{r['document_name']} p.{r['page']}]\n{r['content']}")
            sources.append({"document": r["document_name"], "page": r["page"], "score": 1.0})

        # Respuesta simulada
        answer = f"Basándome en la información encontrada en los documentos:\n\n"
        answer += "\n\n".join(context_parts[:3])  # Mostrar solo los primeros 3 chunks
        
        if len(context_parts) > 3:
            answer += f"\n\n... y {len(context_parts) - 3} fragmentos adicionales."
        
        answer += "\n\nEsta es la información relevante que encontré sobre tu pregunta."

        return {"answer": answer, "sources": sources}
        
    except Exception as e:
        print(f"Error en chat: {e}")
        return JSONResponse({"error": str(e)}, status_code=500)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5000)
