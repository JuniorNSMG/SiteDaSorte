// Conferir Aposta - Verifica se seus números já ganharam alguma vez

// Configuração de cada loteria
const LOTERIAS_CONFIG = {
    megasena: {
        nome: 'Mega-Sena',
        cor: '#209869',
        min: 6,
        max: 15,
        maxNumero: 60,
        premios: [
            { acertos: 6, nome: 'Sena (6 números)' },
            { acertos: 5, nome: 'Quina (5 números)' },
            { acertos: 4, nome: 'Quadra (4 números)' }
        ]
    },
    lotofacil: {
        nome: 'Lotofácil',
        cor: '#930089',
        min: 15,
        max: 20,
        maxNumero: 25,
        premios: [
            { acertos: 15, nome: '15 pontos' },
            { acertos: 14, nome: '14 pontos' },
            { acertos: 13, nome: '13 pontos' },
            { acertos: 12, nome: '12 pontos' },
            { acertos: 11, nome: '11 pontos' }
        ]
    },
    quina: {
        nome: 'Quina',
        cor: '#260085',
        min: 5,
        max: 15,
        maxNumero: 80,
        premios: [
            { acertos: 5, nome: 'Quina (5 números)' },
            { acertos: 4, nome: 'Quadra (4 números)' },
            { acertos: 3, nome: 'Terno (3 números)' },
            { acertos: 2, nome: 'Duque (2 números)' }
        ]
    },
    lotomania: {
        nome: 'Lotomania',
        cor: '#f78100',
        min: 50,
        max: 50,
        maxNumero: 100,
        premios: [
            { acertos: 20, nome: '20 pontos' },
            { acertos: 19, nome: '19 pontos' },
            { acertos: 18, nome: '18 pontos' },
            { acertos: 17, nome: '17 pontos' },
            { acertos: 16, nome: '16 pontos' },
            { acertos: 0, nome: '0 pontos (nenhum acerto!)' }
        ]
    },
    timemania: {
        nome: 'Timemania',
        cor: '#00ff48',
        min: 10,
        max: 10,
        maxNumero: 80,
        premios: [
            { acertos: 7, nome: '7 números' },
            { acertos: 6, nome: '6 números' },
            { acertos: 5, nome: '5 números' },
            { acertos: 4, nome: '4 números' },
            { acertos: 3, nome: '3 números' }
        ]
    },
    duplasena: {
        nome: 'Dupla Sena',
        cor: '#a61324',
        min: 6,
        max: 15,
        maxNumero: 50,
        premios: [
            { acertos: 6, nome: 'Sena (6 números)' },
            { acertos: 5, nome: 'Quina (5 números)' },
            { acertos: 4, nome: 'Quadra (4 números)' },
            { acertos: 3, nome: 'Terno (3 números)' }
        ]
    },
    diadesorte: {
        nome: 'Dia de Sorte',
        cor: '#cb852b',
        min: 7,
        max: 15,
        maxNumero: 31,
        premios: [
            { acertos: 7, nome: '7 números' },
            { acertos: 6, nome: '6 números' },
            { acertos: 5, nome: '5 números' },
            { acertos: 4, nome: '4 números' }
        ]
    },
    supersete: {
        nome: 'Super Sete',
        cor: '#a8cf45',
        min: 7,
        max: 7,
        maxNumero: 9,
        premios: [
            { acertos: 7, nome: '7 colunas' },
            { acertos: 6, nome: '6 colunas' },
            { acertos: 5, nome: '5 colunas' },
            { acertos: 4, nome: '4 colunas' },
            { acertos: 3, nome: '3 colunas' }
        ]
    },
    maismilionaria: {
        nome: '+Milionária',
        cor: '#221e50',
        min: 6,
        max: 12,
        maxNumero: 50,
        trevos: true,
        maxTrevo: 6,
        premios: [
            { acertos: 6, trevos: 2, nome: '6 números + 2 trevos' },
            { acertos: 6, trevos: 1, nome: '6 números + 1 trevo' },
            { acertos: 6, trevos: 0, nome: '6 números + 0 trevos' },
            { acertos: 5, trevos: 2, nome: '5 números + 2 trevos' },
            { acertos: 5, trevos: 1, nome: '5 números + 1 trevo' },
            { acertos: 5, trevos: 0, nome: '5 números + 0 trevos' },
            { acertos: 4, trevos: 2, nome: '4 números + 2 trevos' },
            { acertos: 4, trevos: 1, nome: '4 números + 1 trevo' },
            { acertos: 4, trevos: 0, nome: '4 números + 0 trevos' }
        ]
    }
};

class ConferirAposta {
    constructor() {
        this.loteriaAtual = null;
        this.numeros = [];
        this.trevos = [];
        this.init();
    }

    init() {
        this.createModal();
        this.attachEventListeners();
    }

    createModal() {
        const modal = document.createElement('div');
        modal.id = 'conferirApostaModal';
        modal.className = 'hidden fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4';
        modal.innerHTML = `
            <div class="bg-white rounded-xl shadow-2xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
                <!-- Header -->
                <div class="bg-gradient-to-r from-ocean-blue to-sky-blue text-white p-6 sticky top-0 z-10">
                    <div class="flex items-center justify-between">
                        <div>
                            <h2 class="text-2xl font-bold mb-2">🎯 Conferir Minha Aposta</h2>
                            <p class="text-sm opacity-90">Digite seus números e veja se já ganhou alguma vez!</p>
                        </div>
                        <button id="fecharModal" class="text-white hover:text-gray-200 text-3xl leading-none">
                            &times;
                        </button>
                    </div>
                </div>

                <!-- Content -->
                <div class="p-6">
                    <!-- Seletor de Loteria -->
                    <div class="mb-6">
                        <label class="block text-gray-700 font-semibold mb-3">Escolha a Loteria:</label>
                        <div class="grid grid-cols-2 md:grid-cols-3 gap-3" id="seletorLoteria">
                            ${Object.entries(LOTERIAS_CONFIG).map(([id, config]) => `
                                <button
                                    data-loteria="${id}"
                                    class="loteria-btn p-4 rounded-lg border-2 border-gray-200 hover:border-sky-blue transition-all duration-200 text-center font-medium"
                                    style="color: ${config.cor}"
                                >
                                    ${config.nome}
                                </button>
                            `).join('')}
                        </div>
                    </div>

                    <!-- Área de Input de Números -->
                    <div id="areaNumeros" class="hidden">
                        <div class="bg-gray-50 rounded-lg p-6 mb-6">
                            <h3 class="font-bold text-lg mb-4" id="tituloNumeros">Digite seus números:</h3>
                            <p class="text-sm text-gray-600 mb-4" id="instrucoes"></p>

                            <!-- Grid de Números -->
                            <div id="gridNumeros" class="grid grid-cols-5 md:grid-cols-10 gap-2 mb-4"></div>

                            <!-- Trevos (+Milionária) -->
                            <div id="areaTrevos" class="hidden mt-6">
                                <h4 class="font-semibold text-gray-700 mb-3">Trevos (2 números de 1 a 6):</h4>
                                <div id="gridTrevos" class="grid grid-cols-6 gap-2 max-w-md"></div>
                            </div>

                            <!-- Números Selecionados -->
                            <div class="mt-6">
                                <div class="flex items-center justify-between mb-2">
                                    <span class="font-semibold text-gray-700">Números selecionados:</span>
                                    <button id="limparNumeros" class="text-sm text-red-500 hover:text-red-700">
                                        Limpar
                                    </button>
                                </div>
                                <div id="numerosSelecionados" class="min-h-[50px] bg-white rounded-lg p-4 border-2 border-gray-200 flex flex-wrap gap-2">
                                    <span class="text-gray-400 text-sm">Nenhum número selecionado</span>
                                </div>
                                <div id="trevosSelecionados" class="hidden mt-3 min-h-[40px] bg-white rounded-lg p-3 border-2 border-gray-200 flex flex-wrap gap-2">
                                    <span class="text-gray-400 text-sm">Nenhum trevo selecionado</span>
                                </div>
                            </div>
                        </div>

                        <!-- Botão Conferir -->
                        <button id="btnConferir" class="w-full bg-gradient-to-r from-ocean-blue to-sky-blue text-white py-4 rounded-lg font-bold text-lg hover:from-sky-blue hover:to-light-blue transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed">
                            🔍 Conferir Aposta
                        </button>
                    </div>

                    <!-- Resultados -->
                    <div id="resultados" class="hidden mt-6">
                        <div class="bg-gradient-to-br from-green-50 to-emerald-50 rounded-lg p-6 border-2 border-green-200">
                            <div id="conteudoResultados"></div>
                        </div>
                    </div>

                    <!-- Loading -->
                    <div id="loadingConferencia" class="hidden mt-6 text-center py-8">
                        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-ocean-blue mx-auto mb-4"></div>
                        <p class="text-gray-600">Verificando em todos os concursos...</p>
                    </div>
                </div>
            </div>
        `;
        document.body.appendChild(modal);
    }

    attachEventListeners() {
        // Abrir modal
        document.getElementById('btnConferirAposta')?.addEventListener('click', () => {
            this.abrirModal();
        });

        // Fechar modal
        document.getElementById('fecharModal')?.addEventListener('click', () => {
            this.fecharModal();
        });

        // Fechar ao clicar fora
        document.getElementById('conferirApostaModal')?.addEventListener('click', (e) => {
            if (e.target.id === 'conferirApostaModal') {
                this.fecharModal();
            }
        });

        // Seletor de loteria
        document.querySelectorAll('.loteria-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const loteriaId = e.target.dataset.loteria;
                this.selecionarLoteria(loteriaId);
            });
        });

        // Limpar números
        document.getElementById('limparNumeros')?.addEventListener('click', () => {
            this.limparSelecao();
        });

        // Botão conferir
        document.getElementById('btnConferir')?.addEventListener('click', () => {
            this.conferirAposta();
        });
    }

    abrirModal() {
        document.getElementById('conferirApostaModal').classList.remove('hidden');
        document.body.style.overflow = 'hidden';
    }

    fecharModal() {
        document.getElementById('conferirApostaModal').classList.add('hidden');
        document.body.style.overflow = 'auto';
        this.resetar();
    }

    selecionarLoteria(loteriaId) {
        this.loteriaAtual = loteriaId;
        this.numeros = [];
        this.trevos = [];

        const config = LOTERIAS_CONFIG[loteriaId];

        // Destacar botão selecionado
        document.querySelectorAll('.loteria-btn').forEach(btn => {
            if (btn.dataset.loteria === loteriaId) {
                btn.classList.add('border-sky-blue', 'bg-blue-50');
                btn.classList.remove('border-gray-200');
            } else {
                btn.classList.remove('border-sky-blue', 'bg-blue-50');
                btn.classList.add('border-gray-200');
            }
        });

        // Mostrar área de números
        document.getElementById('areaNumeros').classList.remove('hidden');

        // Atualizar instruções
        const instrucoes = config.min === config.max
            ? `Selecione exatamente ${config.min} números`
            : `Selecione de ${config.min} a ${config.max} números`;
        document.getElementById('instrucoes').textContent = instrucoes;

        // Criar grid de números
        this.criarGridNumeros(config);

        // Trevos para +Milionária
        if (config.trevos) {
            document.getElementById('areaTrevos').classList.remove('hidden');
            this.criarGridTrevos(config);
        } else {
            document.getElementById('areaTrevos').classList.add('hidden');
        }

        // Resetar exibição
        this.atualizarNumerosSelecionados();
        document.getElementById('resultados').classList.add('hidden');
    }

    criarGridNumeros(config) {
        const grid = document.getElementById('gridNumeros');
        grid.innerHTML = '';

        for (let i = 1; i <= config.maxNumero; i++) {
            const btn = document.createElement('button');
            btn.textContent = i.toString().padStart(2, '0');
            btn.className = 'numero-btn w-full aspect-square rounded-lg border-2 border-gray-300 hover:border-sky-blue hover:bg-blue-50 transition-all duration-150 font-semibold';
            btn.dataset.numero = i;

            btn.addEventListener('click', () => {
                this.toggleNumero(i, btn);
            });

            grid.appendChild(btn);
        }
    }

    criarGridTrevos(config) {
        const grid = document.getElementById('gridTrevos');
        grid.innerHTML = '';

        for (let i = 1; i <= config.maxTrevo; i++) {
            const btn = document.createElement('button');
            btn.textContent = i;
            btn.className = 'trevo-btn w-full aspect-square rounded-full border-2 border-gray-300 hover:border-green-500 hover:bg-green-50 transition-all duration-150 font-semibold';
            btn.dataset.trevo = i;

            btn.addEventListener('click', () => {
                this.toggleTrevo(i, btn);
            });

            grid.appendChild(btn);
        }
    }

    toggleNumero(numero, btn) {
        const config = LOTERIAS_CONFIG[this.loteriaAtual];
        const index = this.numeros.indexOf(numero);

        if (index > -1) {
            // Remover
            this.numeros.splice(index, 1);
            btn.classList.remove('bg-sky-blue', 'text-white', 'border-sky-blue');
            btn.classList.add('border-gray-300');
        } else {
            // Adicionar (se não exceder máximo)
            if (this.numeros.length < config.max) {
                this.numeros.push(numero);
                this.numeros.sort((a, b) => a - b);
                btn.classList.add('bg-sky-blue', 'text-white', 'border-sky-blue');
                btn.classList.remove('border-gray-300');
            } else {
                alert(`Você só pode selecionar até ${config.max} números!`);
            }
        }

        this.atualizarNumerosSelecionados();
    }

    toggleTrevo(trevo, btn) {
        const index = this.trevos.indexOf(trevo);

        if (index > -1) {
            // Remover
            this.trevos.splice(index, 1);
            btn.classList.remove('bg-green-500', 'text-white', 'border-green-500');
            btn.classList.add('border-gray-300');
        } else {
            // Adicionar (máximo 2)
            if (this.trevos.length < 2) {
                this.trevos.push(trevo);
                this.trevos.sort((a, b) => a - b);
                btn.classList.add('bg-green-500', 'text-white', 'border-green-500');
                btn.classList.remove('border-gray-300');
            } else {
                alert('Você só pode selecionar 2 trevos!');
            }
        }

        this.atualizarNumerosSelecionados();
    }

    atualizarNumerosSelecionados() {
        const config = LOTERIAS_CONFIG[this.loteriaAtual];
        const containerNumeros = document.getElementById('numerosSelecionados');
        const containerTrevos = document.getElementById('trevosSelecionados');

        // Atualizar números
        if (this.numeros.length === 0) {
            containerNumeros.innerHTML = '<span class="text-gray-400 text-sm">Nenhum número selecionado</span>';
        } else {
            containerNumeros.innerHTML = this.numeros.map(n =>
                `<span class="bg-sky-blue text-white px-3 py-1 rounded-full font-semibold">${n.toString().padStart(2, '0')}</span>`
            ).join('');
        }

        // Atualizar trevos
        if (config.trevos) {
            containerTrevos.classList.remove('hidden');
            if (this.trevos.length === 0) {
                containerTrevos.innerHTML = '<span class="text-gray-400 text-sm">Nenhum trevo selecionado</span>';
            } else {
                containerTrevos.innerHTML = this.trevos.map(t =>
                    `<span class="bg-green-500 text-white px-3 py-1 rounded-full font-semibold">🍀 ${t}</span>`
                ).join('');
            }
        }

        // Habilitar/desabilitar botão conferir
        const btnConferir = document.getElementById('btnConferir');
        const numerosValidos = this.numeros.length >= config.min && this.numeros.length <= config.max;
        const trevosValidos = !config.trevos || this.trevos.length === 2;

        btnConferir.disabled = !(numerosValidos && trevosValidos);
    }

    limparSelecao() {
        this.numeros = [];
        this.trevos = [];

        // Resetar botões
        document.querySelectorAll('.numero-btn').forEach(btn => {
            btn.classList.remove('bg-sky-blue', 'text-white', 'border-sky-blue');
            btn.classList.add('border-gray-300');
        });

        document.querySelectorAll('.trevo-btn').forEach(btn => {
            btn.classList.remove('bg-green-500', 'text-white', 'border-green-500');
            btn.classList.add('border-gray-300');
        });

        this.atualizarNumerosSelecionados();
    }

    async conferirAposta() {
        const config = LOTERIAS_CONFIG[this.loteriaAtual];

        // Verificar se Supabase está configurado
        if (!window.SUPABASE_CONFIG || !window.SUPABASE_CONFIG.url) {
            alert('⚠️ Supabase não configurado!\n\nPara usar esta funcionalidade:\n1. Abra o site pelo GitHub Pages:\n   https://juniorNSMG.github.io/SiteDaSorte/\n\nOu configure o Supabase localmente.');
            return;
        }

        // Mostrar loading
        document.getElementById('loadingConferencia').classList.remove('hidden');
        document.getElementById('resultados').classList.add('hidden');

        try {
            // Buscar todos os concursos desta loteria no Supabase
            const response = await fetch(
                `${window.SUPABASE_CONFIG.url}/rest/v1/loterias?tipo_loteria=eq.${this.loteriaAtual}&select=numero_concurso,dezenas,data_sorteio&order=numero_concurso.desc`,
                {
                    headers: {
                        'apikey': window.SUPABASE_CONFIG.anonKey,
                        'Authorization': `Bearer ${window.SUPABASE_CONFIG.anonKey}`
                    }
                }
            );

            if (!response.ok) throw new Error('Erro ao buscar concursos');

            const concursos = await response.json();

            // Verificar acertos em cada concurso
            const resultados = this.verificarAcertos(concursos, config);

            // Exibir resultados
            this.exibirResultados(resultados, concursos.length);

        } catch (error) {
            console.error('Erro ao conferir aposta:', error);
            alert('Erro ao conferir aposta. Tente novamente.');
        } finally {
            document.getElementById('loadingConferencia').classList.add('hidden');
        }
    }

    verificarAcertos(concursos, config) {
        const premiacoes = {};

        concursos.forEach(concurso => {
            const dezenasConcurso = concurso.dezenas.map(d => parseInt(d));

            // Contar acertos nos números
            const acertos = this.numeros.filter(n => dezenasConcurso.includes(n)).length;

            // Para +Milionária, verificar trevos também
            let acertosTrevos = 0;
            if (config.trevos && dezenasConcurso.length === 8) {
                // Últimos 2 números são os trevos
                const trevosConcurso = dezenasConcurso.slice(6, 8);
                acertosTrevos = this.trevos.filter(t => trevosConcurso.includes(t)).length;
            }

            // Verificar se ganhou algum prêmio
            config.premios.forEach(premio => {
                let ganhou = false;

                if (config.trevos) {
                    // +Milionária considera números E trevos
                    ganhou = acertos === premio.acertos && acertosTrevos === premio.trevos;
                } else {
                    ganhou = acertos === premio.acertos;
                }

                if (ganhou) {
                    if (!premiacoes[premio.nome]) {
                        premiacoes[premio.nome] = [];
                    }
                    premiacoes[premio.nome].push({
                        concurso: concurso.numero_concurso,
                        data: concurso.data_sorteio,
                        dezenas: concurso.dezenas,
                        acertos,
                        acertosTrevos
                    });
                }
            });
        });

        return premiacoes;
    }

    exibirResultados(premiacoes, totalConcursos) {
        const container = document.getElementById('conteudoResultados');
        const config = LOTERIAS_CONFIG[this.loteriaAtual];

        const totalPremios = Object.values(premiacoes).reduce((sum, arr) => sum + arr.length, 0);

        if (totalPremios === 0) {
            container.innerHTML = `
                <div class="text-center py-6">
                    <div class="text-6xl mb-4">😔</div>
                    <h3 class="text-xl font-bold text-gray-800 mb-2">Nenhum Prêmio Encontrado</h3>
                    <p class="text-gray-600">
                        Estes números não ganharam nenhum prêmio em ${totalConcursos.toLocaleString('pt-BR')} concursos verificados.
                    </p>
                    <p class="text-sm text-gray-500 mt-4">
                        Mas não desanime! A sorte pode estar no próximo sorteio! 🍀
                    </p>
                </div>
            `;
        } else {
            const html = `
                <div class="text-center mb-6">
                    <div class="text-6xl mb-4">🎉</div>
                    <h3 class="text-2xl font-bold text-green-800 mb-2">Parabéns!</h3>
                    <p class="text-gray-700">
                        Estes números <strong>JÁ GANHARAM ${totalPremios}x</strong> em ${totalConcursos.toLocaleString('pt-BR')} concursos!
                    </p>
                </div>

                <div class="space-y-4">
                    ${Object.entries(premiacoes).map(([premio, ocorrencias]) => `
                        <div class="bg-white rounded-lg p-4 border-2 border-green-300">
                            <div class="flex items-center justify-between mb-3">
                                <h4 class="font-bold text-lg" style="color: ${config.cor}">
                                    🏆 ${premio}
                                </h4>
                                <span class="bg-green-500 text-white px-3 py-1 rounded-full text-sm font-bold">
                                    ${ocorrencias.length}x
                                </span>
                            </div>
                            <div class="space-y-2">
                                ${ocorrencias.slice(0, 5).map(o => `
                                    <div class="text-sm bg-gray-50 p-3 rounded">
                                        <div class="flex items-center justify-between">
                                            <span class="font-semibold">Concurso ${o.concurso}</span>
                                            <span class="text-gray-600">${new Date(o.data).toLocaleDateString('pt-BR')}</span>
                                        </div>
                                        <div class="mt-2 flex flex-wrap gap-1">
                                            ${o.dezenas.map((d, i) => {
                                                const isNumero = i < (config.trevos ? 6 : o.dezenas.length);
                                                const acertou = isNumero
                                                    ? this.numeros.includes(parseInt(d))
                                                    : this.trevos.includes(parseInt(d));
                                                const classe = acertou
                                                    ? (isNumero ? 'bg-sky-blue text-white' : 'bg-green-500 text-white')
                                                    : 'bg-gray-200 text-gray-600';
                                                return `<span class="${classe} px-2 py-1 rounded text-xs font-semibold">${d}</span>`;
                                            }).join('')}
                                        </div>
                                    </div>
                                `).join('')}
                                ${ocorrencias.length > 5 ? `
                                    <div class="text-center text-sm text-gray-500 mt-2">
                                        ... e mais ${ocorrencias.length - 5} ocorrência(s)
                                    </div>
                                ` : ''}
                            </div>
                        </div>
                    `).join('')}
                </div>
            `;
            container.innerHTML = html;
        }

        document.getElementById('resultados').classList.remove('hidden');
        document.getElementById('resultados').scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }

    resetar() {
        this.loteriaAtual = null;
        this.numeros = [];
        this.trevos = [];

        document.querySelectorAll('.loteria-btn').forEach(btn => {
            btn.classList.remove('border-sky-blue', 'bg-blue-50');
            btn.classList.add('border-gray-200');
        });

        document.getElementById('areaNumeros').classList.add('hidden');
        document.getElementById('resultados').classList.add('hidden');
    }
}

// Inicializar quando o DOM estiver pronto
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        new ConferirAposta();
    });
} else {
    new ConferirAposta();
}
