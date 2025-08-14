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
  embedding VECTOR(1024), -- bge-m3 dimension
  created_at TIMESTAMP DEFAULT NOW()
);

-- Índice para búsqueda por similitud (IVFFlat). Requiere ANALYZE tras insertar.
CREATE INDEX IF NOT EXISTS idx_chunks_embedding
ON chunks
USING ivfflat (embedding vector_cosine_ops);

-- Índice por documento
CREATE INDEX IF NOT EXISTS idx_chunks_document_id ON chunks(document_id);
