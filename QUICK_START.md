# Quick Start Guide 🚀

## Servidor já está rodando!

O projeto está **executando agora** em:

```
http://localhost:8000
```

## Como Acessar

1. **No navegador do servidor**: Abra `http://localhost:8000`
2. **De outro dispositivo na mesma rede**: Acesse `http://[IP-DO-SERVIDOR]:8000`

## Recursos Disponíveis

### 📱 Teste o PWA
- Abra no Chrome/Edge e clique no botão "Instalar App"
- No celular, adicione à tela inicial
- Teste o modo offline (desconecte a internet)

### 🎨 Verifique o Design
- Paleta de cores: Consulte `DESIGN_SYSTEM.md`
- Cores em JSON: `src/assets/colors.json`
- Estilos customizados: `src/css/styles.css`

### 🔍 Explorar o Código

**Frontend:**
- `index.html` - Estrutura principal
- `src/js/app.js` - Lógica da aplicação
- `src/css/styles.css` - Estilos customizados

**PWA:**
- `manifest.json` - Configuração do PWA
- `sw.js` - Service Worker
- `src/js/sw-register.js` - Registro do SW

**Design:**
- `DESIGN_SYSTEM.md` - Sistema de design completo
- `src/assets/colors.json` - Paleta de cores
- `icons/` - Ícones do PWA (SVG)

## Comandos Úteis

### Parar o Servidor
```bash
pkill -f "python3 -m http.server"
```

### Reiniciar o Servidor
```bash
pkill -f "python3 -m http.server"
python3 -m http.server 8000
```

### Iniciar em Outra Porta
```bash
python3 -m http.server 3000
```

## Testando Funcionalidades

### ✅ Checklist de Testes

- [ ] **Carregamento**: Página carrega corretamente
- [ ] **API**: Resultados das loterias aparecem
- [ ] **Responsivo**: Teste em mobile (F12 → Device Toolbar)
- [ ] **PWA**: Botão "Instalar App" aparece
- [ ] **Offline**: Service Worker registrado (DevTools → Application)
- [ ] **Design**: Cores seguem a paleta definida
- [ ] **Performance**: Carregamento rápido
- [ ] **Acessibilidade**: Navegação por teclado funciona

### 🎯 Teste Específico das Loterias

Verifique se aparecem:
- ✅ Mega-Sena
- ✅ Lotofácil
- ✅ Quina
- ✅ Lotomania
- ✅ Timemania
- ✅ Dupla Sena
- ✅ Dia de Sorte
- ✅ Super Sete
- ✅ +Milionária

### 🔧 DevTools

**Chrome DevTools (F12):**

1. **Application Tab**
   - Manifest: Verifique ícones e configurações
   - Service Workers: Verifique se está registrado
   - Cache Storage: Veja dados em cache

2. **Network Tab**
   - Throttling: Teste em 3G lento
   - Offline: Desmarque "Disable cache" e recarregue

3. **Lighthouse**
   - Run audit para PWA, Performance, Accessibility

## Próximos Passos

1. **Personalizar Ícones**
   - Veja `icons/README.md` para instruções
   - Substitua os SVGs por PNGs profissionais

2. **Deploy**
   - GitHub Pages
   - Netlify
   - Vercel
   - Firebase Hosting

3. **Melhorias**
   - Adicionar modo escuro
   - Implementar filtros
   - Histórico de resultados
   - Notificações push

## Troubleshooting

### Servidor não inicia
```bash
# Verifique se a porta 8000 está em uso
lsof -i :8000

# Use outra porta
python3 -m http.server 3000
```

### API não responde
- Verifique conexão com internet
- A API pode estar temporariamente offline
- Dados em cache ainda estarão disponíveis

### Service Worker não registra
- Certifique-se que está usando HTTP/HTTPS (não file://)
- Limpe cache do navegador
- Abra em aba anônima

### Ícones não aparecem
- Verifique que os arquivos SVG existem em `/icons/`
- Rode `./create-icons.sh` novamente se necessário
- Verifique console do navegador para erros

## Performance Tips

1. **Primeira Visita**: ~2-3 segundos (depende da API)
2. **Visitas Subsequentes**: <1 segundo (cache)
3. **Offline**: Instantâneo (Service Worker)

## Documentação Completa

- **README.md** - Documentação principal
- **DESIGN_SYSTEM.md** - Guia de design
- **icons/README.md** - Guia de ícones

---

**Divirta-se testando! 🍀**

Se encontrar problemas, consulte o README.md para mais detalhes.
