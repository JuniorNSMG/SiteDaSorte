#!/bin/bash

# DEPLOY PARA MAIN - Faz merge automático da branch atual para main

cd "$(dirname "$0")"

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       🚀 DEPLOY PARA MAIN - GitHub Pages              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Pegar branch atual
CURRENT_BRANCH=$(git branch --show-current)

if [[ "$CURRENT_BRANCH" == "main" ]]; then
    echo -e "${YELLOW}⚠️  Você já está na branch main!${NC}"
    echo ""
    echo "Pressione qualquer tecla para sair..."
    read -n 1 -s
    exit 0
fi

echo -e "${BLUE}📍 Branch atual: ${YELLOW}$CURRENT_BRANCH${NC}"
echo ""

# Verificar mudanças não commitadas
if [[ -n $(git status -s) ]]; then
    echo -e "${RED}❌ Há mudanças não commitadas!${NC}"
    echo ""
    echo "Mudanças pendentes:"
    git status -s
    echo ""
    echo -e "${YELLOW}Por favor, faça commit de todas as mudanças antes de fazer deploy.${NC}"
    echo ""
    echo "Pressione qualquer tecla para sair..."
    read -n 1 -s
    exit 1
fi

# Confirmar deploy
echo -e "${YELLOW}Este comando irá:${NC}"
echo "  1. Fazer checkout para main"
echo "  2. Fazer merge de $CURRENT_BRANCH em main"
echo "  3. Fazer push para GitHub (dispara deploy automático)"
echo "  4. Voltar para $CURRENT_BRANCH"
echo ""
echo -e "${RED}⚠️  As mudanças ficarão VISÍVEIS NO SITE após alguns segundos!${NC}"
echo ""
read -p "Deseja continuar? (s/n): " confirma

if [[ $confirma != "s" ]]; then
    echo "Deploy cancelado."
    exit 0
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Fazer fetch para garantir que está atualizado
echo -e "${BLUE}📡 Atualizando referências do GitHub...${NC}"
git fetch origin

# Fazer checkout para main
echo -e "${BLUE}🔄 Mudando para branch main...${NC}"
git checkout main

if [[ $? -ne 0 ]]; then
    echo -e "${RED}❌ Erro ao mudar para main!${NC}"
    exit 1
fi

# Atualizar main com origin
echo -e "${BLUE}⬇️  Atualizando main com GitHub...${NC}"
git pull origin main

# Fazer merge
echo -e "${BLUE}🔀 Fazendo merge de $CURRENT_BRANCH em main...${NC}"
git merge "$CURRENT_BRANCH" --no-edit

if [[ $? -ne 0 ]]; then
    echo -e "${RED}❌ Erro no merge! Resolva os conflitos manualmente.${NC}"
    echo ""
    echo "Para voltar:"
    echo "  git merge --abort"
    echo "  git checkout $CURRENT_BRANCH"
    exit 1
fi

# Push para main (dispara GitHub Pages)
echo -e "${BLUE}⬆️  Enviando para GitHub (main)...${NC}"

# Tentar push com retry
MAX_RETRIES=4
RETRY_COUNT=0
PUSH_SUCCESS=false

while [[ $RETRY_COUNT -lt $MAX_RETRIES ]]; do
    if [[ $RETRY_COUNT -gt 0 ]]; then
        WAIT_TIME=$((2 ** RETRY_COUNT))
        echo -e "${YELLOW}   Tentativa $((RETRY_COUNT + 1))/$MAX_RETRIES após ${WAIT_TIME}s...${NC}"
        sleep $WAIT_TIME
    fi

    if git push origin main; then
        PUSH_SUCCESS=true
        break
    fi

    RETRY_COUNT=$((RETRY_COUNT + 1))
done

if [[ $PUSH_SUCCESS == false ]]; then
    echo -e "${RED}❌ Erro ao fazer push após $MAX_RETRIES tentativas!${NC}"
    echo ""
    echo "Você está na branch main. Para voltar:"
    echo "  git checkout $CURRENT_BRANCH"
    exit 1
fi

# Voltar para branch original
echo -e "${BLUE}↩️  Voltando para $CURRENT_BRANCH...${NC}"
git checkout "$CURRENT_BRANCH"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}✅✅✅ DEPLOY CONCLUÍDO COM SUCESSO! ✅✅✅${NC}"
echo ""
echo -e "${GREEN}🎉 Suas mudanças estão sendo publicadas no GitHub Pages!${NC}"
echo ""
echo "📊 Acompanhe o deploy:"
echo "   https://github.com/JuniorNSMG/SiteDaSorte/actions"
echo ""
echo "🌐 Site estará atualizado em ~30-60 segundos:"
echo "   https://juniorNSMG.github.io/SiteDaSorte/"
echo ""
echo -e "${BLUE}💡 Dica: Use CTRL+clique (Mac) para abrir os links${NC}"
echo ""
echo "Pressione qualquer tecla para fechar..."
read -n 1 -s
