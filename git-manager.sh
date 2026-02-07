#!/bin/bash

# Git Manager - Site da Sorte
# Script para facilitar operações git

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

show_menu() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}   Git Manager - Site da Sorte${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    echo "1) Status do repositório"
    echo "2) Commit mudanças"
    echo "3) Push para branch atual"
    echo "4) Merge para main e push"
    echo "5) Restaurar arquivo"
    echo "6) Criar nova branch"
    echo "7) Trocar de branch"
    echo "8) Ver histórico (log)"
    echo "9) Deploy para GitHub Pages"
    echo "0) Sair"
    echo ""
}

git_status() {
    echo -e "${BLUE}=== Status do Repositório ===${NC}"
    git status
    echo ""
    git branch -v
}

git_commit() {
    echo -e "${BLUE}=== Commit Mudanças ===${NC}"
    git status
    echo ""
    read -p "Deseja adicionar todos os arquivos? (y/n): " add_all

    if [ "$add_all" = "y" ]; then
        git add -A
    else
        read -p "Digite os arquivos para adicionar (ex: index.html src/): " files
        git add $files
    fi

    echo ""
    echo "Digite a mensagem do commit:"
    read -p "> " commit_msg

    git commit -m "$commit_msg

https://claude.ai/code/session_012dYJmhVHYHpNkw1xS4p8jX"

    echo -e "${GREEN}✓ Commit realizado!${NC}"
}

git_push() {
    echo -e "${BLUE}=== Push para Branch Atual ===${NC}"
    current_branch=$(git branch --show-current)
    echo "Branch atual: $current_branch"
    echo ""

    read -p "Confirma push para origin/$current_branch? (y/n): " confirm

    if [ "$confirm" = "y" ]; then
        git push -u origin "$current_branch" || \
        (sleep 2 && git push -u origin "$current_branch") || \
        (sleep 4 && git push -u origin "$current_branch") || \
        (sleep 8 && git push -u origin "$current_branch")

        echo -e "${GREEN}✓ Push realizado!${NC}"
    else
        echo -e "${YELLOW}Push cancelado.${NC}"
    fi
}

merge_to_main() {
    echo -e "${BLUE}=== Merge para Main e Push ===${NC}"
    current_branch=$(git branch --show-current)

    echo "Branch atual: $current_branch"
    echo ""
    echo -e "${YELLOW}ATENÇÃO: Isso vai:${NC}"
    echo "1. Fazer checkout para main"
    echo "2. Fazer merge de $current_branch em main"
    echo "3. Push para origin/main"
    echo ""

    read -p "Confirma? (y/n): " confirm

    if [ "$confirm" = "y" ]; then
        # Fetch latest
        git fetch origin

        # Checkout main
        git checkout main 2>/dev/null || git checkout -b main

        # Pull latest main
        git pull origin main --no-edit 2>/dev/null || echo "Primeira vez em main"

        # Merge
        git merge "$current_branch" --no-edit

        # Push
        git push -u origin main || \
        (sleep 2 && git push -u origin main) || \
        (sleep 4 && git push -u origin main)

        echo -e "${GREEN}✓ Merge e push para main realizado!${NC}"
        echo ""
        echo "Voltando para branch anterior..."
        git checkout "$current_branch"
    else
        echo -e "${YELLOW}Operação cancelada.${NC}"
    fi
}

restore_file() {
    echo -e "${BLUE}=== Restaurar Arquivo ===${NC}"
    echo "Arquivos modificados:"
    git status --short
    echo ""

    read -p "Digite o caminho do arquivo para restaurar: " file_path

    if [ -z "$file_path" ]; then
        echo -e "${RED}Nenhum arquivo especificado.${NC}"
        return
    fi

    echo ""
    echo -e "${YELLOW}Opções:${NC}"
    echo "1) Restaurar do staging (desfazer git add)"
    echo "2) Restaurar do último commit (descartar mudanças)"
    echo "3) Restaurar de commit específico"
    read -p "Escolha: " restore_option

    case $restore_option in
        1)
            git restore --staged "$file_path"
            echo -e "${GREEN}✓ Arquivo removido do staging${NC}"
            ;;
        2)
            read -p "ATENÇÃO: Isso descartará todas as mudanças. Confirma? (y/n): " confirm
            if [ "$confirm" = "y" ]; then
                git restore "$file_path"
                echo -e "${GREEN}✓ Arquivo restaurado${NC}"
            fi
            ;;
        3)
            git log --oneline -10
            read -p "Digite o hash do commit: " commit_hash
            git restore --source="$commit_hash" "$file_path"
            echo -e "${GREEN}✓ Arquivo restaurado do commit $commit_hash${NC}"
            ;;
    esac
}

create_branch() {
    echo -e "${BLUE}=== Criar Nova Branch ===${NC}"
    read -p "Nome da nova branch: " branch_name

    if [ -z "$branch_name" ]; then
        echo -e "${RED}Nome inválido.${NC}"
        return
    fi

    git checkout -b "$branch_name"
    echo -e "${GREEN}✓ Branch '$branch_name' criada e ativada!${NC}"
}

switch_branch() {
    echo -e "${BLUE}=== Trocar de Branch ===${NC}"
    echo "Branches disponíveis:"
    git branch -a
    echo ""

    read -p "Digite o nome da branch: " branch_name

    if [ -z "$branch_name" ]; then
        echo -e "${RED}Nome inválido.${NC}"
        return
    fi

    git checkout "$branch_name"
    echo -e "${GREEN}✓ Branch trocada!${NC}"
}

git_log() {
    echo -e "${BLUE}=== Histórico de Commits ===${NC}"
    git log --oneline --graph --decorate --all -20
}

deploy_github_pages() {
    echo -e "${BLUE}=== Deploy para GitHub Pages ===${NC}"
    echo ""
    echo "Este script irá:"
    echo "1. Garantir que main está atualizado"
    echo "2. Configurar GitHub Pages via gh CLI"
    echo ""

    read -p "Continuar? (y/n): " confirm

    if [ "$confirm" != "y" ]; then
        echo -e "${YELLOW}Cancelado.${NC}"
        return
    fi

    # Verificar se gh está instalado
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}GitHub CLI (gh) não encontrado.${NC}"
        echo "Instale com: brew install gh"
        echo ""
        echo -e "${YELLOW}Configuração manual:${NC}"
        echo "1. Vá para: https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/settings/pages"
        echo "2. Em 'Source', selecione 'Deploy from a branch'"
        echo "3. Selecione branch 'main' e pasta '/ (root)'"
        echo "4. Clique em 'Save'"
        return
    fi

    # Configurar GitHub Pages
    echo "Configurando GitHub Pages..."
    gh api repos/:owner/:repo/pages \
        -X POST \
        -f source[branch]=main \
        -f source[path]=/

    echo ""
    echo -e "${GREEN}✓ GitHub Pages configurado!${NC}"
    echo ""
    echo "Seu site estará disponível em:"
    echo "https://$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/' | sed 's/\//.github.io\//')"
}

# Menu principal
while true; do
    show_menu
    read -p "Escolha uma opção: " choice
    echo ""

    case $choice in
        1) git_status ;;
        2) git_commit ;;
        3) git_push ;;
        4) merge_to_main ;;
        5) restore_file ;;
        6) create_branch ;;
        7) switch_branch ;;
        8) git_log ;;
        9) deploy_github_pages ;;
        0)
            echo -e "${GREEN}Até logo!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Opção inválida!${NC}"
            ;;
    esac

    echo ""
    read -p "Pressione Enter para continuar..."
    clear
done
