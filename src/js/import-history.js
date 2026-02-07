// Importador de Histórico - Site da Sorte
// Importa histórico completo de todas as loterias para o Supabase

// Configurações de importação
const IMPORT_CONFIG = {
    // Quantos concursos importar por loteria (0 = todos)
    maxConcursosPorLoteria: 100, // Começar com 100 últimos

    // Delay entre requisições (ms) para não sobrecarregar API
    delayEntreRequisicoes: 1000, // 1 segundo

    // Concursos por batch (salva no Supabase a cada N concursos)
    batchSize: 10
};

let importRunning = false;
let importStats = {
    total: 0,
    sucesso: 0,
    erro: 0,
    pulado: 0
};

// Iniciar importação de histórico
async function startHistoricImport() {
    if (importRunning) {
        console.log('⚠️ Importação já está em execução');
        return;
    }

    if (!supabaseReady) {
        console.error('❌ Supabase não está inicializado');
        alert('Configure o Supabase primeiro!');
        return;
    }

    importRunning = true;
    importStats = { total: 0, sucesso: 0, erro: 0, pulado: 0 };

    console.log('🚀 Iniciando importação de histórico...');
    console.log(`📊 Importando últimos ${IMPORT_CONFIG.maxConcursosPorLoteria} concursos por loteria`);

    showImportProgress('Iniciando importação...', 0);

    for (const lottery of LOTTERIES) {
        if (!importRunning) {
            console.log('⏸️ Importação cancelada');
            break;
        }

        console.log(`\n📥 Importando histórico de ${lottery.name}...`);
        await importLotteryHistory(lottery);
    }

    importRunning = false;

    console.log('\n✅ Importação concluída!');
    console.log(`📊 Estatísticas:`);
    console.log(`   Total processado: ${importStats.total}`);
    console.log(`   ✅ Sucesso: ${importStats.sucesso}`);
    console.log(`   ⏭️ Pulados (já existem): ${importStats.pulado}`);
    console.log(`   ❌ Erros: ${importStats.erro}`);

    showImportProgress('Importação concluída!', 100);

    // Recarregar dados atualizados
    setTimeout(() => {
        location.reload();
    }, 2000);
}

// Importar histórico de uma loteria específica
async function importLotteryHistory(lottery) {
    try {
        // Buscar último concurso
        const latestResponse = await fetch(`${API_BASE_URL}/${lottery.id}/latest`);
        if (!latestResponse.ok) {
            console.error(`❌ Erro ao buscar último concurso de ${lottery.name}`);
            return;
        }

        const latestData = await latestResponse.json();
        const ultimoConcurso = latestData.concurso;

        console.log(`   Último concurso: ${ultimoConcurso}`);

        // Calcular range de importação
        const maxConcursos = IMPORT_CONFIG.maxConcursosPorLoteria || ultimoConcurso;
        const primeiroConcurso = Math.max(1, ultimoConcurso - maxConcursos + 1);

        console.log(`   Importando do concurso ${primeiroConcurso} ao ${ultimoConcurso}`);

        // Importar do mais recente para o mais antigo
        for (let concurso = ultimoConcurso; concurso >= primeiroConcurso; concurso--) {
            if (!importRunning) break;

            const progress = ((ultimoConcurso - concurso + 1) / maxConcursos) * 100;
            showImportProgress(
                `Importando ${lottery.name}: Concurso ${concurso}/${ultimoConcurso}`,
                progress
            );

            const result = await importConcurso(lottery.id, concurso);

            importStats.total++;
            if (result === 'success') importStats.sucesso++;
            else if (result === 'skipped') importStats.pulado++;
            else importStats.erro++;

            // Delay entre requisições
            await sleep(IMPORT_CONFIG.delayEntreRequisicoes);
        }

        console.log(`   ✅ ${lottery.name} concluída`);

    } catch (error) {
        console.error(`❌ Erro ao importar ${lottery.name}:`, error);
    }
}

// Importar um concurso específico
async function importConcurso(lotteryId, numeroConcurso) {
    try {
        // Verificar se já existe
        const existe = await concursoExiste(lotteryId, numeroConcurso);
        if (existe) {
            console.log(`   ⏭️ Concurso ${numeroConcurso} já existe, pulando`);
            return 'skipped';
        }

        // Buscar dados da API
        const response = await fetch(`${API_BASE_URL}/${lotteryId}/${numeroConcurso}`);

        if (!response.ok) {
            if (response.status === 404) {
                console.log(`   ⏭️ Concurso ${numeroConcurso} não existe na API`);
                return 'not_found';
            }
            throw new Error(`HTTP ${response.status}`);
        }

        const data = await response.json();

        // Salvar no Supabase
        const salvou = await salvarResultado(lotteryId, data);

        if (salvou) {
            console.log(`   ✅ Concurso ${numeroConcurso} importado`);
            return 'success';
        } else {
            console.error(`   ❌ Erro ao salvar concurso ${numeroConcurso}`);
            return 'error';
        }

    } catch (error) {
        console.error(`   ❌ Erro no concurso ${numeroConcurso}:`, error.message);
        return 'error';
    }
}

// Parar importação
function stopImport() {
    importRunning = false;
    console.log('⏸️ Parando importação...');
}

// Mostrar progresso da importação
function showImportProgress(message, percent) {
    let progressBar = document.getElementById('importProgress');

    if (!progressBar) {
        // Criar barra de progresso
        progressBar = document.createElement('div');
        progressBar.id = 'importProgress';
        progressBar.style.cssText = `
            position: fixed;
            top: 80px;
            left: 50%;
            transform: translateX(-50%);
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
            z-index: 9999;
            min-width: 400px;
            max-width: 90%;
        `;
        progressBar.innerHTML = `
            <div style="margin-bottom: 10px; font-weight: 600; color: #1E293D;">
                Importando Histórico
            </div>
            <div id="importMessage" style="margin-bottom: 10px; font-size: 14px; color: #666;">
            </div>
            <div style="background: #E8F1F2; height: 20px; border-radius: 10px; overflow: hidden;">
                <div id="importBar" style="background: linear-gradient(90deg, #1B98E0, #247BA0); height: 100%; width: 0%; transition: width 0.3s;"></div>
            </div>
            <div style="margin-top: 10px; font-size: 12px; color: #666;">
                <span id="importPercent">0%</span>
                <button onclick="stopImport()" style="float: right; background: #374151; color: white; border: none; padding: 5px 15px; border-radius: 5px; cursor: pointer;">
                    Cancelar
                </button>
            </div>
        `;
        document.body.appendChild(progressBar);
    }

    const messageEl = document.getElementById('importMessage');
    const barEl = document.getElementById('importBar');
    const percentEl = document.getElementById('importPercent');

    if (messageEl) messageEl.textContent = message;
    if (barEl) barEl.style.width = `${percent}%`;
    if (percentEl) percentEl.textContent = `${Math.round(percent)}%`;

    // Remover após conclusão
    if (percent >= 100 && !importRunning) {
        setTimeout(() => {
            if (progressBar && progressBar.parentNode) {
                progressBar.remove();
            }
        }, 3000);
    }
}

// Exportar funções
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        startHistoricImport,
        stopImport,
        importLotteryHistory,
        importConcurso
    };
}

// Adicionar ao escopo global
window.startHistoricImport = startHistoricImport;
window.stopImport = stopImport;
