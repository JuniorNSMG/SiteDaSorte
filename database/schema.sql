-- Schema do Banco de Dados - Site da Sorte
-- Supabase PostgreSQL Database Schema

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabela principal de loterias
CREATE TABLE IF NOT EXISTS loterias (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tipo_loteria TEXT NOT NULL,
    numero_concurso INTEGER NOT NULL,
    data_sorteio DATE NOT NULL,
    dezenas TEXT[] NOT NULL,
    acumulou BOOLEAN NOT NULL DEFAULT false,
    valor_estimado_proximo NUMERIC(15, 2),
    data_proximo_concurso DATE,
    premiacoes JSONB,
    dados_completos JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraint de unicidade
    CONSTRAINT unique_concurso UNIQUE (tipo_loteria, numero_concurso)
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_loterias_tipo
    ON loterias(tipo_loteria);

CREATE INDEX IF NOT EXISTS idx_loterias_data_sorteio
    ON loterias(data_sorteio DESC);

CREATE INDEX IF NOT EXISTS idx_loterias_tipo_data
    ON loterias(tipo_loteria, data_sorteio DESC);

CREATE INDEX IF NOT EXISTS idx_loterias_numero_concurso
    ON loterias(tipo_loteria, numero_concurso DESC);

CREATE INDEX IF NOT EXISTS idx_loterias_acumulou
    ON loterias(acumulou)
    WHERE acumulou = true;

-- Tabela de log de sincronização
CREATE TABLE IF NOT EXISTS sync_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tipo_loteria TEXT NOT NULL,
    numero_concurso INTEGER NOT NULL,
    status TEXT NOT NULL, -- 'success', 'error', 'skipped'
    mensagem TEXT,
    dados_api JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sync_log_created
    ON sync_log(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_sync_log_status
    ON sync_log(status);

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para updated_at
DROP TRIGGER IF EXISTS update_loterias_updated_at ON loterias;
CREATE TRIGGER update_loterias_updated_at
    BEFORE UPDATE ON loterias
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- View para últimos resultados de cada loteria
CREATE OR REPLACE VIEW ultimos_resultados AS
SELECT DISTINCT ON (tipo_loteria)
    id,
    tipo_loteria,
    numero_concurso,
    data_sorteio,
    dezenas,
    acumulou,
    valor_estimado_proximo,
    data_proximo_concurso,
    premiacoes,
    created_at
FROM loterias
ORDER BY tipo_loteria, numero_concurso DESC;

-- View para loterias acumuladas
CREATE OR REPLACE VIEW loterias_acumuladas AS
SELECT
    tipo_loteria,
    numero_concurso,
    data_sorteio,
    valor_estimado_proximo,
    data_proximo_concurso
FROM ultimos_resultados
WHERE acumulou = true
ORDER BY valor_estimado_proximo DESC NULLS LAST;

-- Função para buscar último concurso de uma loteria
CREATE OR REPLACE FUNCTION get_ultimo_concurso(p_tipo_loteria TEXT)
RETURNS TABLE (
    numero_concurso INTEGER,
    data_sorteio DATE,
    dezenas TEXT[],
    acumulou BOOLEAN,
    valor_estimado_proximo NUMERIC,
    data_proximo_concurso DATE,
    premiacoes JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.numero_concurso,
        l.data_sorteio,
        l.dezenas,
        l.acumulou,
        l.valor_estimado_proximo,
        l.data_proximo_concurso,
        l.premiacoes
    FROM loterias l
    WHERE l.tipo_loteria = p_tipo_loteria
    ORDER BY l.numero_concurso DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Função para inserir ou atualizar loteria
CREATE OR REPLACE FUNCTION upsert_loteria(
    p_tipo_loteria TEXT,
    p_numero_concurso INTEGER,
    p_data_sorteio DATE,
    p_dezenas TEXT[],
    p_acumulou BOOLEAN,
    p_valor_estimado_proximo NUMERIC,
    p_data_proximo_concurso DATE,
    p_premiacoes JSONB,
    p_dados_completos JSONB
)
RETURNS UUID AS $$
DECLARE
    v_id UUID;
BEGIN
    INSERT INTO loterias (
        tipo_loteria,
        numero_concurso,
        data_sorteio,
        dezenas,
        acumulou,
        valor_estimado_proximo,
        data_proximo_concurso,
        premiacoes,
        dados_completos
    ) VALUES (
        p_tipo_loteria,
        p_numero_concurso,
        p_data_sorteio,
        p_dezenas,
        p_acumulou,
        p_valor_estimado_proximo,
        p_data_proximo_concurso,
        p_premiacoes,
        p_dados_completos
    )
    ON CONFLICT (tipo_loteria, numero_concurso)
    DO UPDATE SET
        data_sorteio = EXCLUDED.data_sorteio,
        dezenas = EXCLUDED.dezenas,
        acumulou = EXCLUDED.acumulou,
        valor_estimado_proximo = EXCLUDED.valor_estimado_proximo,
        data_proximo_concurso = EXCLUDED.data_proximo_concurso,
        premiacoes = EXCLUDED.premiacoes,
        dados_completos = EXCLUDED.dados_completos,
        updated_at = NOW()
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- Row Level Security (RLS)
ALTER TABLE loterias ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_log ENABLE ROW LEVEL SECURITY;

-- Política: Todos podem ler
CREATE POLICY "Loterias são públicas para leitura"
    ON loterias FOR SELECT
    TO anon, authenticated
    USING (true);

-- Política: Apenas autenticados podem inserir/atualizar
CREATE POLICY "Apenas autenticados podem modificar"
    ON loterias FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Política para sync_log
CREATE POLICY "Sync log público para leitura"
    ON sync_log FOR SELECT
    TO anon, authenticated
    USING (true);

CREATE POLICY "Apenas autenticados podem criar logs"
    ON sync_log FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Comentários nas tabelas
COMMENT ON TABLE loterias IS 'Armazena histórico completo de todos os sorteios das loterias';
COMMENT ON TABLE sync_log IS 'Log de sincronizações com a API externa';
COMMENT ON COLUMN loterias.tipo_loteria IS 'Tipo da loteria: megasena, lotofacil, quina, etc';
COMMENT ON COLUMN loterias.numero_concurso IS 'Número do concurso';
COMMENT ON COLUMN loterias.dezenas IS 'Array com números sorteados';
COMMENT ON COLUMN loterias.premiacoes IS 'JSON com detalhes das premiações';
COMMENT ON COLUMN loterias.dados_completos IS 'JSON com todos os dados originais da API';
