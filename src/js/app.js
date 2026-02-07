// Site da Sorte - Aplicação Principal
// Versão com integração Supabase

const API_BASE_URL = 'https://loteriascaixa-api.herokuapp.com/api';

// Configurações das loterias
const LOTTERIES = [
    { id: 'megasena', name: 'Mega-Sena', color: '#209869' },
    { id: 'lotofacil', name: 'Lotofácil', color: '#930089' },
    { id: 'quina', name: 'Quina', color: '#260085' },
    { id: 'lotomania', name: 'Lotomania', color: '#F78100' },
    { id: 'timemania', name: 'Timemania', color: '#00FF48' },
    { id: 'duplasena', name: 'Dupla Sena', color: '#A61324' },
    { id: 'diadesorte', name: 'Dia de Sorte', color: '#CB852B' },
    { id: 'supersete', name: 'Super Sete', color: '#A8CF45' },
    { id: 'maismilionaria', name: '+Milionária', color: '#208068' }
];

// Gerenciamento de estado
let lotteriesData = [];
let isOnline = navigator.onLine;
let useSupabase = false;

// Inicializar aplicação
document.addEventListener('DOMContentLoaded', async () => {
    await initApp();
    setupEventListeners();
    checkOnlineStatus();
});

async function initApp() {
    try {
        // Tentar inicializar Supabase
        useSupabase = await initSupabase();

        if (useSupabase) {
            // Carregar do Supabase (mais rápido)
            const loaded = await loadFromSupabase();

            if (!loaded) {
                // Fallback para API
                await fetchAllLotteries();
            }

            // Iniciar sincronização automática em background
            startAutoSync();
        } else {
            // Apenas API
            await fetchAllLotteries();

            // Atualizar periodicamente da API
            setInterval(() => {
                if (isOnline) {
                    fetchAllLotteries();
                }
            }, 5 * 60 * 1000);
        }

        renderLotteries();
    } catch (error) {
        console.error('Erro ao inicializar aplicação:', error);
        showError();
    }
}

function setupEventListeners() {
    // Eventos de conectividade
    window.addEventListener('online', () => {
        isOnline = true;
        hideOfflineBanner();
        initApp();
    });

    window.addEventListener('offline', () => {
        isOnline = false;
        showOfflineBanner();
    });

    // Botão de sincronização manual
    const syncButton = document.getElementById('syncButton');
    if (syncButton) {
        syncButton.addEventListener('click', manualSync);
    }
}

function checkOnlineStatus() {
    if (!isOnline) {
        showOfflineBanner();
    }
}

async function fetchAllLotteries() {
    const loading = document.getElementById('loading');
    const results = document.getElementById('results');
    const error = document.getElementById('error');

    loading.classList.remove('hidden');
    results.classList.add('hidden');
    error.classList.add('hidden');

    const promises = LOTTERIES.map(lottery =>
        fetchLottery(lottery.id, lottery.name, lottery.color)
    );

    const settled = await Promise.allSettled(promises);

    lotteriesData = settled
        .filter(result => result.status === 'fulfilled' && result.value)
        .map(result => result.value);

    // Ordenar por maior acumulação/prêmio estimado primeiro
    lotteriesData.sort((a, b) => {
        const valorA = a.valorEstimadoProximoConcurso || 0;
        const valorB = b.valorEstimadoProximoConcurso || 0;
        return valorB - valorA;
    });

    loading.classList.add('hidden');

    if (lotteriesData.length > 0) {
        results.classList.remove('hidden');
    } else {
        error.classList.remove('hidden');
    }
}

async function fetchLottery(id, name, color) {
    try {
        const response = await fetch(`${API_BASE_URL}/${id}/latest`, {
            cache: 'default'
        });

        if (!response.ok) {
            throw new Error(`Erro HTTP! status: ${response.status}`);
        }

        const data = await response.json();

        // Salvar no Supabase se disponível
        if (useSupabase) {
            await salvarResultado(id, data);
        }

        return { ...data, lotteryName: name, lotteryColor: color };
    } catch (error) {
        console.error(`Erro ao buscar ${name}:`, error);
        return null;
    }
}

function renderLotteries() {
    const resultsContainer = document.getElementById('results');
    resultsContainer.innerHTML = '';

    // Adicionar cabeçalho
    const header = document.createElement('div');
    header.className = 'mb-8 text-center';
    header.innerHTML = `
        <div class="flex items-center justify-center gap-4 mb-4">
            <h2 class="text-2xl md:text-3xl font-bold text-dark-navy">
                Últimos Resultados
            </h2>
            ${useSupabase ? `
                <button id="syncButton" class="bg-ocean-blue hover:bg-sky-blue text-white px-4 py-2 rounded-lg font-medium transition-colors duration-200 text-sm">
                    🔄 Sincronizar
                </button>
            ` : ''}
        </div>
        <p class="text-gray-600">
            Confira os resultados mais recentes das loterias da CAIXA
        </p>
        ${useSupabase ? `
            <p class="text-xs text-gray-500 mt-2">
                📊 Dados armazenados no Supabase | Sincronização automática a cada 5 minutos
            </p>
        ` : ''}
    `;
    resultsContainer.appendChild(header);

    // Criar grid de loterias
    const grid = document.createElement('div');
    grid.className = 'lottery-grid';

    lotteriesData.forEach((lottery, index) => {
        const card = createLotteryCard(lottery, index);
        grid.appendChild(card);
    });

    resultsContainer.appendChild(grid);

    // Re-adicionar event listener do botão de sync
    if (useSupabase) {
        const syncButton = document.getElementById('syncButton');
        if (syncButton) {
            syncButton.addEventListener('click', manualSync);
        }
    }
}

function createLotteryCard(lottery, index) {
    const card = document.createElement('div');
    card.className = 'lottery-card p-6 fade-in-up';
    card.style.animationDelay = `${index * 0.1}s`;

    const numbersHTML = lottery.dezenas.map(num =>
        `<div class="number-ball">${num}</div>`
    ).join('');

    const nextDrawDate = lottery.dataProximoConcurso || 'A definir';
    const nextDrawValue = lottery.valorEstimadoProximoConcurso
        ? formatCurrency(lottery.valorEstimadoProximoConcurso)
        : 'A definir';

    const statusBadge = lottery.acumulou
        ? '<span class="status-accumulated">ACUMULOU</span>'
        : '<span class="status-has-winner">TEM GANHADOR</span>';

    // Criar HTML das premiações (destacado)
    let premiacoesHTML = '';
    if (lottery.premiacoes && lottery.premiacoes.length > 0) {
        const mainPrize = lottery.premiacoes[0];

        if (mainPrize.ganhadores > 0 && mainPrize.valorPremio) {
            premiacoesHTML = `
                <div class="mt-4 p-4 bg-gradient-to-br from-green-50 to-emerald-50 rounded-lg border-2 border-green-200">
                    <div class="flex items-center gap-2 mb-3">
                        <span class="text-2xl">🏆</span>
                        <div class="text-sm font-bold text-gray-700">${mainPrize.descricao}</div>
                    </div>
                    <div class="flex items-center justify-between mb-2">
                        <span class="text-gray-600 text-sm">Ganhadores:</span>
                        <span class="font-bold text-lg text-ocean-blue">${mainPrize.ganhadores}</span>
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="text-gray-600 text-sm">Prêmio ${mainPrize.ganhadores === 1 ? 'total' : 'por ganhador'}:</span>
                        <span class="font-bold text-xl text-green-700">${formatCurrency(mainPrize.valorPremio)}</span>
                    </div>
                </div>
            `;
        }

        // Adicionar outras faixas de premiação
        if (lottery.premiacoes.length > 1) {
            const otherPrizes = lottery.premiacoes.slice(1, 4).filter(p => p.ganhadores > 0);

            if (otherPrizes.length > 0) {
                premiacoesHTML += `
                    <div class="mt-3 p-3 bg-gray-50 rounded-lg space-y-2">
                        <div class="text-xs font-semibold text-gray-500 mb-2">Outras Premiações:</div>
                        ${otherPrizes.map(prize => `
                            <div class="flex items-center justify-between text-sm py-2 border-b border-gray-200 last:border-0">
                                <div class="flex-1">
                                    <div class="font-medium text-gray-700">${prize.descricao}</div>
                                    <div class="text-xs text-gray-500">${prize.ganhadores} ganhador${prize.ganhadores !== 1 ? 'es' : ''}</div>
                                </div>
                                <div class="font-bold text-sky-blue text-right">${formatCurrency(prize.valorPremio)}</div>
                            </div>
                        `).join('')}
                    </div>
                `;
            }
        }
    }

    card.innerHTML = `
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-xl font-bold text-dark-navy">${lottery.lotteryName}</h3>
            ${statusBadge}
        </div>

        <div class="mb-4">
            <div class="text-sm text-gray-600 mb-1">Concurso ${lottery.concurso}</div>
            <div class="text-sm text-gray-600">${lottery.data}</div>
        </div>

        <div class="mb-6">
            <div class="text-sm font-semibold text-gray-700 mb-3">Números Sorteados:</div>
            <div class="flex flex-wrap gap-2">
                ${numbersHTML}
            </div>
        </div>

        ${premiacoesHTML}

        <div class="next-draw-card p-4 mt-4">
            <div class="text-sm font-semibold mb-2 opacity-90">Próximo Concurso:</div>
            <div class="flex justify-between items-center">
                <div>
                    <div class="text-xs opacity-90">Data</div>
                    <div class="font-bold">${nextDrawDate}</div>
                </div>
                <div class="text-right">
                    <div class="text-xs opacity-90">Prêmio Estimado</div>
                    <div class="font-bold text-lg">${nextDrawValue}</div>
                </div>
            </div>
        </div>
    `;

    return card;
}

function formatCurrency(value) {
    return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
        minimumFractionDigits: 2
    }).format(value);
}

function showError() {
    document.getElementById('loading').classList.add('hidden');
    document.getElementById('results').classList.add('hidden');
    document.getElementById('error').classList.remove('hidden');
}

function showOfflineBanner() {
    let banner = document.querySelector('.offline-banner');

    if (!banner) {
        banner = document.createElement('div');
        banner.className = 'offline-banner';
        banner.innerHTML = `
            <p class="text-sm font-medium">
                Você está offline. ${useSupabase ? 'Mostrando dados salvos.' : 'Mostrando resultados em cache.'}
            </p>
        `;
        document.body.appendChild(banner);
    }

    setTimeout(() => banner.classList.add('show'), 100);
}

function hideOfflineBanner() {
    const banner = document.querySelector('.offline-banner');
    if (banner) {
        banner.classList.remove('show');
    }
}

// Exportar para uso global
window.LOTTERIES = LOTTERIES;
window.lotteriesData = lotteriesData;
