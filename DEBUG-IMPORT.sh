#!/bin/bash

# Script de debug para testar importação

GITHUB_JSON_BASE="https://raw.githubusercontent.com/guilhermeasn/loteria.json/master/data"

# Teste com 3 loterias
loterias_teste=("megasena" "lotofacil" "maismilionaria")

for loteria_id in "${loterias_teste[@]}"; do
    echo "=== Testando: $loteria_id ==="

    # Baixar JSON
    json_url="${GITHUB_JSON_BASE}/${loteria_id}.json"
    json_file="/tmp/${loteria_id}.json"

    echo "URL: $json_url"

    if curl -s -f "$json_url" -o "$json_file"; then
        echo "✓ Download OK"

        # Contar concursos
        if command -v jq &> /dev/null; then
            total=$(jq 'length' "$json_file")
            echo "✓ Total de concursos: $total"

            # Pegar primeiro concurso
            primeiro=$(jq -r 'to_entries | .[0] | "\(.key): \(.value)"' "$json_file")
            echo "✓ Primeiro concurso: $primeiro"

            # Testar criação de JSON para Supabase
            jq -r --arg loteria "$loteria_id" 'to_entries | .[0] | "{\"tipo_loteria\":\"\($loteria)\",\"numero_concurso\":\(.key),\"dezenas\":\(.value)}"' "$json_file"
        else
            echo "⚠ jq não disponível"
        fi
    else
        echo "❌ Erro no download"
    fi

    echo ""
done
