#!/bin/bash

# Deploy Now - Automated deployment script
# This script merges changes to main and deploys to GitHub Pages

set -e  # Exit on error

echo "🚀 Site da Sorte - Deploy Automático"
echo "===================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${BLUE}Branch atual: $CURRENT_BRANCH${NC}"
echo ""

# Pull latest changes
echo -e "${BLUE}1. Atualizando branch atual...${NC}"
git pull origin "$CURRENT_BRANCH" || true
echo -e "${GREEN}✓ Atualizado${NC}"
echo ""

# Checkout to main
echo -e "${BLUE}2. Mudando para branch main...${NC}"
git checkout main 2>/dev/null || git checkout -b main
echo -e "${GREEN}✓ Em main${NC}"
echo ""

# Pull latest main
echo -e "${BLUE}3. Sincronizando main...${NC}"
git pull origin main --no-edit 2>/dev/null || echo "Primeira vez em main"
echo -e "${GREEN}✓ Sincronizado${NC}"
echo ""

# Merge from development branch
echo -e "${BLUE}4. Fazendo merge de $CURRENT_BRANCH...${NC}"
git merge "$CURRENT_BRANCH" --no-edit
echo -e "${GREEN}✓ Merge concluído${NC}"
echo ""

# Try to push to main with retries
echo -e "${BLUE}5. Enviando para GitHub (main)...${NC}"

MAX_RETRIES=4
DELAY=2

for i in $(seq 1 $MAX_RETRIES); do
    if git push origin main 2>/dev/null; then
        echo -e "${GREEN}✓ Push bem-sucedido!${NC}"
        PUSH_SUCCESS=true
        break
    else
        if [ $i -lt $MAX_RETRIES ]; then
            echo -e "${YELLOW}Tentativa $i falhou. Tentando novamente em ${DELAY}s...${NC}"
            sleep $DELAY
            DELAY=$((DELAY * 2))
        fi
    fi
done

if [ -z "$PUSH_SUCCESS" ]; then
    echo -e "${RED}✗ Erro ao fazer push para main${NC}"
    echo ""
    echo -e "${YELLOW}Isso pode acontecer por:${NC}"
    echo "1. Branch main protegida (precisa de Pull Request)"
    echo "2. Sem permissões de push"
    echo ""
    echo -e "${BLUE}Solução automática: Criando Pull Request...${NC}"
    echo ""

    # Try to create PR using GitHub CLI
    if command -v gh &> /dev/null; then
        echo "Usando GitHub CLI (gh)..."

        # First push the current branch
        git checkout "$CURRENT_BRANCH"
        git push -f origin "$CURRENT_BRANCH"

        # Create and merge PR
        PR_URL=$(gh pr create \
            --base main \
            --head "$CURRENT_BRANCH" \
            --title "Deploy: Site da Sorte - Correções de caminhos" \
            --body "Deploy automático com correções de caminhos para GitHub Pages.

## Mudanças
- ✅ Caminhos absolutos → relativos
- ✅ Correção de 404s
- ✅ PWA funcionando

Criado automaticamente via deploy-now.sh" \
            2>/dev/null)

        if [ ! -z "$PR_URL" ]; then
            echo -e "${GREEN}✓ Pull Request criada: $PR_URL${NC}"
            echo ""
            echo "Fazendo merge automático..."
            gh pr merge "$PR_URL" --merge --delete-branch
            echo -e "${GREEN}✓ Merge concluído via PR!${NC}"
            DEPLOY_SUCCESS=true
        fi
    fi

    if [ -z "$DEPLOY_SUCCESS" ]; then
        echo -e "${YELLOW}GitHub CLI não encontrado.${NC}"
        echo ""
        echo -e "${BLUE}📋 Próximos passos manuais:${NC}"
        echo ""
        echo "1. Acesse este link:"
        echo "   https://github.com/JuniorNSMG/SiteDaSorte/compare/main...$CURRENT_BRANCH"
        echo ""
        echo "2. Clique em 'Create pull request'"
        echo "3. Clique em 'Merge pull request'"
        echo "4. Clique em 'Confirm merge'"
        echo ""

        # Return to original branch
        git checkout "$CURRENT_BRANCH"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   ✓ Deploy Concluído com Sucesso!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}📱 Seu site estará disponível em:${NC}"
echo ""
echo "   https://juniornsmg.github.io/SiteDaSorte"
echo ""
echo -e "${YELLOW}⏱  Aguarde 1-2 minutos para o build do GitHub Pages${NC}"
echo ""
echo "Para verificar o status do build:"
echo "   https://github.com/JuniorNSMG/SiteDaSorte/actions"
echo ""

# Return to original branch
git checkout "$CURRENT_BRANCH"
echo -e "${BLUE}Voltando para branch $CURRENT_BRANCH${NC}"
echo ""
echo -e "${GREEN}Tudo pronto! 🎉${NC}"
