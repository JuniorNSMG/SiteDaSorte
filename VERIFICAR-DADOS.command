#!/bin/bash

# Verificador de Dados - Site da Sorte
# Mostra estatísticas completas do Supabase

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

clear
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        🔍 VERIFICADOR DE DADOS - Supabase 🔍          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verificar se jq está disponível
if command -v jq &> /dev/null; then
    USE_JQ=true
else
    USE_JQ=false
fi

# Função para contar registros
contar_registros() {
    local loteria=$1

    local response=$(curl -s "${SUPABASE_URL}/rest/v1/loterias?tipo_loteria=eq.$loteria&select=numero_concurso" \
        -H "apikey: ${SUPABASE_KEY}" \
        -H "Authorization: Bearer ${SUPABASE_KEY}")

    if $USE_JQ; then
        echo "$response" | jq 'length'
    else
        echo "$response" | grep -o '"numero_concurso"' | wc -l | tr -d ' '
    fi
}

# Função para obter range de concursos
get_range() {
    local loteria=$1

    local response=$(curl -s "${SUPABASE_URL}/rest/v1/loterias?tipo_loteria=eq.$loteria&select=numero_concurso&order=numero_concurso.asc&limit=1" \
        -H "apikey: ${SUPABASE_KEY}" \
        -H "Authorization: Bearer ${SUPABASE_KEY}")

    local primeiro
    if $USE_JQ; then
        primeiro=$(echo "$response" | jq -r '.[0].numero_concurso // 0')
    else
        primeiro=$(echo "$response" | grep -o '"numero_concurso":[0-9]*' | head -1 | cut -d':' -f2)
        [[ -z "$primeiro" ]] && primeiro=0
    fi

    local response2=$(curl -s "${SUPABASE_URL}/rest/v1/loterias?tipo_loteria=eq.$loteria&select=numero_concurso&order=numero_concurso.desc&limit=1" \
        -H "apikey: ${SUPABASE_KEY}" \
        -H "Authorization: Bearer ${SUPABASE_KEY}")

    local ultimo
    if $USE_JQ; then
        ultimo=$(echo "$response2" | jq -r '.[0].numero_concurso // 0')
    else
        ultimo=$(echo "$response2" | grep -o '"numero_concurso":[0-9]*' | head -1 | cut -d':' -f2)
        [[ -z "$ultimo" ]] && ultimo=0
    fi

    echo "${primeiro}-${ultimo}"
}

# Verificar total geral
echo -e "${YELLOW}📊 Consultando Supabase...${NC}"
echo ""

total_geral=$(curl -s "${SUPABASE_URL}/rest/v1/loterias?select=count" \
    -H "apikey: ${SUPABASE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_KEY}" \
    -H "Prefer: count=exact")

if $USE_JQ; then
    total_count=$(echo "$total_geral" | jq -r '.[0].count // 0')
else
    # Pegar do header (mais confiável sem jq)
    total_count=$(curl -s -I "${SUPABASE_URL}/rest/v1/loterias?select=id" \
        -H "apikey: ${SUPABASE_KEY}" \
        -H "Authorization: Bearer ${SUPABASE_KEY}" \
        -H "Prefer: count=exact" | grep -i "content-range" | grep -o '[0-9]*$')
    [[ -z "$total_count" ]] && total_count=0
fi

echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  TOTAL NO BANCO: ${total_count} concursos${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Estatísticas por loteria
echo -e "${BLUE}📋 Detalhes por Loteria:${NC}"
echo ""
printf "%-20s %10s %20s\n" "LOTERIA" "TOTAL" "RANGE (primeiro-último)"
echo "────────────────────────────────────────────────────────────"

total_verificado=0

for loteria_id in megasena lotofacil quina lotomania timemania duplasena diadesorte supersete maismilionaria; do
    loteria_nome="${LOTERIAS[$loteria_id]}"

    # Contar
    count=$(contar_registros "$loteria_id")
    total_verificado=$((total_verificado + count))

    # Range
    range=$(get_range "$loteria_id")

    # Cor baseada na quantidade
    if (( count > 1000 )); then
        cor=$GREEN
    elif (( count > 100 )); then
        cor=$YELLOW
    elif (( count > 0 )); then
        cor=$BLUE
    else
        cor=$RED
    fi

    printf "${cor}%-20s %10s %20s${NC}\n" "$loteria_nome" "$count" "$range"
done

echo "────────────────────────────────────────────────────────────"
printf "%-20s %10s\n" "TOTAL VERIFICADO:" "$total_verificado"
echo ""

# Análise
echo -e "${BLUE}🔍 Análise:${NC}"
echo ""

if (( total_count == 0 )); then
    echo -e "${RED}❌ BANCO VAZIO!${NC}"
    echo ""
    echo "Nenhum dado foi importado ainda."
    echo ""
    echo -e "${YELLOW}👉 Soluções:${NC}"
    echo "   1. Execute: IMPORTAR-GITHUB-JSON.command (2-5 minutos)"
    echo "   2. Ou execute: IMPORTAR-TUDO.command (2-3 horas)"
    echo ""
elif (( total_count < 1000 )); then
    echo -e "${YELLOW}⚠️  POUCOS DADOS IMPORTADOS${NC}"
    echo ""
    echo "Esperado: ~27.000 concursos"
    echo "Atual: ${total_count} concursos"
    echo ""
    echo -e "${YELLOW}👉 Recomendação:${NC}"
    echo "   Execute IMPORTAR-GITHUB-JSON.command para importar histórico completo"
    echo ""
elif (( total_count < 10000 )); then
    echo -e "${BLUE}📊 IMPORTAÇÃO PARCIAL${NC}"
    echo ""
    echo "Você tem ${total_count} concursos no banco."
    echo ""
    echo -e "${YELLOW}👉 Para importar mais:${NC}"
    echo "   Execute IMPORTAR-GITHUB-JSON.command"
    echo ""
else
    echo -e "${GREEN}✅ BANCO BEM POPULADO!${NC}"
    echo ""
    echo "Você tem ${total_count} concursos importados!"
    echo ""
    if (( total_count < 27000 )); then
        echo -e "${BLUE}💡 Dica: Execute IMPORTAR-GITHUB-JSON.command para completar${NC}"
        echo ""
    fi
fi

# Verificar dados completos
echo -e "${BLUE}🔍 Verificando qualidade dos dados...${NC}"
echo ""

# Checar quantos tem data_sorteio preenchida
with_date=$(curl -s "${SUPABASE_URL}/rest/v1/loterias?select=id&data_sorteio=not.is.null" \
    -H "apikey: ${SUPABASE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_KEY}" \
    -H "Prefer: count=exact" -I | grep -i "content-range" | grep -o '[0-9]*$')
[[ -z "$with_date" ]] && with_date=0

# Checar quantos tem premiações
with_prizes=$(curl -s "${SUPABASE_URL}/rest/v1/loterias?select=id&premiacoes=not.is.null" \
    -H "apikey: ${SUPABASE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_KEY}" \
    -H "Prefer: count=exact" -I | grep -i "content-range" | grep -o '[0-9]*$')
[[ -z "$with_prizes" ]] && with_prizes=0

if (( total_count > 0 )); then
    percent_date=$((with_date * 100 / total_count))
    percent_prizes=$((with_prizes * 100 / total_count))

    echo "  Com data de sorteio: ${with_date} (${percent_date}%)"
    echo "  Com premiações: ${with_prizes} (${percent_prizes}%)"
    echo ""

    if (( percent_date < 50 )); then
        echo -e "${YELLOW}⚠️  Muitos concursos sem data/premiações${NC}"
        echo ""
        echo "Execute IMPORTAR-GITHUB-JSON.command e escolha 's' para enriquecer"
        echo ""
    fi
fi

# Links úteis
echo -e "${BLUE}🔗 Links Úteis:${NC}"
echo ""
echo "  Ver dados no Supabase:"
echo "  https://supabase.com/dashboard/project/kbczmmgfkbnuyfwrlmtu/editor/loterias"
echo ""
echo "  SQL Editor (consultas personalizadas):"
echo "  https://supabase.com/dashboard/project/kbczmmgfkbnuyfwrlmtu/sql/new"
echo ""

# Exemplos de consultas SQL
echo -e "${BLUE}💡 Consultas SQL úteis:${NC}"
echo ""
echo "  # Ver números mais sorteados (Mega-Sena):"
echo "  SELECT unnest(dezenas) as numero, COUNT(*) as vezes"
echo "  FROM loterias WHERE tipo_loteria = 'megasena'"
echo "  GROUP BY numero ORDER BY vezes DESC LIMIT 10;"
echo ""
echo "  # Ver concursos acumulados:"
echo "  SELECT tipo_loteria, numero_concurso, valor_estimado_proximo"
echo "  FROM loterias WHERE acumulou = true"
echo "  ORDER BY valor_estimado_proximo DESC LIMIT 10;"
echo ""

echo -e "${GREEN}Pressione qualquer tecla para fechar...${NC}"
read -n 1 -s
