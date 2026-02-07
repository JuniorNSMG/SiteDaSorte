// Sincronização Automática - Site da Sorte
// Sincroniza dados da API externa com o Supabase

const SYNC_INTERVAL = 5 * 60 * 1000; // 5 minutos
let syncTimer = null;
let isSyncing = false;

// Iniciar sincronização automática
function startAutoSync() {
    console.log('🔄 Iniciando sincronização automática...');

    // Sincronização inicial
    syncAllLotteries();

    // Sincronização periódica
    syncTimer = setInterval(() => {
        if (!isSyncing) {
            syncAllLotteries();
        }
    }, SYNC_INTERVAL);
}

// Parar sincronização automática
function stopAutoSync() {
    if (syncTimer) {
        clearInterval(syncTimer);
        syncTimer = null;
        console.log('⏸️ Sincronização automática pausada');
    }
}

// Sincronizar todas as loterias
async function syncAllLotteries() {
    if (isSyncing) {
        console.log('⏳ Sincronização já em andamento...');
        return;
    }

    if (!supabaseReady) {
        console.log('⚠️ Supabase não disponível, pulando sincronização');
        return;
    }

    isSyncing = true;
    console.log('🔄 Iniciando sincronização de todas as loterias...');

    let syncedCount = 0;
    let skippedCount = 0;
    let errorCount = 0;

    for (const lottery of LOTTERIES) {
        try {
            const result = await syncLottery(lottery.id, lottery.name);

            if (result === 'synced') {
                syncedCount++;
            } else if (result === 'skipped') {
                skippedCount++;
            } else {
                errorCount++;
            }

            // Pequeno delay entre requisições para não sobrecarregar
            await sleep(500);
        } catch (error) {
            console.error(`Erro ao sincronizar ${lottery.name}:`, error);
            errorCount++;
        }
    }

    console.log(`✅ Sincronização concluída: ${syncedCount} novos, ${skippedCount} existentes, ${errorCount} erros`);
    isSyncing = false;

    // Atualizar interface se houver novos dados
    if (syncedCount > 0) {
        console.log('🔄 Atualizando interface com novos dados...');
        await loadFromSupabase();
    }
}

// Sincronizar uma loteria específica
async function syncLottery(lotteryId, lotteryName) {
    try {
        // Buscar último resultado no Supabase
        const ultimoLocal = await getUltimoResultado(lotteryId);

        // Buscar último resultado da API
        const response = await fetch(`${API_BASE_URL}/${lotteryId}/latest`, {
            cache: 'no-cache'
        });

        if (!response.ok) {
            console.error(`API retornou erro ${response.status} para ${lotteryName}`);
            return 'error';
        }

        const dadosAPI = await response.json();

        // Verificar se já existe
        if (ultimoLocal && ultimoLocal.numero_concurso >= dadosAPI.concurso) {
            console.log(`⏭️ ${lotteryName} concurso ${dadosAPI.concurso} já existe`);
            return 'skipped';
        }

        // Salvar novo resultado
        const salvou = await salvarResultado(lotteryId, dadosAPI);

        if (salvou) {
            console.log(`✅ ${lotteryName} concurso ${dadosAPI.concurso} sincronizado`);
            return 'synced';
        } else {
            return 'error';
        }
    } catch (error) {
        console.error(`Erro ao sincronizar ${lotteryName}:`, error);
        return 'error';
    }
}

// Sincronização manual (botão)
async function manualSync() {
    if (isSyncing) {
        showNotification('Sincronização já em andamento...', 'info');
        return;
    }

    showNotification('Sincronizando loterias...', 'info');
    await syncAllLotteries();
    showNotification('Sincronização concluída!', 'success');
}

// Carregar dados do Supabase (mais rápido que API)
async function loadFromSupabase() {
    const loading = document.getElementById('loading');
    const results = document.getElementById('results');
    const error = document.getElementById('error');

    try {
        // Mostrar loading
        if (loading) loading.classList.remove('hidden');
        if (results) results.classList.add('hidden');
        if (error) error.classList.add('hidden');

        const dados = await getTodosUltimosResultados();

        if (!dados || dados.length === 0) {
            console.log('📥 Nenhum dado no Supabase, usando API...');
            return false;
        }

        // Converter formato do Supabase para formato esperado pela UI
        lotteriesData = dados.map(item => ({
            lotteryName: getLotteryName(item.tipo_loteria),
            lotteryColor: getLotteryColor(item.tipo_loteria),
            concurso: item.numero_concurso,
            data: formatDateBR(item.data_sorteio),
            dezenas: item.dezenas,
            acumulou: item.acumulou,
            valorEstimadoProximoConcurso: item.valor_estimado_proximo,
            dataProximoConcurso: formatDateBR(item.data_proximo_concurso),
            premiacoes: item.premiacoes
        }));

        // Ordenar por concurso
        lotteriesData.sort((a, b) => b.concurso - a.concurso);

        // Esconder loading e mostrar resultados
        if (loading) loading.classList.add('hidden');
        if (results) results.classList.remove('hidden');

        renderLotteries();
        console.log('✅ Dados carregados do Supabase');
        return true;
    } catch (error) {
        console.error('Erro ao carregar do Supabase:', error);

        // Esconder loading em caso de erro
        if (loading) loading.classList.add('hidden');

        return false;
    }
}

// Obter nome da loteria por ID
function getLotteryName(id) {
    const lottery = LOTTERIES.find(l => l.id === id);
    return lottery ? lottery.name : id;
}

// Obter cor da loteria por ID
function getLotteryColor(id) {
    const lottery = LOTTERIES.find(l => l.id === id);
    return lottery ? lottery.color : '#666';
}

// Sleep helper
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// Mostrar notificação
function showNotification(message, type = 'info') {
    // Criar elemento de notificação
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.style.cssText = `
        position: fixed;
        top: 80px;
        right: 20px;
        background: ${type === 'success' ? '#247BA0' : type === 'error' ? '#374151' : '#1B98E0'};
        color: white;
        padding: 1rem 1.5rem;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.2);
        z-index: 1000;
        animation: slideIn 0.3s ease-out;
    `;
    notification.textContent = message;

    document.body.appendChild(notification);

    // Remover após 3 segundos
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease-out';
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

// Adicionar animações CSS
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }

    @keyframes slideOut {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);

// Exportar funções
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        startAutoSync,
        stopAutoSync,
        syncAllLotteries,
        manualSync,
        loadFromSupabase
    };
}
