#!/bin/bash

# Verificar o que realmente está no banco

SUPABASE_URL="https://kbczmmgfkbnuyfwrlmtu.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtiY3ptbWdma2JudXlmd3JsbXR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA0ODA5NDgsImV4cCI6MjA4NjA1Njk0OH0.2l6oad-2j_CGLRfWEFrJI7jvFHcLWTG1gEkEtK8oPlY"

echo "=== Consultando banco de dados Supabase ==="
echo ""

# Contar por tipo de loteria
echo "Contagem por tipo de loteria:"
echo ""

for loteria in megasena lotofacil quina lotomania timemania duplasena diadesorte supersete maismilionaria; do
    count=$(curl -s "${SUPABASE_URL}/rest/v1/loterias?tipo_loteria=eq.$loteria&select=count" \
        -H "apikey: ${SUPABASE_KEY}" \
        -H "Authorization: Bearer ${SUPABASE_KEY}" \
        -H "Prefer: count=exact" -I | grep -i "content-range" | grep -o '[0-9]*$')

    if [[ -z "$count" ]]; then
        count=0
    fi

    printf "%-20s: %d concursos\n" "$loteria" "$count"
done

echo ""
echo "Primeiros 5 registros (qualquer loteria):"
curl -s "${SUPABASE_URL}/rest/v1/loterias?select=tipo_loteria,numero_concurso,dezenas&limit=5" \
    -H "apikey: ${SUPABASE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_KEY}" | jq '.'
