#!/bin/bash

# DEPLOY AUTOMÁTICO - Faz TUDO sozinho sem perguntar nada!

cd "$(dirname "$0")"

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          🤖 DEPLOY AUTOMÁTICO - SEM PERGUNTAS         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Pegar branch atual
CURRENT_BRANCH=$(git branch --show-current)

if [[ "$CURRENT_BRANCH" == "main" ]]; then
    echo -e "${YELLOW}⚠️  Você já está na branch main!${NC}"
    echo ""
    sleep 3
    exit 0
fi

echo -e "${BLUE}📍 Branch: ${YELLOW}$CURRENT_BRANCH${NC}"
echo ""

# Verificar mudanças não commitadas
if [[ -n $(git status -s) ]]; then
    echo -e "${RED}❌ Há mudanças não commitadas!${NC}"
    echo ""
    echo "Mudanças pendentes:"
    git status -s
    echo ""
    echo -e "${YELLOW}Fazendo commit automático...${NC}"

    git add -A
    git commit -m "Auto-commit antes do deploy

Commit automático de mudanças pendentes antes do deploy.

https://claude.ai/code/session_4a8af5fa-2925-402e-9299-2df67b682408"

    git push -u origin "$CURRENT_BRANCH"
    echo ""
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Fazer fetch
echo -e "${BLUE}📡 Atualizando referências...${NC}"
git fetch origin -q

# Fazer checkout para main
echo -e "${BLUE}🔄 Mudando para main...${NC}"
git checkout main -q

# Atualizar main
echo -e "${BLUE}⬇️  Atualizando main...${NC}"
git pull origin main -q

# Fazer merge
echo -e "${BLUE}🔀 Fazendo merge...${NC}"
if git merge "$CURRENT_BRANCH" --no-edit -q; then
    echo -e "${GREEN}   ✓ Merge concluído${NC}"
else
    echo -e "${RED}❌ Erro no merge!${NC}"
    echo ""
    echo "Abortando e voltando..."
    git merge --abort
    git checkout "$CURRENT_BRANCH" -q
    sleep 3
    exit 1
fi

# Tentar push direto
echo -e "${BLUE}⬆️  Tentando push direto para main...${NC}"

if git push origin main 2>/dev/null; then
    # SUCESSO!
    echo -e "${GREEN}   ✓ Push direto bem-sucedido!${NC}"
    git checkout "$CURRENT_BRANCH" -q

    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}✅✅✅ DEPLOY CONCLUÍDO! ✅✅✅${NC}"
    echo ""
    echo -e "${GREEN}🎉 Site será atualizado em ~30-60 segundos!${NC}"
    echo ""
    echo "🌐 Site: https://juniorNSMG.github.io/SiteDaSorte/"
    echo "📊 Deploy: https://github.com/JuniorNSMG/SiteDaSorte/actions"
    echo ""
    sleep 5
    exit 0
else
    # FALHOU - Criar PR
    echo -e "${YELLOW}   ⚠️  Push direto bloqueado (branch protegida)${NC}"
    echo ""

    # Voltar para branch original
    git checkout "$CURRENT_BRANCH" -q

    echo -e "${BLUE}📝 Criando Pull Request automaticamente...${NC}"
    echo ""

    # Construir URL do PR
    PR_URL="https://github.com/JuniorNSMG/SiteDaSorte/compare/main...${CURRENT_BRANCH}?expand=1"

    # Tentar com gh CLI primeiro
    if command -v gh &> /dev/null; then
        echo -e "${BLUE}   Usando GitHub CLI...${NC}"

        PR_BODY="## 🚀 Deploy Automático

### Mudanças neste PR:
$(git log main..${CURRENT_BRANCH} --oneline --pretty=format:'- %s' | head -10)

### 📊 Estatísticas:
- Branch: \`${CURRENT_BRANCH}\`
- Commits: $(git rev-list --count main..${CURRENT_BRANCH})
- Arquivos modificados: $(git diff --name-only main..${CURRENT_BRANCH} | wc -l)

🤖 PR criado automaticamente por DEPLOY-AUTOMATICO.command

https://claude.ai/code/session_4a8af5fa-2925-402e-9299-2df67b682408"

        if gh pr create --base main --head "$CURRENT_BRANCH" \
            --title "🚀 Deploy: $(date '+%d/%m/%Y %H:%M')" \
            --body "$PR_BODY" 2>/dev/null; then

            echo ""
            echo -e "${GREEN}✅ Pull Request criado com sucesso!${NC}"
            echo ""
            echo -e "${YELLOW}Abrindo PR no navegador...${NC}"
            sleep 2

            # Abrir PR no navegador
            gh pr view --web 2>/dev/null || open "$PR_URL"

            echo ""
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo -e "${GREEN}✅ PR CRIADO! Agora é só fazer o merge no GitHub! ✅${NC}"
            echo ""
            sleep 5
            exit 0
        fi
    fi

    # Fallback: Abrir navegador direto
    echo -e "${BLUE}   Abrindo navegador...${NC}"
    echo ""

    # Abrir no navegador (Mac)
    open "$PR_URL" 2>/dev/null || echo "Acesse: $PR_URL"

    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}✅ NAVEGADOR ABERTO!${NC}"
    echo ""
    echo "📝 No GitHub:"
    echo "   1. Revise as mudanças"
    echo "   2. Clique em 'Create pull request'"
    echo "   3. Clique em 'Merge pull request'"
    echo "   4. Confirme o merge"
    echo ""
    echo "🌐 Após o merge, site atualiza em ~30-60 segundos!"
    echo ""
    echo -e "${YELLOW}💡 Se o navegador não abriu, acesse:${NC}"
    echo "   $PR_URL"
    echo ""
    sleep 10
    exit 0
fi
