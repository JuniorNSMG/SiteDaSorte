# Site da Sorte 🍀

Progressive Web App (PWA) para consulta de resultados das Loterias CAIXA em tempo real.

![Color Palette](docs/palette.png)

## 📋 Sobre o Projeto

Site da Sorte é uma aplicação web moderna e responsiva que permite aos usuários acompanhar os resultados mais recentes das principais loterias da CAIXA Econômica Federal do Brasil.

### Características

- ✅ **PWA (Progressive Web App)** - Instalável como aplicativo nativo
- ✅ **Mobile-First** - Otimizado para dispositivos móveis
- ✅ **Offline Support** - Funciona sem conexão com internet
- ✅ **Real-time Updates** - Atualização automática dos resultados
- ✅ **Design Moderno** - Interface limpa e profissional
- ✅ **Acessível** - Segue diretrizes WCAG AA

## 🎨 Design System

### Paleta de Cores

O projeto utiliza uma paleta de cores exclusiva baseada em tons de azul:

| Cor | Hex | Uso |
|-----|-----|-----|
| Dark Navy | `#1E293D` | Headers, footers, textos principais |
| Ocean Blue | `#006494` | Botões primários, badges |
| Sky Blue | `#247BA0` | Links, hover states |
| Light Blue | `#1B98E0` | Destaques, próximo sorteio |
| Ice White | `#E8F1F2` | Backgrounds claros |

**Cores Neutras Permitidas:**
- Branco (`#FFFFFF`)
- Cinza Claro (`#F5F5F5`)
- Cinza Médio (`#9CA3AF`) - Textos secundários
- Cinza Escuro (`#374151`) - Textos primários
- Preto (`#000000`) - Alto contraste

### Referências de Design

- **UI/UX Framework**: [UI/UX Pro Max Skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)
- **Estilo**: Minimalist + Glassmorphism elements
- **Tipografia**: System fonts (SF Pro, Segoe UI, Roboto)

## 🚀 Tecnologias

- **Frontend**: HTML5, CSS3, JavaScript (Vanilla)
- **Styling**: Tailwind CSS
- **PWA**: Service Workers, Web Manifest
- **API**: [Loterias CAIXA API](https://github.com/guto-alves/loterias-api)

## 📦 Estrutura do Projeto

```
SiteDaSorte/
├── index.html              # Página principal
├── manifest.json           # PWA manifest
├── sw.js                   # Service Worker
├── DESIGN_SYSTEM.md        # Documentação do design system
├── README.md               # Este arquivo
├── src/
│   ├── css/
│   │   └── styles.css      # Estilos customizados
│   ├── js/
│   │   ├── app.js          # Lógica principal
│   │   └── sw-register.js  # Registro do Service Worker
│   └── assets/
│       └── colors.json     # Paleta de cores
├── icons/                  # Ícones do PWA
├── screenshots/            # Screenshots para PWA
├── loterias-api/          # Repositório da API (referência)
└── ui-ux-pro-max-skill/   # Skill de design (referência)
```

## 🎯 Loterias Suportadas

- Mega-Sena
- Lotofácil
- Quina
- Lotomania
- Timemania
- Dupla Sena
- Dia de Sorte
- Super Sete
- +Milionária

## 💻 Como Executar

### Pré-requisitos

- Navegador web moderno (Chrome, Firefox, Safari, Edge)
- Servidor HTTP local

### Opção 1: Python (Recomendado)

```bash
# Python 3
python3 -m http.server 8000

# Python 2
python -m SimpleHTTPServer 8000
```

### Opção 2: Node.js (http-server)

```bash
npx http-server -p 8000
```

### Opção 3: PHP

```bash
php -S localhost:8000
```

### Acessar o Aplicativo

Abra seu navegador e acesse:
```
http://localhost:8000
```

## 📱 Instalação como PWA

### Android / Chrome

1. Acesse o site no Chrome
2. Toque no menu (três pontos)
3. Selecione "Adicionar à tela inicial"
4. Confirme a instalação

### iOS / Safari

1. Acesse o site no Safari
2. Toque no botão de compartilhar
3. Role para baixo e toque em "Adicionar à Tela de Início"
4. Confirme a instalação

### Desktop / Chrome

1. Acesse o site no Chrome
2. Clique no ícone de instalação na barra de endereços
3. Ou clique no botão "Instalar App" no canto superior direito
4. Confirme a instalação

## 🎨 Guia de Desenvolvimento

### Regras de Design

1. **Cores**: Use apenas a paleta definida + branco, cinza e preto
2. **Tipografia**: Cinza e preto para textos
3. **Contraste**: Mínimo 4.5:1 para textos
4. **Espaçamento**: Múltiplos de 4px
5. **Animações**: 150-300ms com easing suave
6. **Responsividade**: Mobile-first (320px → 1440px)

### Componentes Principais

#### Lottery Card
```css
.lottery-card {
  background: #FFFFFF;
  border-radius: 8px;
  padding: 16px;
  box-shadow: 0 2px 8px rgba(30, 41, 61, 0.1);
}
```

#### Number Ball
```css
.number-ball {
  width: 44px;
  height: 44px;
  background: #006494;
  color: #FFFFFF;
  border-radius: 50%;
}
```

#### Next Draw Card
```css
.next-draw-card {
  background: linear-gradient(135deg, #1B98E0, #247BA0);
  color: #FFFFFF;
  border-radius: 12px;
  padding: 16px;
}
```

## 🔄 Funcionalidades

### Atualização Automática
- Atualiza os resultados automaticamente a cada 5 minutos
- Verifica conexão com internet
- Exibe banner de status offline/online

### Cache Inteligente
- Armazena resultados em cache para acesso offline
- Service Worker gerencia cache de recursos estáticos
- Estratégia Network-First para API

### Performance
- Lazy loading de imagens
- Minificação de recursos
- Compressão gzip
- Cache de longa duração para assets estáticos

## 📊 API Reference

A aplicação consome a [Loterias CAIXA API](https://loteriascaixa-api.herokuapp.com/api).

### Endpoints Utilizados

```javascript
GET /api/{loteria}/latest

// Exemplo
GET /api/megasena/latest
```

### Resposta da API

```json
{
  "loteria": "megasena",
  "concurso": 2620,
  "data": "12/08/2023",
  "dezenas": ["04", "06", "13", "21", "26", "28"],
  "acumulou": false,
  "valorEstimadoProximoConcurso": 3500000.0,
  "dataProximoConcurso": "16/08/2023",
  "premiacoes": [...]
}
```

## 🔧 Personalização

### Adicionar Nova Loteria

Edite `src/js/app.js`:

```javascript
const LOTTERIES = [
    { id: 'megasena', name: 'Mega-Sena', color: '#209869' },
    // Adicione aqui
];
```

### Alterar Intervalo de Atualização

Edite `src/js/app.js`:

```javascript
// Padrão: 5 minutos (5 * 60 * 1000)
setInterval(() => {
    if (isOnline) {
        initApp();
    }
}, 5 * 60 * 1000); // Altere aqui
```

## 🎯 Melhorias Futuras

- [ ] Notificações push para novos resultados
- [ ] Filtros por loteria
- [ ] Histórico de resultados
- [ ] Gerador de números aleatórios
- [ ] Estatísticas e análises
- [ ] Modo escuro
- [ ] Compartilhamento de resultados
- [ ] Favoritar loterias
- [ ] Configurações personalizadas

## 📄 Licença

Este projeto é de código aberto e está disponível sob a licença MIT.

## ⚠️ Avisos Importantes

1. **Não Oficial**: Este aplicativo não é afiliado à CAIXA Econômica Federal
2. **API de Terceiros**: Utiliza API não-oficial que pode ter limitações
3. **Verificação**: Sempre confira os resultados oficiais em [loterias.caixa.gov.br](https://loterias.caixa.gov.br)
4. **Responsabilidade**: Os desenvolvedores não se responsabilizam por eventuais erros nos resultados

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:

1. Fork o projeto
2. Criar uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abrir um Pull Request

## 📞 Suporte

Para reportar bugs ou solicitar features, abra uma [Issue](https://github.com/seu-usuario/SiteDaSorte/issues).

## 🙏 Agradecimentos

- [guto-alves](https://github.com/guto-alves) - Loterias CAIXA API
- [nextlevelbuilder](https://github.com/nextlevelbuilder) - UI/UX Pro Max Skill
- CAIXA Econômica Federal - Dados das loterias

## 📚 Referências

- [Loterias CAIXA API](https://github.com/guto-alves/loterias-api)
- [UI/UX Pro Max Skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)
- [PWA Documentation](https://web.dev/progressive-web-apps/)
- [Tailwind CSS](https://tailwindcss.com/)

---

**Desenvolvido com ❤️ usando UI/UX Pro Max Skill**

![Made with UI/UX Pro Max](https://img.shields.io/badge/Made%20with-UI%2FUX%20Pro%20Max-blue)
![PWA Ready](https://img.shields.io/badge/PWA-Ready-success)
![Mobile First](https://img.shields.io/badge/Mobile-First-orange)
