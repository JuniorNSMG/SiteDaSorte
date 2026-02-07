#!/bin/bash

# Script de Deploy - Duplo Clique
# Coloque este arquivo na pasta SiteDaSorte e dê duplo clique!

# Ir para o diretório do script
cd "$(dirname "$0")"

clear
echo "╔════════════════════════════════════════╗"
echo "║   🍀 Site da Sorte - Deploy Rápido   ║"
echo "╔════════════════════════════════════════╗"
echo ""

# Puxar atualizações
echo "📥 Baixando últimas atualizações..."
git pull
echo ""

# Checkout main
echo "🔄 Mudando para branch main..."
git checkout main 2>/dev/null || git checkout -b main
git pull origin main --no-edit 2>/dev/null || echo "Primeira vez"
echo ""

# Merge
echo "🔀 Fazendo merge..."
git merge claude/add-design-system-joUB0 --no-edit
echo ""

# Push
echo "📤 Enviando para GitHub..."
git push origin main 2>/dev/null

if [ $? -eq 0 ]; then
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║        ✅ DEPLOY CONCLUÍDO! ✅         ║"
    echo "╔════════════════════════════════════════╗"
    echo ""
    echo "🌐 Seu site estará em:"
    echo "   https://juniornsmg.github.io/SiteDaSorte"
    echo ""
    echo "⏱  Aguarde 1-2 minutos para o build"
    echo ""
else
    echo ""
    echo "⚠️  Erro no push automático"
    echo ""
    echo "📋 Abra este link no navegador:"
    echo ""
    echo "https://github.com/JuniorNSMG/SiteDaSorte/compare/main...claude/add-design-system-joUB0"
    echo ""
    echo "Depois:"
    echo "1. Clique 'Create pull request'"
    echo "2. Clique 'Merge pull request'"
    echo "3. Clique 'Confirm merge'"
    echo ""
fi

# Voltar para branch original
git checkout claude/add-design-system-joUB0 2>/dev/null

echo ""
echo "Pressione qualquer tecla para fechar..."
read -n 1 -s
