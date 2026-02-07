# Regras do Projeto - Site da Sorte

## 📋 Regras Gerais

### Idioma
- ✅ **TODOS os commits devem ser em Português Brasil**
- ✅ **TODAS as conversas e documentação em Português Brasil**
- ✅ **Mensagens de commit seguem padrão: feat/fix/docs em português**
- ✅ **Comentários no código em Português Brasil**

### Commits
**Formato obrigatório:**
```
tipo: Descrição em português

Detalhes em português...

https://claude.ai/code/session_[ID]
```

**Tipos permitidos:**
- `feat:` - Nova funcionalidade
- `fix:` - Correção de bug
- `docs:` - Documentação
- `style:` - Formatação, estilos
- `refactor:` - Refatoração de código
- `test:` - Testes
- `chore:` - Tarefas de manutenção

### Exemplo de Commit Correto:
```
feat: Adiciona integração com Supabase

Implementa armazenamento de histórico de loterias no banco de dados.
Sincroniza automaticamente novos resultados da API.

https://claude.ai/code/session_012dYJmhVHYHpNkw1xS4p8jX
```

## 🎨 Design System

### Paleta de Cores (OBRIGATÓRIA)
Usar APENAS estas cores:

**Principais:**
- Dark Navy: `#1E293D`
- Ocean Blue: `#006494`
- Sky Blue: `#247BA0`
- Light Blue: `#1B98E0`
- Ice White: `#E8F1F2`

**Neutras (apenas para textos):**
- Branco: `#FFFFFF`
- Cinza Claro: `#F5F5F5`
- Cinza Médio: `#9CA3AF`
- Cinza Escuro: `#374151`
- Preto: `#000000`

### Regras de UI/UX

1. **Mobile-First SEMPRE**
   - Design para 320px primeiro
   - Progressive enhancement para tablets/desktop

2. **Acessibilidade Obrigatória**
   - Contraste mínimo 4.5:1
   - Navegação por teclado
   - ARIA labels quando necessário

3. **Performance**
   - Lazy loading de imagens
   - Service Worker para cache
   - Otimização de assets

## 💾 Banco de Dados

### Supabase
- **Armazenamento:** Histórico completo de todas as loterias
- **Sincronização:** Automática quando há novos resultados
- **Backup:** Dados preservados mesmo se API cair

### Estrutura de Dados

**Tabela: loterias**
```sql
- id (uuid, primary key)
- tipo_loteria (text) - megasena, lotofacil, etc
- numero_concurso (integer)
- data_sorteio (date)
- dezenas (text[]) - array de números sorteados
- acumulou (boolean)
- valor_estimado_proximo (numeric)
- data_proximo_concurso (date)
- premiacoes (jsonb) - detalhes dos prêmios
- created_at (timestamp)
- updated_at (timestamp)
```

**Índices:**
- `tipo_loteria, numero_concurso` (único)
- `data_sorteio`
- `tipo_loteria, data_sorteio`

## 📊 Exibição de Informações

### Ganhadores
- ✅ Mostrar **discretamente** os valores ganhos
- ✅ Usar formatação em reais (R$)
- ✅ Destacar principais prêmios
- ✅ Não ser sensacionalista

**Exemplo:**
```
✓ 6 acertos: 2 ganhadores - R$ 15.000.000,00 cada
✓ 5 acertos: 45 ganhadores - R$ 50.234,50 cada
✓ 4 acertos: 3.210 ganhadores - R$ 1.150,00 cada
```

### Informações Sempre Visíveis
1. Números sorteados (destaque)
2. Próximo concurso (data e valor estimado)
3. Status de acumulação
4. Premiações (quando houver ganhadores)

## 🔄 Sincronização de Dados

### Fluxo Automático
1. App carrega dados do Supabase (rápido)
2. Em background: verifica API por novos resultados
3. Se novos: atualiza Supabase
4. Atualiza interface

### Regras de Sincronização
- ✅ Verificar novos dados a cada 5 minutos
- ✅ Não sobrescrever dados existentes
- ✅ Log de todas as sincronizações
- ✅ Fallback para API se Supabase falhar

## 📁 Estrutura de Arquivos

```
SiteDaSorte/
├── src/
│   ├── js/
│   │   ├── app.js           # Lógica principal
│   │   ├── supabase.js      # Integração Supabase
│   │   ├── sync.js          # Sincronização automática
│   │   └── sw-register.js
│   ├── css/
│   │   └── styles.css
│   └── assets/
├── config/
│   └── supabase-config.js   # Configurações
├── database/
│   └── schema.sql           # Schema do banco
└── docs/
```

## 🚫 Anti-Padrões (NÃO FAZER)

1. ❌ Commits em inglês
2. ❌ Cores fora da paleta
3. ❌ Texto em light backgrounds sem contraste
4. ❌ Ignorar mobile-first
5. ❌ Dados hardcoded (usar Supabase)
6. ❌ Sobrescrever dados históricos
7. ❌ Valores de prêmios muito destacados (ser discreto)
8. ❌ Sem loading states
9. ❌ Sem tratamento de erros

## 🔐 Segurança

### Supabase
- ✅ Usar variáveis de ambiente para credenciais
- ✅ Row Level Security (RLS) habilitado
- ✅ API keys nunca no código-fonte
- ✅ HTTPS obrigatório

### API Externa
- ✅ Rate limiting
- ✅ Timeout de requisições
- ✅ Retry com backoff exponencial

## 📝 Checklist de Desenvolvimento

Antes de cada commit:
- [ ] Código em português (comentários, variáveis importantes)
- [ ] Mensagem de commit em português
- [ ] Design segue paleta de cores
- [ ] Mobile-first verificado
- [ ] Funciona offline (PWA)
- [ ] Dados vindo do Supabase
- [ ] Tratamento de erros implementado
- [ ] Loading states presentes

## 🎯 Prioridades

1. **Sempre:** Português Brasil
2. **Sempre:** Mobile-first
3. **Sempre:** Paleta de cores
4. **Sempre:** Supabase como fonte de dados
5. **Sempre:** Discreto com valores (não sensacionalista)

## 📞 Referências

- Design System: `DESIGN_SYSTEM.md`
- Deploy: `DEPLOY_INSTRUCTIONS.md`
- Git Manager: `GIT_MANAGER_GUIDE.md`
- Supabase Docs: https://supabase.com/docs

---

**Estas regras devem ser seguidas SEMPRE em TODO o desenvolvimento do projeto.**
