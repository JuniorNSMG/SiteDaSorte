// Site da Sorte - Main Application

const API_BASE_URL = 'https://loteriascaixa-api.herokuapp.com/api';

// Lottery configurations
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

// State management
let lotteriesData = [];
let isOnline = navigator.onLine;

// Initialize app
document.addEventListener('DOMContentLoaded', () => {
    initApp();
    setupEventListeners();
    checkOnlineStatus();
});

async function initApp() {
    try {
        await fetchAllLotteries();
        renderLotteries();
    } catch (error) {
        console.error('Error initializing app:', error);
        showError();
    }
}

function setupEventListeners() {
    // Online/Offline events
    window.addEventListener('online', () => {
        isOnline = true;
        hideOfflineBanner();
        initApp();
    });

    window.addEventListener('offline', () => {
        isOnline = false;
        showOfflineBanner();
    });
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

    // Sort by contest number (most recent first)
    lotteriesData.sort((a, b) => b.concurso - a.concurso);

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
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        return { ...data, lotteryName: name, lotteryColor: color };
    } catch (error) {
        console.error(`Error fetching ${name}:`, error);
        return null;
    }
}

function renderLotteries() {
    const resultsContainer = document.getElementById('results');
    resultsContainer.innerHTML = '';

    // Add header
    const header = document.createElement('div');
    header.className = 'mb-8 text-center';
    header.innerHTML = `
        <h2 class="text-2xl md:text-3xl font-bold text-dark-navy mb-2">
            Últimos Resultados
        </h2>
        <p class="text-gray-600">
            Confira os resultados mais recentes das loterias da CAIXA
        </p>
    `;
    resultsContainer.appendChild(header);

    // Create lottery grid
    const grid = document.createElement('div');
    grid.className = 'lottery-grid';

    lotteriesData.forEach((lottery, index) => {
        const card = createLotteryCard(lottery, index);
        grid.appendChild(card);
    });

    resultsContainer.appendChild(grid);
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

    const hasWinner = !lottery.acumulou;
    const statusBadge = lottery.acumulou
        ? '<span class="status-accumulated">ACUMULOU</span>'
        : '<span class="status-has-winner">TEM GANHADOR</span>';

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

        ${lottery.premiacoes && lottery.premiacoes.length > 0 ? `
            <div class="mb-6 space-y-2">
                ${lottery.premiacoes.slice(0, 3).map(prize => `
                    <div class="flex justify-between items-center text-sm">
                        <span class="text-gray-600">${prize.descricao}:</span>
                        <span class="font-semibold text-gray-800">
                            ${prize.ganhadores} ganhador${prize.ganhadores !== 1 ? 'es' : ''}
                        </span>
                    </div>
                `).join('')}
            </div>
        ` : ''}

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
                Você está offline. Mostrando resultados salvos.
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

// Auto-refresh every 5 minutes if online
setInterval(() => {
    if (isOnline) {
        initApp();
    }
}, 5 * 60 * 1000);
