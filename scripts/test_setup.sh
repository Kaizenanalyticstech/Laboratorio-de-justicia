#!/usr/bin/env bash
set -e

echo "🧪 Probando configuración del ODR Chatbot MVP..."

# Verificar que Docker está corriendo
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker no está corriendo. Inicia Docker y vuelve a intentar."
    exit 1
fi

# Verificar que los servicios están corriendo
echo "📋 Verificando servicios..."

# API
echo "🔍 Probando API en http://localhost:5000/health..."
if curl -s http://localhost:5000/health | grep -q '"ok": true'; then
    echo "✅ API funcionando correctamente"
else
    echo "❌ API no responde. Verifica que el servicio esté corriendo."
    echo "   Comando: docker compose ps"
fi

# Web UI
echo "🔍 Probando Web UI en http://localhost:3000..."
if curl -s -I http://localhost:3000 | grep -q "HTTP/1.1 200"; then
    echo "✅ Web UI funcionando correctamente"
else
    echo "❌ Web UI no responde. Verifica que el servicio esté corriendo."
    echo "   Comando: docker compose ps"
fi

# Verificar que los modelos están descargados
if [ -f models/tinyllama-1.1b-chat.Q4_K_M.gguf ]; then
    echo "✅ Modelo TinyLlama descargado"
else
    echo "⚠️  Modelo no encontrado. Ejecuta: bash scripts/setup_models.sh"
fi

echo ""
echo "🎉 Configuración completada!"
echo "📱 Abre http://localhost:3000 en tu navegador"
echo "🔧 API disponible en http://localhost:5000"
echo ""
echo "📝 Próximos pasos:"
echo "1. Sube un PDF en la UI web"
echo "2. Haz una pregunta sobre el documento"
echo "3. El bot responderá con citas [Documento p.X]"

