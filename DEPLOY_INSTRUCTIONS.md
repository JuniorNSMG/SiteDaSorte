# 🚀 Instruções de Deploy - GitHub Pages

## Status Atual

✅ **Código Completo:** Todos os arquivos estão prontos
✅ **Branch Criada:** `claude/add-design-system-joUB0`
✅ **Commits Feitos:** 2 commits com todo o projeto
✅ **Push Realizado:** Código está no GitHub

⚠️ **Próximo Passo:** Configurar GitHub Pages

---

## Opção 1: Deploy Automático (Via Script)

O jeito mais fácil! Use o Git Manager:

```bash
# No seu Mac, dentro da pasta SiteDaSorte

# 1. Puxar os arquivos do GitHub
git pull origin claude/add-design-system-joUB0

# 2. Executar o Git Manager
./git-manager.sh

# 3. Escolher opção 4 (Merge para main e push)
# 4. Escolher opção 9 (Deploy GitHub Pages)
```

Se der erro 403 no push para main, siga para Opção 2.

---

## Opção 2: Via Pull Request (Recomendado)

### Passo 1: Criar Pull Request

Acesse no navegador:
```
https://github.com/JuniorNSMG/SiteDaSorte/compare/main...claude/add-design-system-joUB0
```

Ou:
1. Vá para: https://github.com/JuniorNSMG/SiteDaSorte
2. Clique em "Pull requests"
3. Clique em "New pull request"
4. Base: `main` ← Compare: `claude/add-design-system-joUB0`
5. Clique em "Create pull request"
6. Adicione título: "Site da Sorte PWA - Design System Completo"
7. Clique em "Create pull request"
8. Clique em "Merge pull request"
9. Clique em "Confirm merge"

### Passo 2: Configurar GitHub Pages

1. Vá para: https://github.com/JuniorNSMG/SiteDaSorte/settings/pages

2. Em **"Build and deployment"**:
   - Source: Deploy from a branch
   - Branch: `main`
   - Folder: `/ (root)`

3. Clique em **Save**

4. Aguarde ~1-2 minutos

5. Acesse seu site:
   ```
   https://juniornsmg.github.io/SiteDaSorte
   ```

---

## Opção 3: Via Terminal (Seu Mac)

Se você tiver acesso para push direto à main:

```bash
# No seu Mac, na pasta SiteDaSorte

# 1. Puxar mudanças
git fetch origin
git checkout main
git pull origin main

# 2. Fazer merge
git merge claude/add-design-system-joUB0

# 3. Enviar para GitHub
git push origin main
```

Depois, configure GitHub Pages (Passo 2 da Opção 2).

---

## Opção 4: GitHub Pages via Linha de Comando

Se tiver `gh` CLI instalado:

```bash
# 1. Instalar gh CLI (se não tiver)
brew install gh

# 2. Autenticar
gh auth login

# 3. Criar PR e fazer merge
gh pr create --base main --head claude/add-design-system-joUB0 \
  --title "Site da Sorte PWA" \
  --body "Deploy da aplicação completa com design system"

gh pr merge --merge --delete-branch

# 4. Configurar GitHub Pages
gh api repos/JuniorNSMG/SiteDaSorte/pages \
  -X POST \
  -f source[branch]=main \
  -f source[path]=/
```

---

## Verificar Deploy

### 1. Status do GitHub Pages

Acesse:
```
https://github.com/JuniorNSMG/SiteDaSorte/settings/pages
```

Você verá:
- ✅ **"Your site is live at..."** (se funcionou)
- ⏳ **"Your site is being built..."** (aguarde 1-2 min)
- ❌ **Erro** (veja Troubleshooting abaixo)

### 2. Verificar Build

Em:
```
https://github.com/JuniorNSMG/SiteDaSorte/actions
```

Procure por "pages build and deployment"

### 3. Acessar Site

```
https://juniornsmg.github.io/SiteDaSorte
```

---

## Troubleshooting

### ❌ Erro 403 ao fazer push para main

**Causa:** Branch protegida ou sem permissões

**Solução:** Use Pull Request (Opção 2)

### ❌ "GitHub Pages is not enabled"

**Solução:**
1. Vá para Settings → Pages
2. Configure Source como "Deploy from a branch"
3. Selecione branch `main` e pasta `/`

### ❌ "404 - File not found"

**Causa:** GitHub Pages não encontrou index.html

**Verificar:**
1. `index.html` está na raiz do repositório?
2. Branch correta selecionada (main)?
3. Pasta correta (`/` root)?

**Solução:**
```bash
# Verificar estrutura
git ls-tree -r main --name-only | head -10

# Deve aparecer index.html na raiz
```

### ❌ "Site não carrega CSS/JS"

**Causa:** Caminhos absolutos não funcionam no GitHub Pages

**Verificação:**
- No `index.html`, os caminhos devem ser relativos
- Já estão corretos no projeto! ✅

### ❌ Build demora muito

**Normal:** Primeira build pode levar 3-5 minutos
**Subsequentes:** 30-60 segundos

---

## Após Deploy Bem-Sucedido

### ✅ Checklist

- [ ] Site abre corretamente
- [ ] Todas as loterias aparecem
- [ ] Cores estão corretas (paleta azul)
- [ ] Responsivo funciona (teste no celular)
- [ ] PWA pode ser instalado
- [ ] Service Worker registra
- [ ] Funciona offline

### 📱 Testar PWA

**Desktop (Chrome/Edge):**
1. Abra o site
2. Olhe na barra de endereço
3. Clique no ícone de instalação (+)
4. Clique em "Instalar"

**Mobile (Android - Chrome):**
1. Abra o site
2. Menu (⋮) → "Adicionar à tela inicial"
3. Confirme

**Mobile (iOS - Safari):**
1. Abra o site
2. Botão compartilhar
3. "Adicionar à Tela de Início"

### 🔗 Compartilhar

Seu site estará em:
```
https://juniornsmg.github.io/SiteDaSorte
```

### 🎨 Customizar Domínio (Opcional)

Se tiver um domínio próprio:

1. Em Settings → Pages → Custom domain
2. Digite: `seudominio.com`
3. Configure DNS:
   ```
   Type: CNAME
   Name: www
   Value: juniornsmg.github.io
   ```
4. Aguarde propagação DNS (até 24h)

---

## Atualizações Futuras

Quando fizer mudanças:

```bash
# 1. Fazer mudanças nos arquivos

# 2. Commit
git add .
git commit -m "feat: descrição da mudança"

# 3. Push
git push origin main

# 4. GitHub Pages atualiza automaticamente!
```

Ou use o Git Manager:
```bash
./git-manager.sh
# Opção 2 → Opção 3
```

---

## Monitoramento

### Analytics (Opcional)

Adicionar Google Analytics no `index.html`:

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXX');
</script>
```

### Uptime Monitoring

Use serviços gratuitos:
- UptimeRobot
- Pingdom
- StatusCake

---

## Suporte

### Documentação Oficial

- [GitHub Pages](https://docs.github.com/pages)
- [PWA Guide](https://web.dev/progressive-web-apps/)

### Logs Úteis

```bash
# Ver último deploy
gh api repos/JuniorNSMG/SiteDaSorte/pages/builds/latest

# Status do Pages
gh api repos/JuniorNSMG/SiteDaSorte/pages
```

---

## Resumo Rápido

**Mais fácil (GUI):**
1. GitHub.com → Pull Request → Merge
2. Settings → Pages → Configurar
3. Aguardar build
4. Acessar site

**Via Script (Terminal):**
```bash
git pull origin claude/add-design-system-joUB0
./git-manager.sh
# Opção 4 → Opção 9
```

**Seu site estará em:**
```
https://juniornsmg.github.io/SiteDaSorte
```

---

**Boa sorte! 🍀**

Se precisar de ajuda, consulte o GIT_MANAGER_GUIDE.md ou README.md
