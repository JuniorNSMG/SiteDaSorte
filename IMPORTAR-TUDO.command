#!/bin/bash

# Importador COMPLETO de Histórico - Site da Sorte
# Versão otimizada para importar milhares de concursos

cd "$(dirname "$0")"

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configurações
SUPABASE_URL="https://kbczmmgfkbnuyfwrlmtu.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtiY3ptbWdma2JudXlmd3JsbXR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA0ODA5NDgsImV4cCI6MjA4NjA1Njk0OH0.2l6oad-2j_CGLRfWEFrJI7jvFHcLWTG1gEkEtK8oPlY"
API_URL="https://loteriascaixa-api.herokuapp.com/api"

# Delay entre requisições (menor = mais rápido, mas pode sobrecarregar)
DELAY=0.3  # 300ms

# Salvar em lotes (batch)
BATCH_SIZE=50  # Salva 50 de uma vez

# Arquivo de progresso
PROGRESS_FILE="/tmp/import-progress.txt"

# Loterias
declare -A LOTERIAS=(
    [megasena]="Mega-Sena"
    [lotofacil]="Lotofácil"
    [quina]="Quina"
    [lotomania]="Lotomania"
    [timemania]="Timemania"
    [duplasena]="Dupla Sena"
    [diadesorte]="Dia de Sorte"
    [supersete]="Super Sete"
    [maismilionaria]="+Milionária"
)

# Estatísticas
declare -A STATS
STATS[total]=0
STATS[sucesso]=0
STATS[erro]=0
STATS[pulado]=0

# Limpar arquivo de progresso
> "$PROGRESS_FILE"

clear
echo -e "${BLUE}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🍀 Importador COMPLETO - Site da Sorte 🍀          ║${NC}"
echo -e "${BLUE}║     Versão Otimizada para Milhares de Concursos      ║${NC}"
echo -e "${BLUE}╔══════════════════════════════════════════════════════╗${NC}"
echo ""

# Verificar se jq está disponível (para JSON mais rápido)
if command -v jq &> /dev/null; then
    USE_JQ=true
    echo -e "${GREEN}✓ jq detectado - modo ultra-rápido ativado${NC}"
else
    USE_JQ=false
    echo -e "${YELLOW}⚠ jq não encontrado - usando modo padrão${NC}"
    echo -e "${YELLOW}  Para acelerar, instale: brew install jq${NC}"
fi
echo ""

# Função para salvar em lote no Supabase
salvar_lote_supabase() {
    local json_array="$1"

    # Enviar lote inteiro
    curl -s -X POST \
        "${SUPABASE_URL}/rest/v1/loterias" \
        -H "apikey: ${SUPABASE_KEY}" \
        -H "Authorization: Bearer ${SUPABASE_KEY}" \
        -H "Content-Type: application/json" \
        -H "Prefer: resolution=merge-duplicates,return=minimal" \
        -d "$json_array" > /dev/null 2>&1

    return $?
}

# Função otimizada para processar JSON
process_json() {
    local tipo_loteria=$1
    local json_data=$2

    if $USE_JQ; then
        # Modo ultra-rápido com jq
        echo "$json_data" | jq -c "{
            tipo_loteria: \"$tipo_loteria\",
            numero_concurso: .concurso,
            data_sorteio: (.data | split(\"/\") | \"\\(.[2])-\\(.[1])-\\(.[0])\"),
            dezenas: .dezenas,
            acumulou: .acumulou,
            valor_estimado_proximo: .valorEstimadoProximoConcurso,
            data_proximo_concurso: (.dataProximoConcurso | split(\"/\") | \"\\(.[2])-\\(.[1])-\\(.[0])\"),
            premiacoes: .premiacoes,
            dados_completos: .
        }"
    else
        # Modo padrão
        local concurso=$(echo "$json_data" | grep -o '"concurso":[0-9]*' | cut -d':' -f2)
        local data=$(echo "$json_data" | grep -o '"data":"[^"]*"' | cut -d'"' -f4)

        # Converter data
        if [[ $data =~ ([0-9]{2})/([0-9]{2})/([0-9]{4}) ]]; then
            data_sql="${BASH_REMATCH[3]}-${BASH_REMATCH[2]}-${BASH_REMATCH[1]}"
        fi

        local dezenas=$(echo "$json_data" | grep -o '"dezenas":\[[^]]*\]' | sed 's/"dezenas"://')
        local acumulou=$(echo "$json_data" | grep -o '"acumulou":[a-z]*' | cut -d':' -f2)

        echo "{\"tipo_loteria\":\"$tipo_loteria\",\"numero_concurso\":$concurso,\"data_sorteio\":\"$data_sql\",\"dezenas\":$dezenas,\"acumulou\":$acumulou}"
    fi
}

# Importar loteria completa otimizada
importar_loteria_completa() {
    local loteria_id=$1
    local loteria_nome=$2

    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║ 📥 Importando $loteria_nome${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════╝${NC}"

    # Buscar último concurso
    local ultimo_json=$(curl -s "${API_URL}/${loteria_id}/latest")
    local ultimo_concurso

    if $USE_JQ; then
        ultimo_concurso=$(echo "$ultimo_json" | jq -r '.concurso')
    else
        ultimo_concurso=$(echo "$ultimo_json" | grep -o '"concurso":[0-9]*' | cut -d':' -f2)
    fi

    if [[ -z "$ultimo_concurso" ]]; then
        echo -e "${RED}❌ Erro ao buscar último concurso${NC}"
        return
    fi

    echo -e "   Último concurso: ${GREEN}${ultimo_concurso}${NC}"
    echo -e "   Importando do 1 ao ${ultimo_concurso}"
    echo ""

    local batch_array="["
    local batch_count=0
    local total_importado=0
    local total_erro=0

    # Importar do mais recente para o mais antigo
    for ((i=ultimo_concurso; i>=1; i--)); do
        # Progresso visual
        if (( i % 10 == 0 )); then
            local percent=$(( (ultimo_concurso - i + 1) * 100 / ultimo_concurso ))
            printf "\r   [%-50s] %3d%% - Concurso %d/%d   " \
                "$(printf '#%.0s' $(seq 1 $((percent / 2))))" \
                "$percent" \
                "$i" \
                "$ultimo_concurso"
        fi

        # Buscar da API
        local json=$(curl -s "${API_URL}/${loteria_id}/${i}" 2>/dev/null)

        # Verificar se tem erro
        if [[ -z "$json" ]] || echo "$json" | grep -q "error\|404"; then
            # Concurso não existe, parar
            if (( i < ultimo_concurso - 100 )); then
                # Se já importamos mais de 100 e encontramos 404, significa que acabaram os concursos
                break
            fi
            total_erro=$((total_erro + 1))
            sleep $DELAY
            continue
        fi

        # Processar e adicionar ao batch
        local processed=$(process_json "$loteria_id" "$json")

        if [[ $batch_count -gt 0 ]]; then
            batch_array+=","
        fi
        batch_array+="$processed"
        batch_count=$((batch_count + 1))

        # Salvar batch quando atingir o tamanho
        if (( batch_count >= BATCH_SIZE )); then
            batch_array+="]"

            if salvar_lote_supabase "$batch_array"; then
                total_importado=$((total_importado + batch_count))
                STATS[sucesso]=$((STATS[sucesso] + batch_count))
            else
                total_erro=$((total_erro + batch_count))
                STATS[erro]=$((STATS[erro] + batch_count))
            fi

            STATS[total]=$((STATS[total] + batch_count))

            # Resetar batch
            batch_array="["
            batch_count=0
        fi

        sleep $DELAY
    done

    # Salvar último batch se tiver sobra
    if (( batch_count > 0 )); then
        batch_array+="]"

        if salvar_lote_supabase "$batch_array"; then
            total_importado=$((total_importado + batch_count))
            STATS[sucesso]=$((STATS[sucesso] + batch_count))
        fi

        STATS[total]=$((STATS[total] + batch_count))
    fi

    echo ""
    echo -e "   ${GREEN}✅ Concluído: $total_importado importados, $total_erro erros${NC}"

    # Salvar progresso
    echo "$loteria_nome: $total_importado concursos" >> "$PROGRESS_FILE"
}

# Menu
echo -e "${YELLOW}ATENÇÃO: Importação COMPLETA pode levar MUITO tempo!${NC}"
echo ""
echo "Estimativas de tempo:"
echo "  • Mega-Sena (~3000 concursos): ~15-20 minutos"
echo "  • Lotofácil (~3600 concursos): ~20-25 minutos"
echo "  • TODAS as loterias: ~2-3 HORAS"
echo ""
echo -e "${BLUE}Opções:${NC}"
echo "  1) Importar TODAS as loterias (COMPLETO)"
echo "  2) Escolher loterias específicas"
echo "  3) Mega-Sena apenas (teste)"
echo ""
read -p "Escolha: " opcao

case $opcao in
    1)
        loterias_para_importar=("megasena" "lotofacil" "quina" "lotomania" "timemania" "duplasena" "diadesorte" "supersete" "maismilionaria")
        ;;
    2)
        echo ""
        echo "Digite os IDs separados por espaço:"
        echo "megasena lotofacil quina lotomania timemania duplasena diadesorte supersete maismilionaria"
        read -p "> " -a loterias_para_importar
        ;;
    3)
        loterias_para_importar=("megasena")
        ;;
    *)
        echo "Opção inválida"
        exit 1
        ;;
esac

# Confirmar
echo ""
echo -e "${RED}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║                     ATENÇÃO!                         ║${NC}"
echo -e "${RED}║  Esta operação pode levar HORAS e usar muita banda  ║${NC}"
echo -e "${RED}║  Não feche esta janela até concluir!                 ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
read -p "Deseja continuar? (digite SIM em maiúsculas): " confirma

if [[ $confirma != "SIM" ]]; then
    echo "Cancelado."
    exit 0
fi

# Iniciar importação
INICIO=$(date +%s)

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         Iniciando Importação Completa...             ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"

for loteria_id in "${loterias_para_importar[@]}"; do
    if [[ -n "${LOTERIAS[$loteria_id]}" ]]; then
        importar_loteria_completa "$loteria_id" "${LOTERIAS[$loteria_id]}"
    fi
done

# Estatísticas finais
FIM=$(date +%s)
DURACAO=$((FIM - INICIO))
HORAS=$((DURACAO / 3600))
MINUTOS=$(( (DURACAO % 3600) / 60 ))
SEGUNDOS=$((DURACAO % 60))

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          ✅✅✅ IMPORTAÇÃO CONCLUÍDA! ✅✅✅           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📊 Estatísticas Globais:${NC}"
echo -e "   Total processado: ${STATS[total]}"
echo -e "   ${GREEN}✅ Sucesso: ${STATS[sucesso]}${NC}"
echo -e "   ${RED}❌ Erros: ${STATS[erro]}${NC}"
echo ""
echo -e "${BLUE}⏱  Tempo total: ${HORAS}h ${MINUTOS}m ${SEGUNDOS}s${NC}"
echo ""
echo -e "${BLUE}📋 Resumo por loteria:${NC}"
cat "$PROGRESS_FILE"
echo ""
echo -e "${BLUE}🔗 Ver todos os dados:${NC}"
echo "   https://supabase.com/dashboard/project/kbczmmgfkbnuyfwrlmtu/editor/loterias"
echo ""
echo -e "${GREEN}Pressione qualquer tecla para fechar...${NC}"
read -n 1 -s
