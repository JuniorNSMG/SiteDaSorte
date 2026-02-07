#!/bin/bash

# Cores
BLUE='\033[0;34m'
NC='\033[0m'

# Array de loterias
declare -A LOTERIAS=(
    [megasena]="Mega-Sena"
    [lotofacil]="Lotofácil"
    [quina]="Quina"
    [maismilionaria]="+Milionária"
)

# Função de teste
importar_teste() {
    local loteria_id="$1"
    local loteria_nome="$2"

    echo "=== DENTRO DA FUNÇÃO ==="
    echo "Parâmetro 1 (\$1): '$1'"
    echo "Parâmetro 2 (\$2): '$2'"
    echo "loteria_id: '$loteria_id'"
    echo "loteria_nome: '$loteria_nome'"
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║ 📥 Importando ${loteria_nome} do GitHub JSON${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Simular criação de JSON
    local json_teste="{\"tipo_loteria\":\"${loteria_id}\",\"numero_concurso\":1}"
    echo "JSON criado: $json_teste"
    echo ""
}

# Lista de loterias para importar
loterias_para_importar=("megasena" "lotofacil" "maismilionaria")

echo "=== TESTE DE LOOP E FUNÇÃ O ==="
echo ""

for loteria_id in "${loterias_para_importar[@]}"; do
    echo "--- Iteração do loop ---"
    echo "loteria_id no loop: '$loteria_id'"
    echo "LOTERIAS[\$loteria_id]: '${LOTERIAS[$loteria_id]}'"
    echo ""

    if [[ -n "${LOTERIAS[$loteria_id]}" ]]; then
        importar_teste "$loteria_id" "${LOTERIAS[$loteria_id]}"
    fi
done
