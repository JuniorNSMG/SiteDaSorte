#!/bin/bash

# Importador Ultra-Rápido via JSON do GitHub
# Baixa JSONs completos e importa em massa

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
GITHUB_JSON_BASE="https://raw.githubusercontent.com/guilhermeasn/loteria.json/master/data"

# Função para obter nome da loteria (compatível com bash 3.2)
get_loteria_nome() {
    case "$1" in
        megasena) echo "Mega-Sena" ;;
        lotofacil) echo "Lotofácil" ;;
        quina) echo "Quina" ;;
        lotomania) echo "Lotomania" ;;
        timemania) echo "Timemania" ;;
        duplasena) echo "Dupla Sena" ;;
        diadesorte) echo "Dia de Sorte" ;;
        supersete) echo "Super Sete" ;;
        maismilionaria) echo "+Milionária" ;;
        *) echo "$1" ;;
    esac
}

# Estatísticas
TOTAL_BAIXADO=0
TOTAL_IMPORTADO=0
TOTAL_JA_EXISTE=0
TOTAL_ENRIQUECIDO=0

clear
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  ⚡ IMPORTADOR ULTRA-RÁPIDO - GitHub JSON ⚡          ║${NC}"
echo -e "${BLUE}║    Importa MILHARES de concursos em MINUTOS!          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ Fonte: github.com/guilhermeasn/loteria.json${NC}"
echo -e "${GREEN}✓ Atualizado diariamente via GitHub Actions${NC}"
echo -e "${GREEN}✓ Histórico completo desde o primeiro concurso${NC}"
echo ""

# Verificar jq
if command -v jq &> /dev/null; then
    USE_JQ=true
    echo -e "${GREEN}✓ jq detectado - modo ultra-rápido ativado${NC}"
else
    USE_JQ=false
    echo -e "${YELLOW}⚠ jq não encontrado${NC}"
    echo -e "${YELLOW}  Instale para 10x mais velocidade: brew install jq${NC}"
fi
echo ""

# Função para verificar concursos existentes
get_existing_contests() {
    local loteria=$1

    curl -s "${SUPABASE_URL}/rest/v1/loterias?tipo_loteria=eq.$loteria&select=numero_concurso" \
        -H "apikey: ${SUPABASE_KEY}" \
        -H "Authorization: Bearer ${SUPABASE_KEY}" | \
    if $USE_JQ; then
        jq -r '.[].numero_concurso'
    else
        grep -o '"numero_concurso":[0-9]*' | cut -d':' -f2
    fi | sort -n
}

# Função para enriquecer dados da API
enriquecer_concurso() {
    local loteria=$1
    local numero=$2

    # Buscar dados completos da API
    local json=$(curl -s "${API_URL}/${loteria}/${numero}")

    if [[ -z "$json" ]] || echo "$json" | grep -q "error\|404"; then
        return 1
    fi

    # Extrair dados importantes
    local data acumulou valor_proximo data_proximo

    if $USE_JQ; then
        data=$(echo "$json" | jq -r '.data // empty')
        acumulou=$(echo "$json" | jq -r '.acumulou // false')
        valor_proximo=$(echo "$json" | jq -r '.valorEstimadoProximoConcurso // 0')
        data_proximo=$(echo "$json" | jq -r '.dataProximoConcurso // empty')
    else
        data=$(echo "$json" | grep -o '"data":"[^"]*"' | cut -d'"' -f4)
        acumulou=$(echo "$json" | grep -o '"acumulou":[a-z]*' | cut -d':' -f2)
        valor_proximo=$(echo "$json" | grep -o '"valorEstimadoProximoConcurso":[0-9.]*' | cut -d':' -f2)
        data_proximo=$(echo "$json" | grep -o '"dataProximoConcurso":"[^"]*"' | cut -d'"' -f4)
    fi

    # Converter datas
    if [[ $data =~ ([0-9]{2})/([0-9]{2})/([0-9]{4}) ]]; then
        data="${BASH_REMATCH[3]}-${BASH_REMATCH[2]}-${BASH_REMATCH[1]}"
    fi

    if [[ $data_proximo =~ ([0-9]{2})/([0-9]{2})/([0-9]{4}) ]]; then
        data_proximo="${BASH_REMATCH[3]}-${BASH_REMATCH[2]}-${BASH_REMATCH[1]}"
    fi

    # Atualizar no Supabase
    local update_json="{\"data_sorteio\":\"$data\",\"acumulou\":$acumulou,\"valor_estimado_proximo\":$valor_proximo,\"data_proximo_concurso\":\"$data_proximo\",\"dados_completos\":$json}"

    curl -s -X PATCH \
        "${SUPABASE_URL}/rest/v1/loterias?tipo_loteria=eq.$loteria&numero_concurso=eq.$numero" \
        -H "apikey: ${SUPABASE_KEY}" \
        -H "Authorization: Bearer ${SUPABASE_KEY}" \
        -H "Content-Type: application/json" \
        -d "$update_json" > /dev/null 2>&1

    return $?
}

# Função para importar loteria do GitHub
importar_do_github() {
    local loteria_id="$1"
    local loteria_nome="$2"

    # Debug: verificar parâmetros recebidos
    echo "DEBUG: loteria_id='$loteria_id', loteria_nome='$loteria_nome'"

    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║ 📥 Importando ${loteria_nome} do GitHub JSON${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"

    # Baixar JSON do GitHub
    echo -e "   📡 Baixando JSON completo..."
    local json_url="${GITHUB_JSON_BASE}/${loteria_id}.json"
    local json_file="/tmp/${loteria_id}.json"

    if ! curl -s -f "$json_url" -o "$json_file"; then
        echo -e "${RED}   ❌ Erro ao baixar JSON${NC}"
        return 1
    fi

    # Contar total de concursos no JSON
    local total_github
    if $USE_JQ; then
        total_github=$(jq 'length' "$json_file")
    else
        total_github=$(grep -o '"[0-9]*":' "$json_file" | wc -l)
    fi

    echo -e "   ✓ Baixado: ${GREEN}${total_github} concursos${NC}"

    TOTAL_BAIXADO=$((TOTAL_BAIXADO + total_github))

    # Buscar concursos já existentes no Supabase
    echo -e "   🔍 Verificando concursos existentes no Supabase..."
    local existing=$(get_existing_contests "$loteria_id")
    local total_existente=$(echo "$existing" | wc -l)

    if [[ -n "$existing" ]]; then
        echo -e "   ✓ Já existem: ${YELLOW}${total_existente} concursos${NC}"
        TOTAL_JA_EXISTE=$((TOTAL_JA_EXISTE + total_existente))
    else
        echo -e "   ✓ Banco vazio - importando tudo"
        total_existente=0
    fi

    # Preparar batch para importação
    echo -e "   📦 Preparando importação em lote..."

    local batch_array="["
    local batch_count=0
    local importados=0

    # Processar cada concurso
    if $USE_JQ; then
        # Modo rápido com jq
        while IFS=$'\t' read -r numero dezenas; do
            # Pular linhas vazias
            [[ -z "$numero" ]] && continue

            # Verificar se já existe
            if echo "$existing" | grep -q "^${numero}$"; then
                continue
            fi

            if (( batch_count > 0 )); then
                batch_array+=","
            fi

            batch_array+="{\"tipo_loteria\":\"${loteria_id}\",\"numero_concurso\":${numero},\"dezenas\":${dezenas}}"
            batch_count=$((batch_count + 1))

            # Salvar batch quando atingir 100
            if (( batch_count >= 100 )); then
                batch_array+="]"

                response=$(curl -s -X POST \
                    "${SUPABASE_URL}/rest/v1/loterias" \
                    -H "apikey: ${SUPABASE_KEY}" \
                    -H "Authorization: Bearer ${SUPABASE_KEY}" \
                    -H "Content-Type: application/json" \
                    -H "Prefer: resolution=merge-duplicates,return=minimal" \
                    -d "$batch_array" 2>&1)

                if [[ $? -ne 0 ]] || echo "$response" | grep -q "error"; then
                    echo -e "\n   ${RED}❌ Erro ao salvar batch: $response${NC}"
                fi

                importados=$((importados + batch_count))
                printf "\r   💾 Salvando no Supabase: %d concursos   " "$importados"

                batch_array="["
                batch_count=0
            fi
        done < <(jq -r 'to_entries | .[] | "\(.key)\t\(.value)"' "$json_file")
    else
        # Modo sem jq (mais lento)
        while read -r line; do
            if [[ $line =~ \"([0-9]+)\":(\[.*?\]) ]]; then
                local numero="${BASH_REMATCH[1]}"
                local dezenas="${BASH_REMATCH[2]}"

                if echo "$existing" | grep -q "^${numero}$"; then
                    continue
                fi

                if (( batch_count > 0 )); then
                    batch_array+=","
                fi

                batch_array+="{\"tipo_loteria\":\"${loteria_id}\",\"numero_concurso\":${numero},\"dezenas\":${dezenas}}"
                batch_count=$((batch_count + 1))

                if (( batch_count >= 100 )); then
                    batch_array+="]"

                    response=$(curl -s -X POST \
                        "${SUPABASE_URL}/rest/v1/loterias" \
                        -H "apikey: ${SUPABASE_KEY}" \
                        -H "Authorization: Bearer ${SUPABASE_KEY}" \
                        -H "Content-Type: application/json" \
                        -H "Prefer: resolution=merge-duplicates,return=minimal" \
                        -d "$batch_array" 2>&1)

                    if [[ $? -ne 0 ]] || echo "$response" | grep -q "error"; then
                        echo -e "\n   ${RED}❌ Erro ao salvar batch: $response${NC}"
                    fi

                    importados=$((importados + batch_count))
                    printf "\r   💾 Salvando no Supabase: %d concursos   " "$importados"

                    batch_array="["
                    batch_count=0
                fi
            fi
        done < "$json_file"
    fi

    # Salvar último batch
    if (( batch_count > 0 )); then
        batch_array+="]"

        response=$(curl -s -X POST \
            "${SUPABASE_URL}/rest/v1/loterias" \
            -H "apikey: ${SUPABASE_KEY}" \
            -H "Authorization: Bearer ${SUPABASE_KEY}" \
            -H "Content-Type: application/json" \
            -H "Prefer: resolution=merge-duplicates,return=minimal" \
            -d "$batch_array" 2>&1)

        if [[ $? -ne 0 ]] || echo "$response" | grep -q "error"; then
            echo -e "\n   ${RED}❌ Erro ao salvar último batch: $response${NC}"
        fi

        importados=$((importados + batch_count))
    fi

    echo -e "\r   ✅ Importados: ${GREEN}${importados} novos concursos${NC}            "

    TOTAL_IMPORTADO=$((TOTAL_IMPORTADO + importados))

    # Limpar arquivo temporário
    rm -f "$json_file"

    # Perguntar se quer enriquecer com dados da API
    if (( importados > 0 )); then
        echo ""
        read -p "   Enriquecer com dados completos da API (data, prêmios)? (s/n): " enriquecer

        if [[ $enriquecer == "s" ]]; then
            echo -e "   🔄 Enriquecendo últimos 100 concursos..."

            local enriquecidos=0
            local max_enriquecer=100

            for ((i=total_github; i>total_github-max_enriquecer && i>=1; i--)); do
                if ! echo "$existing" | grep -q "^${i}$"; then
                    if enriquecer_concurso "$loteria_id" "$i"; then
                        enriquecidos=$((enriquecidos + 1))
                    fi
                    printf "\r   ⏳ Enriquecidos: %d/%d   " "$enriquecidos" "$max_enriquecer"
                    sleep 0.5
                fi
            done

            echo -e "\r   ✅ Enriquecidos: ${GREEN}${enriquecidos} concursos${NC}            "
            TOTAL_ENRIQUECIDO=$((TOTAL_ENRIQUECIDO + enriquecidos))
        fi
    fi
}

# Menu
echo -e "${YELLOW}Escolha o modo de importação:${NC}"
echo ""
echo "  1) IMPORTAR TUDO - Todas as 9 loterias (RECOMENDADO) ⚡"
echo "  2) Escolher loterias específicas"
echo "  3) Apenas Mega-Sena (teste rápido)"
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
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Importação Ultra-Rápida via GitHub JSON              ║${NC}"
echo -e "${BLUE}║  Tempo estimado: 2-5 MINUTOS para tudo! ⚡            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
read -p "Continuar? (s/n): " confirma

if [[ $confirma != "s" ]]; then
    echo "Cancelado."
    exit 0
fi

# Iniciar importação
INICIO=$(date +%s)

for loteria_id in "${loterias_para_importar[@]}"; do
    loteria_nome=$(get_loteria_nome "$loteria_id")
    if [[ -n "$loteria_nome" ]]; then
        importar_do_github "$loteria_id" "$loteria_nome"
    fi
done

# Estatísticas finais
FIM=$(date +%s)
DURACAO=$((FIM - INICIO))
MINUTOS=$((DURACAO / 60))
SEGUNDOS=$((DURACAO % 60))

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║       ✅✅✅ IMPORTAÇÃO ULTRA-RÁPIDA CONCLUÍDA! ✅✅✅  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📊 Estatísticas:${NC}"
echo -e "   📥 Total baixado do GitHub: ${TOTAL_BAIXADO} concursos"
echo -e "   💾 Total importado (novos): ${GREEN}${TOTAL_IMPORTADO}${NC} concursos"
echo -e "   ⏭️  Já existiam: ${YELLOW}${TOTAL_JA_EXISTE}${NC} concursos"
echo -e "   🔄 Enriquecidos com API: ${TOTAL_ENRIQUECIDO} concursos"
echo ""
echo -e "${BLUE}⏱  Tempo total: ${MINUTOS}m ${SEGUNDOS}s${NC}"
echo ""
echo -e "${BLUE}🔗 Ver todos os dados:${NC}"
echo "   https://supabase.com/dashboard/project/kbczmmgfkbnuyfwrlmtu/editor/loterias"
echo ""
echo -e "${GREEN}✨ Pronto! Dezenas de milhares de concursos importados em minutos! ✨${NC}"
echo ""
echo -e "${GREEN}Pressione qualquer tecla para fechar...${NC}"
read -n 1 -s
