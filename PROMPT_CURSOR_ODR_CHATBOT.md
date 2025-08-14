# PROMPT PARA CURSOR — "ODR Chatbot sin cuotas (self-hosted)"

Eres un asistente de desarrollo full-stack senior. Crea un proyecto llamado `odr-chatbot-mvp` 100% autoalojado (sin servicios de pago) con esta estructura y contenidos exactos. Cuando termines, imprime los comandos para correrlo y pruebas de verificación.

## Requisitos de la solución
- **Sin cuotas mensuales**: todo local con Docker.
- **Servicios**: PostgreSQL 16 + pgvector, TEI (HuggingFace Text Embeddings Inference) con BAAI/bge-m3, llama.cpp (API estilo OpenAI) con un modelo GGUF local, FastAPI (API), Nginx (UI estática).

## Funcionalidad:
- `POST /ingest` (subida PDF → chunking → embeddings → guardado en Postgres).
- `POST /chat` (consulta → retrieve top-k por similitud → prompt a llama.cpp → respuesta con citas [Documento p.X]).
- UI web mínima: subir PDF y chatear.
- Docker Compose con healthchecks básicos.
- README con pasos para correrlo.

## Estructura y archivos (crear exactamente):
```
odr-chatbot-mvp/
├─ README.md
├─ .env.example
├─ docker-compose.yml
├─ db/
│  └─ init.sql
├─ scripts/
│  └─ setup_models.sh
├─ services/
│  └─ api/
│     ├─ Dockerfile
│     ├─ requirements.txt
│     └─ main.py
└─ web/
   ├─ Dockerfile
   ├─ index.html
   ├─ style.css
   └─ app.js
```

## 1) README.md
```markdown
# ODR Chatbot MVP — 100% autoalojado (sin cuotas)

Este MVP provee:
- **Chat RAG**: ingesta de PDFs, búsqueda semántica y respuestas con fuentes.
- **Stack libre**: Postgres + pgvector, FastAPI, UI web estática, **llama.cpp** con un modelo local, **TEI** (HuggingFace) para embeddings locales.
- **Sin cuotas mensuales**: todo corre en tu propio servidor/PC (o LAN).

> Requisitos: Linux (Ubuntu 22.04+ recomendado), Docker y Docker Compose plugin.

## Servicios (docker-compose)
- `postgres`: PostgreSQL 16 con extensión `pgvector`.
- `tei`: Text Embeddings Inference con modelo **BAAI/bge-m3** (local).
- `llama`: Servidor **llama.cpp** con API compatible OpenAI (modelo local GGUF).
- `api`: FastAPI con endpoints `/ingest` y `/chat`.
- `web`: UI web estática (HTML/JS) con chat mínimo.

## Primeros pasos
1) Clona este proyecto y copia `.env.example` a `.env` (edita si lo deseas).
2) Descarga los modelos (una sola vez):
```bash
bash scripts/setup_models.sh
```
Por defecto baja TinyLlama-1.1B-Chat en formato GGUF (rápido en CPU).

Puedes cambiar por un modelo mayor en `scripts/setup_models.sh` (p. ej., Qwen2-7B-Instruct GGUF).

3) Levanta todo:
```bash
docker compose up -d --build
```

4) Abre http://localhost:3000 (UI web).

5) Ingesta un PDF en http://localhost:3000 (o vía API) y prueba el chat.

## Endpoints (resumen)
- `POST /ingest` (multipart): `file` (PDF). Divide en chunks, calcula embeddings y guarda en Postgres.
- `POST /chat` (JSON): `{ "query": "..." }` → Hace búsqueda semántica + prompt a llama.cpp y devuelve respuesta con fragmentos citados.

## Notas
- Este MVP guarda archivos en `data/uploads/` (dentro del contenedor api), y metadatos en Postgres.
- Puedes apuntar la UI a otra URL de API vía `WEB_API_BASE` en `.env`.
- **Sin cuotas**: no se usa ningún servicio pago. Si no quieres pagar VPS, corre en una máquina local u on-prem.
- Para producción, considera: backup, HTTPS con Caddy/Traefik, RBAC (Keycloak), logging y monitoreo.
```

## 2) `.env.example`
```env
# Variables de entorno (copia a .env si quieres personalizar)
POSTGRES_USER=odr_user
POSTGRES_PASSWORD=odr_pass
POSTGRES_DB=odr_db
POSTGRES_PORT=5432

# API
API_PORT=5000
API_HOST=0.0.0.0

# TEI (Text Embeddings Inference)
TEI_PORT=8080
TEI_MODEL_ID=BAAI/bge-m3

# Llama.cpp (servidor OpenAI-like)
LLAMA_PORT=8081
LLAMA_MODEL_PATH=/models/tinyllama-1.1b-chat.Q4_K_M.gguf
LLAMA_CTX_SIZE=4096
LLAMA_PARALLEL=2

# WEB
WEB_PORT=3000
WEB_API_BASE=http://localhost:5000
```

## 3) docker-compose.yml
```yaml
version: "3.9"
services:
  postgres:
    image: pgvector/pgvector:pg16
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    ports:
      - "${POSTGRES_PORT:-5432}:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql:ro

  tei:
    image: ghcr.io/huggingface/text-embeddings-inference:1.5
    restart: unless-stopped
    environment:
      MODEL_ID: ${TEI_MODEL_ID:-BAAI/bge-m3}
      HF_HUB_ENABLE_TELEMETRY: "0"
    ports:
      - "${TEI_PORT:-8080}:8080"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 15s
      timeout: 5s
      retries: 12

  llama:
    image: ghcr.io/ggerganov/llama.cpp:server
    command: >
      --host 0.0.0.0
      --port 8080
      --api-server
      --model ${LLAMA_MODEL_PATH:-/models/tinyllama-1.1b-chat.Q4_K_M.gguf}
      --ctx-size ${LLAMA_CTX_SIZE:-4096}
      --parallel ${LLAMA_PARALLEL:-2}
    volumes:
      - ./models:/models
    ports:
      - "${LLAMA_PORT:-8081}:8080"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 15s
      timeout: 5s
      retries: 12

  api:
    build:
      context: ./services/api
      dockerfile: Dockerfile
    restart: unless-stopped
    environment:
      DATABASE_URL: postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}
      TEI_BASE_URL: http://tei:8080
      LLAMA_BASE_URL: http://llama:8080/v1
      FILES_DIR: /app/data/uploads
      HOST: ${API_HOST:-0.0.0.0}
      PORT: ${API_PORT:-5000}
      CORS_ORIGINS: http://localhost:${WEB_PORT:-3000}
    volumes:
      - api_data:/app/data
    depends_on:
      - postgres
      - tei
      - llama
    ports:
      - "5000:5000"

  web:
    build:
      context: ./web
      dockerfile: Dockerfile
    restart: unless-stopped
    environment:
      API_BASE: ${WEB_API_BASE:-http://localhost:5000}
    ports:
      - "3000:80"
    depends_on:
      - api

volumes:
  pgdata:
  api_data:
```

## 4) db/init.sql
```sql
CREATE EXTENSION IF NOT EXISTS vector;

-- Documentos y chunks con embeddings (cosine 1024 dims para BAAI/bge-m3)
CREATE TABLE IF NOT EXISTS documents (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS chunks (
  id SERIAL PRIMARY KEY,
  document_id INT REFERENCES documents(id) ON DELETE CASCADE,
  page INT,
  content TEXT NOT NULL,
  embedding VECTOR(1024),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chunks_embedding
ON chunks
USING ivfflat (embedding vector_cosine_ops);

CREATE INDEX IF NOT EXISTS idx_chunks_document_id ON chunks(document_id);
```

## 5) scripts/setup_models.sh
```bash
#!/usr/bin/env bash
set -e

mkdir -p models

# Modelo por defecto (rápido y liviano en CPU):
# TinyLlama-1.1B-Chat en GGUF Q4_K_M
if [ ! -f models/tinyllama-1.1b-chat.Q4_K_M.gguf ]; then
  echo "Descargando TinyLlama 1.1B Chat (GGUF Q4_K_M)..."
  curl -L -o models/tinyllama-1.1b-chat.Q4_K_M.gguf \
    https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat.Q4_K_M.gguf
fi

echo "Modelos listos. Puedes cambiar LLAMA_MODEL_PATH en .env si usas otro modelo."
```

## 6) services/api/Dockerfile
```dockerfile
FROM python:3.11-slim

WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app

EXPOSE 5000
CMD ["bash", "-lc", "uvicorn main:app --host ${HOST:-0.0.0.0} --port ${PORT:-5000}"]
```

## 7) services/api/requirements.txt
```
fastapi==0.115.0
uvicorn[standard]==0.30.6
pydantic==2.8.2
python-multipart==0.0.9
psycopg2-binary==2.9.9
pypdf==4.3.1
numpy==1.26.4
requests==2.32.3
```

## 8) services/api/main.py
```python
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

DATABASE_URL = os.environ.get("DATABASE_URL", "postgres://odr_user:odr_pass@localhost:5432/odr_db")
TEI_BASE_URL = os.environ.get("TEI_BASE_URL", "http://localhost:8080")
LLAMA_BASE_URL = os.environ.get("LLAMA_BASE_URL", "http://localhost:8081/v1")
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
    conn = psycopg2.connect(DATABASE_URL)
    return conn

def tei_embed(texts: t.List[str]) -> np.ndarray:
    """Call TEI to embed texts. Returns np.array shape (n, 1024) for bge-m3."""
    url = f"{TEI_BASE_URL}/embeddings"
    payload = {"input": texts}
    r = requests.post(url, json=payload, timeout=180)
    r.raise_for_status()
    data = r.json()
    embs = [np.array(item["embedding"], dtype=np.float32) for item in data["data"]]
    return np.vstack(embs)

def cosine_normalize(vecs: np.ndarray) -> np.ndarray:
    norms = np.linalg.norm(vecs, axis=1, keepdims=True) + 1e-12
    return vecs / norms

def chunk_text(text: str, chunk_size: int = 1200, overlap: int = 150) -> t.List[str]:
    chunks = []
    start = 0
    n = len(text)
    while start < n:
        end = min(n, start + chunk_size)
        chunk = text[start:end]
        chunks.append(chunk)
        start = end - overlap if end - overlap > start else end
    return chunks

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
    fname = name or file.filename
    path = os.path.join(FILES_DIR, fname)
    with open(path, "wb") as f:
        f.write(file.file.read())

    reader = PdfReader(path)
    all_pages_text = []
    for i, page in enumerate(reader.pages):
        try:
            txt = page.extract_text() or ""
        except Exception:
            txt = ""
        all_pages_text.append((i + 1, txt))

    conn = get_db()
    cur = conn.cursor()
    cur.execute("INSERT INTO documents (name) VALUES (%s) RETURNING id;", (fname,))
    doc_id = cur.fetchone()[0]

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
        return {"document_id": doc_id, "chunks": 0, "message": "PDF sin texto extraíble o vacío."}

    texts = [r[1] for r in rows]
    embs = tei_embed(texts)
    embs = cosine_normalize(embs)

    insert_sql = "INSERT INTO chunks (document_id, page, content, embedding) VALUES (%s, %s, %s, %s)"
    for (page_no, content), emb in zip(rows, embs):
        cur.execute(insert_sql, (doc_id, page_no, content, emb.tolist()))
    conn.commit()
    conn.close()
    return {"document_id": doc_id, "chunks": len(rows), "pages": len(all_pages_text)}

def llama_chat(messages: t.List[dict], temperature: float = 0.2, max_tokens: int = 512) -> str:
    url = f"{LLAMA_BASE_URL}/chat/completions"
    payload = {
        "model": "local-gguf",
        "messages": messages,
        "temperature": temperature,
        "max_tokens": max_tokens,
        "stream": False
    }
    r = requests.post(url, json=payload, timeout=180)
    r.raise_for_status()
    data = r.json()
    try:
        return data["choices"][0]["message"]["content"]
    except Exception:
        return json.dumps(data)[:2000]

@app.post("/chat")
def chat(req: ChatRequest):
    q = req.query.strip()
    if not q:
        return JSONResponse({"error": "Pregunta vacía"}, status_code=400)

    q_emb = tei_embed([q])
    q_emb = cosine_normalize(q_emb)[0].tolist()

    conn = get_db()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    cur.execute(
        """
        SELECT c.id, c.content, c.page, d.name as document_name,
               (1 - (c.embedding <=> %s)) AS score
        FROM chunks c
        JOIN documents d ON d.id = c.document_id
        ORDER BY c.embedding <=> %s
        LIMIT %s;
        """,
        (q_emb, q_emb, req.top_k)
    )
    rows = cur.fetchall()
    conn.close()

    context_parts = []
    sources = []
    for r in rows:
        context_parts.append(f"[{r['document_name']} p.{r['page']}]\n{r['content']}")
        sources.append({"document": r["document_name"], "page": r["page"], "score": float(r["score"])})

    system_prompt = (
        "Eres un asistente para ODR/Editorial/Observatorio. "
        "Responde en español con precisión y citas en formato [Documento p.X]. "
        "Si no hay información suficiente, dilo claramente."
    )
    context = "\n\n".join(context_parts[:10]) or "N/A"

    user_prompt = (
        f"Pregunta: {q}\n\n"
        f"Contexto recuperado (puede estar incompleto):\n{context}\n\n"
        "Responde de forma breve, con puntos concretos y referencias [Documento p.X] cuando apliquen."
    )

    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": user_prompt}
    ]
    answer = llama_chat(messages, temperature=req.temperature, max_tokens=req.max_tokens)
    return {"answer": answer, "sources": sources}
```

## 9) web/Dockerfile
```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
```

## 10) web/index.html
```html
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>ODR Chatbot MVP</title>
  <link rel="stylesheet" href="style.css" />
</head>
<body>
  <header>
    <h1>ODR Chatbot (MVP sin cuotas)</h1>
    <p>Sube un PDF, luego realiza preguntas. Todo corre local.</p>
  </header>

  <section class="ingest">
    <h2>Ingesta de PDF</h2>
    <form id="ingestForm">
      <input type="file" id="pdfFile" accept="application/pdf" required />
      <button type="submit">Subir e indexar</button>
    </form>
    <div id="ingestResult"></div>
  </section>

  <section class="chat">
    <h2>Chat</h2>
    <div id="chatBox"></div>
    <form id="chatForm">
      <input type="text" id="query" placeholder="Escribe tu pregunta..." required />
      <button type="submit">Preguntar</button>
    </form>
  </section>

  <footer>
    <small>Autoalojado · Postgres+pgvector · llama.cpp · TEI</small>
  </footer>

  <script src="app.js"></script>
</body>
</html>
```

## 11) web/style.css
```css
*{box-sizing:border-box}body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Ubuntu,Helvetica,Arial,sans-serif;margin:0;padding:0;background:#0b0c10;color:#f0f0f0}
header,section,footer{max-width:900px;margin:20px auto;padding:16px}
header{background:#121318;border-radius:14px;box-shadow:0 10px 20px rgba(0,0,0,.25)}
h1{margin:0 0 6px}
.ingest,.chat{background:#121318;border:1px solid #1e212a;border-radius:14px}
#chatBox{height:380px;overflow:auto;background:#0e0f15;border:1px solid #1e212a;border-radius:12px;padding:12px;margin-bottom:10px}
.message{padding:10px;border-radius:10px;margin:8px 0;white-space:pre-wrap}
.user{background:#1e2538}
.bot{background:#13231e}
form{display:flex;gap:8px}
input[type="text"]{flex:1;padding:10px;border-radius:10px;border:1px solid #2a3142;background:#0e1220;color:#eaeaea}
button{padding:10px 14px;border:none;border-radius:10px;background:#3a86ff;color:white;cursor:pointer}
button:hover{filter:brightness(1.05)}
#ingestResult{margin-top:8px;font-size:14px;opacity:.9}
```

## 12) web/app.js
```javascript
(function(){
  const apiBase = (window.API_BASE) || (new URLSearchParams(location.search).get('api') || (window.API_BASE_DEFAULT || 'http://localhost:5000'));
  const chatBox = document.getElementById('chatBox');
  const chatForm = document.getElementById('chatForm');
  const ingestForm = document.getElementById('ingestForm');
  const ingestResult = document.getElementById('ingestResult');

  function addMessage(text, who){
    const div = document.createElement('div');
    div.className = 'message ' + (who === 'user' ? 'user' : 'bot');
    div.textContent = text;
    chatBox.appendChild(div);
    chatBox.scrollTop = chatBox.scrollHeight;
  }

  ingestForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const f = document.getElementById('pdfFile').files[0];
    if(!f) return;
    const formData = new FormData();
    formData.append('file', f, f.name);
    try {
      ingestResult.textContent = 'Subiendo e indexando...';
      const res = await fetch(apiBase + '/ingest', { method: 'POST', body: formData });
      const data = await res.json();
      if(!res.ok) throw new Error(JSON.stringify(data));
      ingestResult.textContent = `Listo: documento ${data.document_id}, chunks=${data.chunks}`;
    } catch (err) {
      ingestResult.textContent = 'Error: ' + (err.message || err);
    }
  });

  chatForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const q = document.getElementById('query').value.trim();
    if(!q) return;
    addMessage(q, 'user');
    document.getElementById('query').value = '';
    try {
      const res = await fetch(apiBase + '/chat', { 
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ query: q, top_k: 4, temperature: 0.2, max_tokens: 512 })
      });
      const data = await res.json();
      if(!res.ok) throw new Error(JSON.stringify(data));
      const src = (data.sources||[]).map(s => `[${s.document} p.${s.page}]`).join(' ');
      addMessage(data.answer + (src ? '\n\n' + src : ''), 'bot');
    } catch (err) {
      addMessage('Error: ' + (err.message || err), 'bot');
    }
  });
})();
```

## Al finalizar la creación, ejecuta automáticamente:
```bash
chmod +x scripts/setup_models.sh
bash scripts/setup_models.sh
cp .env.example .env
docker compose up -d --build
```

## Pruebas automáticas de verificación (imprimir y ejecutar):
```bash
# API viva
curl -s http://localhost:5000/health

# Ingestar un PDF (reemplaza ruta.pdf por un archivo real)
curl -s -F "file=@ruta.pdf" http://localhost:5000/ingest

# Hacer una pregunta
curl -s -H "Content-Type: application/json" -d '{"query":"¿Qué dice el documento sobre mediación?"}' http://localhost:5000/chat
```

**Criterio de aceptación**: UI accesible en http://localhost:3000, `/ingest` indexa un PDF real, `/chat` devuelve respuesta con citas [Documento p.X]. Todo funciona sin usar servicios pagos.
