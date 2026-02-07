#!/bin/bash

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

# Mapeamento de loterias
declare -a LOTERIAS_IDS=(megasena lotofacil quina lotomania timemania duplasena diadesorte supersete maismilionaria)
declare -a LOTERIAS_NOMES=("Mega-Sena" "Lotofácil" "Quina" "Lotomania" "Timemania" "Dupla Sena" "Dia de Sorte" "Super Sete" "+Milionária")

clear
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🔍 VERIFICAÇÃO DE ATUALIZAÇÃO - 100% CONFIÁVEL       ║${NC}"
echo -e "${BLUE}║     Compara Supabase vs API oficial da Caixa         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

total_desatualizadas=0
total_atualizadas=0

for i in "${!LOTERIAS_IDS[@]}"; do
    loteria_id="${LOTERIAS_IDS[$i]}"
    loteria_nome="${LOTERIAS_NOMES[$i]}"

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}📊 ${loteria_nome}${NC}"
    echo ""

    # Buscar último concurso na API da Caixa
    echo -n "   🌐 Consultando API oficial... "
    api_response=$(curl -s "${API_URL}/${loteria_id}/latest" 2>/dev/null)

    if [[ -z "$api_response" ]] || echo "$api_response" | grep -q "error"; then
        echo -e "${RED}ERRO${NC}"
        echo "   ⚠️  API não respondeu"
        echo ""
        continue
    fi

    # Extrair número do concurso da API
    if command -v jq &> /dev/null; then
        ultimo_api=$(echo "$api_response" | jq -r '.concurso' 2>/dev/null)
        data_api=$(echo "$api_response" | jq -r '.data' 2>/dev/null)
    else
        ultimo_api=$(echo "$api_response" | grep -o '"concurso":[0-9]*' | head -1 | grep -o '[0-9]*')
        data_api=$(echo "$api_response" | grep -o '"data":"[^"]*"' | head -1 | cut -d'"' -f4)
    fi

    if [[ -z "$ultimo_api" ]] || [[ "$ultimo_api" == "null" ]]; then
        echo -e "${RED}ERRO${NC}"
        echo "   ⚠️  Não foi possível extrair concurso da API"
        echo ""
        continue
    fi

    echo -e "${GREEN}OK${NC}"
    echo "   📅 Último concurso oficial: ${GREEN}#${ultimo_api}${NC} (${data_api})"

    # Buscar último concurso no Supabase
    echo -n "   💾 Consultando Supabase... "
    supabase_response=$(curl -s "${SUPABASE_URL}/rest/v1/loterias?tipo_loteria=eq.${loteria_id}&select=numero_concurso&order=numero_concurso.desc&limit=1" \
        -H "apikey: ${SUPABASE_KEY}" \
        -H "Authorization: Bearer ${SUPABASE_KEY}" 2>/dev/null)

    if command -v jq &> /dev/null; then
        ultimo_supabase=$(echo "$supabase_response" | jq -r '.[0].numero_concurso' 2>/dev/null)
    else
        ultimo_supabase=$(echo "$supabase_response" | grep -o '"numero_concurso":[0-9]*' | head -1 | grep -o '[0-9]*')
    fi

    if [[ -z "$ultimo_supabase" ]] || [[ "$ultimo_supabase" == "null" ]]; then
        echo -e "${RED}ERRO${NC}"
        echo "   ⚠️  Nenhum concurso encontrado no banco"
        echo ""
        total_desatualizadas=$((total_desatualizadas + 1))
        continue
    fi

    echo -e "${GREEN}OK${NC}"
    echo "   💾 Último concurso no banco: ${BLUE}#${ultimo_supabase}${NC}"
    echo ""

    # Comparar
    if [[ $ultimo_supabase -eq $ultimo_api ]]; then
        echo -e "   ✅ ${GREEN}ATUALIZADO!${NC} Banco está 100% em dia!"
        total_atualizadas=$((total_atualizadas + 1))
    elif [[ $ultimo_supabase -lt $ultimo_api ]]; then
        faltam=$((ultimo_api - ultimo_supabase))
        echo -e "   ⚠️  ${YELLOW}DESATUALIZADO!${NC} Faltam ${RED}${faltam} concursos${NC}"
        echo "   📥 Para atualizar, rode: ./IMPORTAR-TUDO.command"
        total_desatualizadas=$((total_desatualizadas + 1))
    else
        echo -e "   ⚠️  ${YELLOW}INCONSISTENTE${NC} Banco tem concursos mais recentes que a API"
        total_desatualizadas=$((total_desatualizadas + 1))
    fi

    echo ""
done

# Resumo final
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║               📊 RESUMO DA VERIFICAÇÃO                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

if [[ $total_desatualizadas -eq 0 ]]; then
    echo -e "${GREEN}✅✅✅ TUDO 100% ATUALIZADO! ✅✅✅${NC}"
    echo ""
    echo "🎉 Todas as $total_atualizadas loterias estão com os dados mais recentes!"
else
    echo -e "${YELLOW}⚠️  Encontradas $total_desatualizadas loterias desatualizadas${NC}"
    echo -e "${GREEN}✅ $total_atualizadas loterias estão atualizadas${NC}"
    echo ""
    echo "💡 Para atualizar, execute um dos comandos de importação"
fi

echo ""
echo "Pressione qualquer tecla para fechar..."
read -n 1 -s
