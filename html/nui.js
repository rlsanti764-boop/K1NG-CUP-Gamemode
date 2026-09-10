// K1NG CUP - NUI JavaScript Handler

// Verificar se está em FiveM
const inFiveM = window.GetParentResourceName !== undefined;

// Função para enviar dados ao Lua
function sendToLua(eventName, data) {
    if (inFiveM) {
        fetch(`https://${GetParentResourceName()}/${eventName}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        }).catch(e => console.log(e));
    } else {
        console.log(`[K1NG CUP] ${eventName}:`, data);
    }
}

// Função para fechar menu
function fecharMenu() {
    sendToLua('fecharMenu', {});
}

// ===== MENU PRINCIPAL =====
function abrirEscolherTime() {
    window.location.href = 'times.html';
}

function abrirTelagem() {
    window.location.href = 'telagem.html';
}

function abrirBox() {
    window.location.href = 'box.html';
}

function iniciarPartida() {
    sendToLua('iniciarPartida', {});
    fecharMenu();
}

// ===== ESCOLHER TIMES =====
function entrarNoTime(timeId) {
    sendToLua('escolherTime', { time: timeId });
    fecharMenu();
}

// ===== TELAGEM =====
function atualizarTelagem(times) {
    const tbody = document.getElementById('tabela-body');
    if (tbody) {
        tbody.innerHTML = '';
        times.forEach((time, index) => {
            const kd = time.mortes > 0 ? (time.kills / time.mortes).toFixed(2) : time.kills.toFixed(2);
            const cor = ['#FF0000', '#0000FF', '#FFFF00', '#00FF00', '#FF00FF', '#FF6600'][index % 6];
            
            const tr = document.createElement('tr');
            tr.className = 'time-row';
            tr.style.borderLeft = `5px solid ${cor}`;
            tr.innerHTML = `
                <td><strong>TIME ${index + 1}</strong></td>
                <td class="jogadores">${time.jogadores.length}</td>
                <td class="kills">${time.kills}</td>
                <td class="mortes">${time.mortes}</td>
                <td class="kd">${kd}</td>
            `;
            tbody.appendChild(tr);
        });
    }
}

// ===== BOX MENU =====
function abrirAba(abaName) {
    // Fechar todas as abas
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.classList.remove('active');
    });
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });

    // Abrir aba selecionada
    const aba = document.getElementById(abaName + '-tab');
    if (aba) {
        aba.classList.add('active');
    }

    // Marcar botão como ativo
    event.target.classList.add('active');
}

function selecionarSkin(skinName, element) {
    document.querySelectorAll('.skin-card').forEach(card => {
        card.classList.remove('selected');
    });
    element.classList.add('selected');

    sendToLua('selecionarSkin', { skin: skinName });
    console.log(`Skin selecionada: ${skinName}`);
}

function selecionarArma(armaNome, element) {
    document.querySelectorAll('.arma-card').forEach(card => {
        card.classList.remove('selected');
    });
    element.classList.add('selected');

    sendToLua('selecionarArma', { arma: armaNome });
    console.log(`Arma selecionada: ${armaNome}`);
}

function selecionarRoupa(roupaNome, element) {
    document.querySelectorAll('.roupa-card').forEach(card => {
        card.classList.remove('selected');
    });
    element.classList.add('selected');

    sendToLua('selecionarRoupa', { roupa: roupaNome });
    console.log(`Roupa selecionada: ${roupaNome}`);
}

// Receber mensagens do Lua
window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'atualizarTelagem') {
        atualizarTelagem(data.times);
    }

    if (data.action === 'fecharNUI') {
        // Fechar o NUI
        sendToLua('nuiFocus', { focus: false, mouse: false });
    }
});

// ESC para fechar
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        fecharMenu();
    }
});

// Ao carregar a página
document.addEventListener('DOMContentLoaded', () => {
    console.log('[K1NG CUP] Interface carregada!');

    // Se for telagem, pedir dados ao servidor
    if (window.location.href.includes('telagem.html')) {
        sendToLua('pedirDadosTelagem', {});
    }
});