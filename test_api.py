import requests
import json

# Configuración
API_BASE = "http://localhost:5000"

def test_health():
    """Probar el endpoint de health"""
    try:
        response = requests.get(f"{API_BASE}/health")
        print(f"Health Check - Status: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error en health check: {e}")
        return False

def test_chat():
    """Probar el endpoint de chat"""
    try:
        data = {
            "query": "¿Qué es el derecho?",
            "top_k": 4,
            "temperature": 0.2,
            "max_tokens": 512
        }
        response = requests.post(f"{API_BASE}/chat", json=data)
        print(f"Chat Test - Status: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error en chat test: {e}")
        return False

def test_upload():
    """Probar el endpoint de upload con un archivo de prueba"""
    try:
        # Crear un archivo de prueba
        with open("test.txt", "w", encoding="utf-8") as f:
            f.write("Este es un documento de prueba para verificar la funcionalidad de la API.")
        
        with open("test.txt", "rb") as f:
            files = {"file": ("test.txt", f, "text/plain")}
            response = requests.post(f"{API_BASE}/ingest", files=files)
        
        print(f"Upload Test - Status: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error en upload test: {e}")
        return False

if __name__ == "__main__":
    print("=== Test de API ODR Chatbot ===\n")
    
    # Test 1: Health Check
    print("1. Probando Health Check...")
    health_ok = test_health()
    print()
    
    # Test 2: Chat
    print("2. Probando Chat...")
    chat_ok = test_chat()
    print()
    
    # Test 3: Upload
    print("3. Probando Upload...")
    upload_ok = test_upload()
    print()
    
    # Resumen
    print("=== Resumen ===")
    print(f"Health Check: {'✅ OK' if health_ok else '❌ FALLO'}")
    print(f"Chat: {'✅ OK' if chat_ok else '❌ FALLO'}")
    print(f"Upload: {'✅ OK' if upload_ok else '❌ FALLO'}")
