// Configuración - Detecta automáticamente si está en local o online
const isLocal = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
const apiBase = isLocal ? 'http://localhost:5000' : `${window.location.protocol}//${window.location.hostname}/api`;

// Elementos del DOM
const chatBox = document.getElementById('chatBox');
const chatForm = document.getElementById('chatForm');
const ingestForm = document.getElementById('ingestForm');
const ingestResult = document.getElementById('ingestResult');
const pdfFile = document.getElementById('pdfFile');

// Función para agregar mensajes al chat
function addMessage(text, who) {
    const div = document.createElement('div');
    div.className = `message ${who}`;
    
    const header = document.createElement('div');
    header.className = 'message-header';
    
    if (who === 'user') {
        header.innerHTML = '<i class="fas fa-user"></i> <span>Tú</span>';
    } else {
        header.innerHTML = '<i class="fas fa-robot"></i> <span>Asistente Legal</span>';
    }
    
    const content = document.createElement('div');
    content.textContent = text;
    
    div.appendChild(header);
    div.appendChild(content);
    chatBox.appendChild(div);
    chatBox.scrollTop = chatBox.scrollHeight;
}

// Función para mostrar resultados
function showResult(message, type = 'success') {
    ingestResult.textContent = message;
    ingestResult.className = `result-message ${type}`;
    setTimeout(() => {
        ingestResult.textContent = '';
        ingestResult.className = 'result-message';
    }, 5000);
}

// Event listener para el formulario de ingesta
ingestForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const file = pdfFile.files[0];
    if (!file) {
        showResult('Por favor selecciona un archivo PDF', 'error');
        return;
    }
    
    if (file.type !== 'application/pdf') {
        showResult('Solo se permiten archivos PDF', 'error');
        return;
    }
    
    const formData = new FormData();
    formData.append('file', file, file.name);
    
    try {
        showResult('Subiendo e indexando documento...', 'success');
        
        const res = await fetch(apiBase + '/ingest', { 
            method: 'POST', 
            body: formData 
        });
        
        const data = await res.json();
        
        if (!res.ok) {
            throw new Error(data.detail || JSON.stringify(data));
        }
        
        showResult(`✅ Documento indexado: ${data.document_id}, ${data.chunks} fragmentos`, 'success');
        addMessage('Documento subido e indexado correctamente. Ahora puedes hacer preguntas sobre su contenido.', 'bot');
        
        // Limpiar archivo
        pdfFile.value = '';
        
    } catch (err) {
        console.error('Error:', err);
        showResult('❌ Error: ' + (err.message || err), 'error');
    }
});

// Event listener para el formulario de chat
chatForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const query = document.getElementById('query').value.trim();
    if (!query) return;
    
    // Agregar mensaje del usuario
    addMessage(query, 'user');
    document.getElementById('query').value = '';
    
    try {
        const res = await fetch(apiBase + '/chat', { 
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
                query: query, 
                top_k: 4, 
                temperature: 0.2, 
                max_tokens: 512 
            })
        });
        
        const data = await res.json();
        
        if (!res.ok) {
            throw new Error(data.detail || JSON.stringify(data));
        }
        
        // Agregar respuesta del bot
        addMessage(data.answer, 'bot');
        
    } catch (err) {
        console.error('Error:', err);
        addMessage('❌ Error: ' + (err.message || err), 'bot');
    }
});

// Inicialización
document.addEventListener('DOMContentLoaded', () => {
    console.log('ODR Chatbot iniciado');
    console.log('API Base:', apiBase);
    console.log('Modo:', isLocal ? 'Local' : 'Online');
    
    // Verificar conexión con la API
    fetch(apiBase + '/health')
        .then(res => res.json())
        .then(data => {
            if (data.ok) {
                console.log('✅ API conectada correctamente');
            }
        })
        .catch(err => {
            console.error('❌ Error conectando con la API:', err);
        });
});