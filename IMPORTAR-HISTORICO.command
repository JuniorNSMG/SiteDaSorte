#!/bin/bash

# Importador de Histórico - Site da Sorte
# Duplo clique para executar!

cd "$(dirname "$0")"

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configurações Supabase
SUPABASE_URL="https://kbczmmgfkbnuyfwrlmtu.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtiY3ptbWdma2JudXlmd3JsbXR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA0ODA5NDgsImV4cCI6MjA4NjA1Njk0OH0.2l6oad-2j_CGLRfWEFrJI7jvFHcLWTG1gEkEtK8oPlY"
API_URL="https://loteriascaixa-api.herokuapp.com/api"

# Loterias disponíveis
declare -A LOTERIAS=(
    [1]="megasena:Mega-Sena"
    [2]="lotofacil:Lotofácil"
    [3]="quina:Quina"
    [4]="lotomania:Lotomania"
    [5]="timemania:Timemania"
    [6]="duplasena:Dupla Sena"
    [7]="diadesorte:Dia de Sorte"
    [8]="supersete:Super Sete"
    [9]="maismilionaria:+Milionária"
)

# Estatísticas
TOTAL=0
SUCESSO=0
ERRO=0
PULADO=0

clear
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🍀 Importador de Histórico - Site da Sorte  🍀║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo ""

# Função para converter data BR para SQL
convert_date() {
    local data_br=$1
    if [[ $data_br =~ ([0-9]{2})/([0-9]{2})/([0-9]{4}) ]]; then
        echo "${BASH_REMATCH[3]}-${BASH_REMATCH[2]}-${BASH_REMATCH[1]}"
    else
        echo "null"
    fi
}

# Função para salvar no Supabase
salvar_supabase() {
    local tipo_loteria=$1
    local json_data=$2

    # Extrair dados do JSON
    local concurso=$(echo "$json_data" | grep -o '"concurso":[0-9]*' | cut -d':' -f2)
    local data=$(echo "$json_data" | grep -o '"data":"[^"]*"' | cut -d'"' -f4)
    local data_sql=$(convert_date "$data")

    # Extrair dezenas (array)
    local dezenas=$(echo "$json_data" | grep -o '"dezenas":\[[^]]*\]' | sed 's/"dezenas"://')

    # Acumulou
    local acumulou=$(echo "$json_data" | grep -o '"acumulou":[a-z]*' | cut -d':' -f2)

    # Valor próximo concurso
    local valor_proximo=$(echo "$json_data" | grep -o '"valorEstimadoProximoConcurso":[0-9.]*' | cut -d':' -f2)

    # Data próximo concurso
    local data_proximo=$(echo "$json_data" | grep -o '"dataProximoConcurso":"[^"]*"' | cut -d'"' -f4)
    local data_proximo_sql=$(convert_date "$data_proximo")

    # Preparar JSON para Supabase
    local supabase_json=$(cat <<EOF
{
  "tipo_loteria": "$tipo_loteria",
  "numero_concurso": $concurso,
  "data_sorteio": "$data_sql",
  "dezenas": $dezenas,
  "acumulou": $acumulou,
  "valor_estimado_proximo": $valor_proximo,
  "data_proximo_concurso": "$data_proximo_sql",
  "premiacoes": $(echo "$json_data" | grep -o '"premiacoes":\[[^]]*\]' | sed 's/"premiacoes"://'),
  "dados_completos": $json_data
}
EOF
)

    # Enviar para Supabase (upsert)
    local response=$(curl -s -X POST \
        "${SUPABASE_URL}/rest/v1/loterias" \
        -H "apikey: ${SUPABASE_KEY}" \
        -H "Authorization: Bearer ${SUPABASE_KEY}" \
        -H "Content-Type: application/json" \
        -H "Prefer: resolution=merge-duplicates" \
        -d "$supabase_json")

    if [[ $? -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

# Função para importar um concurso
importar_concurso() {
    local loteria_id=$1
    local numero=$2
    local total_concursos=$3

    # Buscar da API
    local json=$(curl -s "${API_URL}/${loteria_id}/${numero}")

    if [[ $? -ne 0 ]] || [[ -z "$json" ]]; then
        return 1
    fi

    # Verificar se é erro 404
    if echo "$json" | grep -q "error\|404\|Not Found"; then
        return 2
    fi

    # Salvar no Supabase
    if salvar_supabase "$loteria_id" "$json"; then
        SUCESSO=$((SUCESSO + 1))
        return 0
    else
        ERRO=$((ERRO + 1))
        return 1
    fi
}

# Função para importar histórico de uma loteria
importar_loteria() {
    local loteria_id=$1
    local loteria_nome=$2
    local quantidade=$3

    echo -e "\n${BLUE}📥 Importando $loteria_nome...${NC}"

    # Buscar último concurso
    local ultimo_json=$(curl -s "${API_URL}/${loteria_id}/latest")
    local ultimo_concurso=$(echo "$ultimo_json" | grep -o '"concurso":[0-9]*' | cut -d':' -f2)

    if [[ -z "$ultimo_concurso" ]]; then
        echo -e "${RED}❌ Erro ao buscar último concurso${NC}"
        return
    fi

    echo -e "   Último concurso: ${ultimo_concurso}"

    # Calcular range
    if [[ $quantidade -eq 0 ]]; then
        primeiro=1
        total=$ultimo_concurso
    else
        primeiro=$((ultimo_concurso - quantidade + 1))
        if [[ $primeiro -lt 1 ]]; then
            primeiro=1
        fi
        total=$quantidade
    fi

    echo -e "   Importando concursos ${primeiro} a ${ultimo_concurso}"
    echo ""

    local atual=0
    # Importar do mais recente para o mais antigo
    for ((i=ultimo_concurso; i>=primeiro; i--)); do
        atual=$((atual + 1))
        TOTAL=$((TOTAL + 1))

        # Progresso
        local percent=$((atual * 100 / total))
        printf "   [%-50s] %d%% - Concurso %d/%d\r" \
            "$(printf '#%.0s' $(seq 1 $((percent / 2))))" \
            "$percent" \
            "$i" \
            "$ultimo_concurso"

        # Importar
        importar_concurso "$loteria_id" "$i" "$total"
        local result=$?

        if [[ $result -eq 2 ]]; then
            # Concurso não existe, parar
            echo -e "\n   ⚠️  Concurso $i não encontrado, parando..."
            break
        fi

        # Delay para não sobrecarregar API
        sleep 0.5
    done

    echo ""
    echo -e "   ${GREEN}✅ $loteria_nome concluída!${NC}"
}

# Menu principal
echo -e "${YELLOW}Escolha as loterias para importar:${NC}"
echo ""
echo "  0) TODAS as loterias"
echo "  ────────────────────"
for i in {1..9}; do
    IFS=':' read -r id nome <<< "${LOTERIAS[$i]}"
    echo "  $i) $nome"
done
echo ""
read -p "Digite os números separados por espaço (ex: 1 2 3) ou 0 para todas: " escolha

# Processar escolha
if [[ "$escolha" == "0" ]]; then
    loterias_selecionadas=(1 2 3 4 5 6 7 8 9)
else
    read -a loterias_selecionadas <<< "$escolha"
fi

echo ""
echo -e "${YELLOW}Quantos concursos importar por loteria?${NC}"
echo ""
echo "  1) Últimos 10 concursos (teste rápido)"
echo "  2) Últimos 50 concursos (~1 minuto)"
echo "  3) Últimos 100 concursos (~2-3 minutos)"
echo "  4) Últimos 500 concursos (~10-15 minutos)"
echo "  5) TODOS os concursos (MUITO LENTO - pode levar horas!)"
echo "  6) Personalizado"
echo ""
read -p "Escolha uma opção: " opcao_qtd

case $opcao_qtd in
    1) quantidade=10 ;;
    2) quantidade=50 ;;
    3) quantidade=100 ;;
    4) quantidade=500 ;;
    5) quantidade=0 ;;
    6)
        read -p "Digite a quantidade de concursos: " quantidade
        ;;
    *)
        quantidade=100
        ;;
esac

if [[ $quantidade -eq 0 ]]; then
    echo -e "\n${RED}⚠️  ATENÇÃO: Você escolheu importar TODOS os concursos!${NC}"
    echo -e "${RED}   Isso pode levar HORAS e consumir muita banda/recursos.${NC}"
    read -p "Tem certeza? (s/n): " confirma
    if [[ $confirma != "s" ]]; then
        echo "Importação cancelada."
        exit 0
    fi
fi

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Iniciando Importação...              ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"

# Importar cada loteria selecionada
for num in "${loterias_selecionadas[@]}"; do
    if [[ $num -ge 1 ]] && [[ $num -le 9 ]]; then
        IFS=':' read -r id nome <<< "${LOTERIAS[$num]}"
        importar_loteria "$id" "$nome" "$quantidade"
    fi
done

# Estatísticas finais
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          ✅ Importação Concluída! ✅            ║${NC}"
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo ""
echo -e "${BLUE}📊 Estatísticas:${NC}"
echo -e "   Total processado: ${TOTAL}"
echo -e "   ${GREEN}✅ Sucesso: ${SUCESSO}${NC}"
echo -e "   ${YELLOW}⏭️  Pulados: ${PULADO}${NC}"
echo -e "   ${RED}❌ Erros: ${ERRO}${NC}"
echo ""
echo -e "${BLUE}🔗 Ver dados importados:${NC}"
echo "   https://supabase.com/dashboard/project/kbczmmgfkbnuyfwrlmtu/editor/loterias"
echo ""
echo -e "${GREEN}Pressione qualquer tecla para fechar...${NC}"
read -n 1 -s
