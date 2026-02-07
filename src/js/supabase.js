// Integração com Supabase - Site da Sorte

// Cliente Supabase
let supabaseClient = null;
let supabaseReady = false;

// Inicializar Supabase
async function initSupabase() {
    try {
        // Verificar se configuração existe
        if (typeof SUPABASE_CONFIG === 'undefined') {
            console.warn('⚠️ Supabase não configurado. Usando apenas API externa.');
            return false;
        }

        // Carregar biblioteca do Supabase via CDN
        if (typeof supabase === 'undefined') {
            await loadSupabaseLibrary();
        }

        // Criar cliente
        supabaseClient = supabase.createClient(
            SUPABASE_CONFIG.url,
            SUPABASE_CONFIG.anonKey,
            SUPABASE_CONFIG.options || {}
        );

        supabaseReady = true;
        console.log('✅ Supabase inicializado com sucesso');
        return true;
    } catch (error) {
        console.error('❌ Erro ao inicializar Supabase:', error);
        return false;
    }
}

// Carregar biblioteca do Supabase
function loadSupabaseLibrary() {
    return new Promise((resolve, reject) => {
        const script = document.createElement('script');
        script.src = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2';
        script.onload = () => resolve();
        script.onerror = () => reject(new Error('Falha ao carregar Supabase'));
        document.head.appendChild(script);
    });
}

// Buscar último resultado de uma loteria
async function getUltimoResultado(tipoLoteria) {
    if (!supabaseReady) return null;

    try {
        const { data, error } = await supabaseClient
            .from('loterias')
            .select('*')
            .eq('tipo_loteria', tipoLoteria)
            .order('numero_concurso', { ascending: false })
            .limit(1)
            .single();

        if (error) throw error;
        return data;
    } catch (error) {
        console.error(`Erro ao buscar ${tipoLoteria}:`, error);
        return null;
    }
}

// Buscar todos os últimos resultados
async function getTodosUltimosResultados() {
    if (!supabaseReady) return null;

    try {
        const { data, error } = await supabaseClient
            .from('ultimos_resultados')
            .select('*')
            .order('numero_concurso', { ascending: false });

        if (error) throw error;
        return data;
    } catch (error) {
        console.error('Erro ao buscar últimos resultados:', error);
        return null;
    }
}

// Buscar histórico de uma loteria
async function getHistoricoLoteria(tipoLoteria, limit = 10) {
    if (!supabaseReady) return null;

    try {
        const { data, error } = await supabaseClient
            .from('loterias')
            .select('*')
            .eq('tipo_loteria', tipoLoteria)
            .order('numero_concurso', { ascending: false })
            .limit(limit);

        if (error) throw error;
        return data;
    } catch (error) {
        console.error(`Erro ao buscar histórico de ${tipoLoteria}:`, error);
        return null;
    }
}

// Buscar loterias acumuladas
async function getLoteriasAcumuladas() {
    if (!supabaseReady) return null;

    try {
        const { data, error } = await supabaseClient
            .from('loterias_acumuladas')
            .select('*')
            .order('valor_estimado_proximo', { ascending: false });

        if (error) throw error;
        return data;
    } catch (error) {
        console.error('Erro ao buscar loterias acumuladas:', error);
        return null;
    }
}

// Salvar resultado no Supabase
async function salvarResultado(tipoLoteria, dadosAPI) {
    if (!supabaseReady) {
        console.log('Supabase não disponível, pulando salvamento');
        return false;
    }

    try {
        const loteria = {
            tipo_loteria: tipoLoteria,
            numero_concurso: dadosAPI.concurso,
            data_sorteio: parseDate(dadosAPI.data),
            dezenas: dadosAPI.dezenas,
            acumulou: dadosAPI.acumulou,
            valor_estimado_proximo: dadosAPI.valorEstimadoProximoConcurso,
            data_proximo_concurso: parseDate(dadosAPI.dataProximoConcurso),
            premiacoes: dadosAPI.premiacoes,
            dados_completos: dadosAPI
        };

        const { data, error } = await supabaseClient
            .from('loterias')
            .upsert(loteria, {
                onConflict: 'tipo_loteria,numero_concurso',
                returning: 'minimal'
            });

        if (error) throw error;

        // Registrar log de sucesso
        await registrarSyncLog(tipoLoteria, dadosAPI.concurso, 'success', 'Salvo com sucesso');

        console.log(`✅ ${tipoLoteria} concurso ${dadosAPI.concurso} salvo no Supabase`);
        return true;
    } catch (error) {
        console.error(`Erro ao salvar ${tipoLoteria}:`, error);

        // Registrar log de erro
        await registrarSyncLog(
            tipoLoteria,
            dadosAPI.concurso,
            'error',
            error.message
        );

        return false;
    }
}

// Registrar log de sincronização
async function registrarSyncLog(tipoLoteria, numeroConcurso, status, mensagem) {
    if (!supabaseReady) return;

    try {
        await supabaseClient
            .from('sync_log')
            .insert({
                tipo_loteria: tipoLoteria,
                numero_concurso: numeroConcurso,
                status: status,
                mensagem: mensagem
            });
    } catch (error) {
        console.error('Erro ao registrar log:', error);
    }
}

// Verificar se concurso já existe
async function concursoExiste(tipoLoteria, numeroConcurso) {
    if (!supabaseReady) return false;

    try {
        const { data, error } = await supabaseClient
            .from('loterias')
            .select('id')
            .eq('tipo_loteria', tipoLoteria)
            .eq('numero_concurso', numeroConcurso)
            .single();

        return !error && data !== null;
    } catch (error) {
        return false;
    }
}

// Converter data brasileira para formato SQL
function parseDate(dataBR) {
    if (!dataBR) return null;

    // Formato esperado: DD/MM/YYYY
    const partes = dataBR.split('/');
    if (partes.length !== 3) return null;

    return `${partes[2]}-${partes[1]}-${partes[0]}`;
}

// Formatar data SQL para brasileira
function formatDateBR(dateSQL) {
    if (!dateSQL) return '';

    const date = new Date(dateSQL);
    const dia = String(date.getDate()).padStart(2, '0');
    const mes = String(date.getMonth() + 1).padStart(2, '0');
    const ano = date.getFullYear();

    return `${dia}/${mes}/${ano}`;
}

// Estatísticas de uso do Supabase
async function getEstatisticas() {
    if (!supabaseReady) return null;

    try {
        const { data, error } = await supabaseClient
            .from('loterias')
            .select('tipo_loteria, numero_concurso', { count: 'exact' });

        if (error) throw error;

        // Agrupar por tipo
        const stats = {};
        data.forEach(item => {
            if (!stats[item.tipo_loteria]) {
                stats[item.tipo_loteria] = 0;
            }
            stats[item.tipo_loteria]++;
        });

        return {
            total: data.length,
            porTipo: stats
        };
    } catch (error) {
        console.error('Erro ao buscar estatísticas:', error);
        return null;
    }
}

// Exportar funções
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        initSupabase,
        getUltimoResultado,
        getTodosUltimosResultados,
        getHistoricoLoteria,
        getLoteriasAcumuladas,
        salvarResultado,
        concursoExiste,
        getEstatisticas
    };
}
