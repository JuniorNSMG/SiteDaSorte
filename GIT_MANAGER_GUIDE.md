# Git Manager - Guia de Uso

Script interativo para facilitar operações Git no projeto Site da Sorte.

## Como Usar

```bash
./git-manager.sh
```

Ou, se estiver no diretório do projeto:

```bash
bash git-manager.sh
```

## Funcionalidades

### 1️⃣ Status do Repositório
- Mostra arquivos modificados
- Lista branches disponíveis
- Exibe branch atual

### 2️⃣ Commit Mudanças
- Adiciona arquivos (todos ou específicos)
- Cria commit com mensagem
- Adiciona automaticamente link da sessão

**Uso:**
- Escolha se quer adicionar todos os arquivos
- Digite a mensagem do commit
- Pronto!

### 3️⃣ Push para Branch Atual
- Envia commits para o GitHub
- Tem retry automático em caso de falha
- Mostra confirmação antes de executar

### 4️⃣ Merge para Main e Push ⭐
**Esta é a opção para publicar!**

Executa automaticamente:
1. Muda para branch `main`
2. Puxa últimas atualizações
3. Faz merge da branch atual
4. Envia para GitHub
5. Volta para branch anterior

**Perfeito para:** Publicar seu trabalho na branch principal

### 5️⃣ Restaurar Arquivo
Desfaz mudanças em arquivos:

**Opção 1:** Remove do staging (desfaz `git add`)
**Opção 2:** Descarta todas as mudanças (volta ao último commit)
**Opção 3:** Restaura de commit específico

⚠️ **CUIDADO:** Opção 2 apaga mudanças permanentemente!

### 6️⃣ Criar Nova Branch
- Cria branch a partir da atual
- Já faz checkout automaticamente

**Exemplo:** Criar branch `feature/novo-recurso`

### 7️⃣ Trocar de Branch
- Lista todas as branches
- Permite trocar rapidamente
- Mostra branches remotas também

### 8️⃣ Ver Histórico (Log)
- Mostra últimos 20 commits
- Formato gráfico colorido
- Inclui branches e tags

### 9️⃣ Deploy para GitHub Pages 🚀
**Configura automaticamente GitHub Pages!**

Duas opções:
- **Com GitHub CLI (`gh`):** Automático
- **Sem `gh`:** Mostra instruções manuais

Após configurar, seu site ficará em:
```
https://username.github.io/SiteDaSorte
```

## Exemplos de Fluxo de Trabalho

### Publicar Mudanças no GitHub Pages

```bash
./git-manager.sh

# No menu:
# 1. Opção 2: Commit mudanças
# 2. Opção 4: Merge para main e push
# 3. Opção 9: Deploy GitHub Pages (primeira vez)
# 4. Aguardar ~1 minuto
# 5. Acessar https://username.github.io/SiteDaSorte
```

### Criar Feature Nova

```bash
./git-manager.sh

# No menu:
# 1. Opção 6: Criar nova branch
#    Nome: feature/nova-funcionalidade
# 2. [Faça suas mudanças nos arquivos]
# 3. Opção 2: Commit mudanças
# 4. Opção 3: Push para branch atual
```

### Desfazer Mudança Errada

```bash
./git-manager.sh

# No menu:
# 1. Opção 5: Restaurar arquivo
# 2. Digite o nome do arquivo
# 3. Escolha opção 2 (descartar mudanças)
```

### Ver o que Foi Feito

```bash
./git-manager.sh

# No menu:
# 1. Opção 1: Ver status atual
# 2. Opção 8: Ver histórico de commits
```

## Requisitos

### Obrigatórios
- Git instalado
- Repositório Git inicializado
- Remote configurado (origin)

### Opcionais
- GitHub CLI (`gh`) - Para deploy automático do GitHub Pages
  - Instalar: `brew install gh`
  - Autenticar: `gh auth login`

## Cores do Menu

- 🔵 **Azul:** Títulos e menus
- 🟢 **Verde:** Operações bem-sucedidas
- 🟡 **Amarelo:** Avisos
- 🔴 **Vermelho:** Erros

## Atalhos Úteis

### Sair do Script
- Opção 0 ou Ctrl+C

### Voltar ao Menu
- Pressione Enter após cada operação

## Troubleshooting

### "Permission denied"
```bash
chmod +x git-manager.sh
```

### "gh: command not found"
Duas opções:
1. Instalar gh: `brew install gh`
2. Usar configuração manual do GitHub Pages (script mostra o link)

### Conflitos no Merge
Se aparecer conflito ao fazer merge para main:
1. Resolva os conflitos manualmente
2. `git add .`
3. `git commit -m "Resolve conflicts"`
4. `git push`

### Erro no Push
O script já tenta 4 vezes automaticamente com delays.
Se persistir:
- Verifique conexão com internet
- Verifique permissões no GitHub
- Tente `git push -f` (com cuidado!)

## Configuração Manual do GitHub Pages

Se não tiver `gh` instalado:

1. Acesse: `https://github.com/seu-usuario/SiteDaSorte/settings/pages`
2. Em **Source**, selecione:
   - Branch: `main`
   - Folder: `/ (root)`
3. Clique em **Save**
4. Aguarde ~1 minuto
5. Acesse: `https://seu-usuario.github.io/SiteDaSorte`

## Dicas Pro

### Commit Frequente
- Faça commits pequenos e frequentes
- Use mensagens descritivas
- Um commit = uma funcionalidade/correção

### Branch Strategy
- `main` - Código de produção
- `develop` - Desenvolvimento
- `feature/` - Novas funcionalidades
- `fix/` - Correções de bugs

### Antes de Merge
- Teste tudo localmente
- Verifique que não há erros
- Rode `git status` para ver o que vai

## Segurança

✅ **O script SEMPRE pede confirmação para:**
- Push
- Merge para main
- Descartar mudanças

❌ **O script NUNCA:**
- Faz force push sem avisar
- Deleta branches automaticamente
- Sobrescreve arquivos sem perguntar

## Próximos Passos

Após configurar GitHub Pages:
1. ✅ Acesse seu site publicado
2. ✅ Compartilhe a URL
3. ✅ Configure domínio customizado (opcional)
4. ✅ Adicione SSL (automático no GitHub Pages)

---

**Desenvolvido para Site da Sorte 🍀**
