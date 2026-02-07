## 🗄️ Setup do Supabase - Site da Sorte

Guia completo para configurar o banco de dados Supabase.

---

## 📋 O Que é o Supabase?

O Supabase armazena todo o histórico das loterias:
- ✅ Dados mais rápidos (não depende da API externa)
- ✅ Histórico completo preservado
- ✅ Funciona offline com dados salvos
- ✅ Sincronização automática com novos resultados

---

## 🚀 Passo 1: Criar Conta no Supabase

1. Acesse: https://supabase.com
2. Clique em **"Start your project"**
3. Faça login com GitHub (recomendado)

---

## 📦 Passo 2: Criar Novo Projeto

1. No Dashboard, clique em **"New Project"**

2. Preencha:
   - **Name**: `site-da-sorte`
   - **Database Password**: Crie uma senha forte (guarde!)
   - **Region**: `South America (São Paulo)` (mais rápido para Brasil)
   - **Pricing Plan**: `Free` (grátis para sempre!)

3. Clique em **"Create new project"**

4. Aguarde 2-3 minutos enquanto o projeto é criado ☕

---

## 🗃️ Passo 3: Criar o Schema do Banco

1. No menu lateral, clique em **"SQL Editor"**

2. Clique em **"New query"**

3. Copie todo o conteúdo do arquivo `database/schema.sql`

4. Cole no editor SQL

5. Clique em **"Run"** (ou pressione Cmd/Ctrl + Enter)

6. Você verá: ✅ **"Success. No rows returned"**

---

## 🔑 Passo 4: Obter Credenciais

1. No menu lateral, clique em **"Settings"** → **"API"**

2. Copie as seguintes informações:

   **Project URL:**
   ```
   https://seu-projeto-id.supabase.co
   ```

   **anon/public key:**
   ```
   eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

3. **GUARDE ESSAS INFORMAÇÕES!**

---

## ⚙️ Passo 5: Configurar no Projeto

### Opção A: Variáveis de Ambiente (Recomendado)

1. Crie arquivo `.env` na raiz do projeto:

```bash
# No terminal, na pasta SiteDaSorte:
touch .env
```

2. Adicione ao `.env`:

```env
VITE_SUPABASE_URL=https://seu-projeto-id.supabase.co
VITE_SUPABASE_ANON_KEY=sua-anon-key-aqui
```

3. O arquivo `.env` já está no `.gitignore` (não será enviado ao GitHub)

### Opção B: Arquivo de Configuração

1. Copie o arquivo de exemplo:

```bash
cp config/supabase-config.example.js config/supabase-config.js
```

2. Edite `config/supabase-config.js`:

```javascript
const SUPABASE_CONFIG = {
    url: 'https://seu-projeto-id.supabase.co',
    anonKey: 'sua-anon-key-aqui',
    // ...
};
```

3. Adicione ao `.gitignore`:

```bash
echo "config/supabase-config.js" >> .gitignore
```

---

## 📝 Passo 6: Adicionar Script no HTML

Edite `index.html` e adicione ANTES do `</head>`:

```html
<!-- Configuração Supabase -->
<script src="./config/supabase-config.js"></script>

<!-- Scripts do app -->
<script src="./src/js/supabase.js"></script>
<script src="./src/js/sync.js"></script>
<script src="./src/js/app.js"></script>
```

---

## ✅ Passo 7: Testar

1. Abra o site localmente:

```bash
python3 -m http.server 8000
```

2. Abra `http://localhost:8000`

3. Abra o DevTools Console (F12)

4. Você deve ver:
   ```
   ✅ Supabase inicializado com sucesso
   🔄 Iniciando sincronização automática...
   ✅ megasena concurso 2XXX salvo no Supabase
   ...
   ```

5. Acesse o Supabase Dashboard → **Table Editor** → **loterias**
   - Você verá os dados sendo salvos! 🎉

---

## 🔒 Segurança - Row Level Security (RLS)

As políticas de segurança já foram criadas no schema:

✅ **Leitura (SELECT)**: Todos podem ler (público)
✅ **Escrita (INSERT/UPDATE)**: Apenas autenticados

### Para Permitir Escrita Pública (Desenvolvimento):

⚠️ **ATENÇÃO**: Use apenas em desenvolvimento!

```sql
-- No SQL Editor do Supabase:
DROP POLICY "Apenas autenticados podem modificar" ON loterias;

CREATE POLICY "Todos podem modificar"
    ON loterias FOR ALL
    TO anon
    USING (true)
    WITH CHECK (true);
```

---

## 📊 Funcionalidades Implementadas

### Sincronização Automática
- Verifica novos resultados a cada 5 minutos
- Salva automaticamente no Supabase
- Não duplica dados (usa UPSERT)

### Views Criadas

**ultimos_resultados**: Último concurso de cada loteria
```sql
SELECT * FROM ultimos_resultados;
```

**loterias_acumuladas**: Loterias que acumularam
```sql
SELECT * FROM loterias_acumuladas;
```

### Funções Disponíveis

**Buscar último concurso:**
```sql
SELECT * FROM get_ultimo_concurso('megasena');
```

**Inserir/Atualizar:**
```sql
SELECT upsert_loteria(
    'megasena',
    2620,
    '2024-02-07',
    ARRAY['04', '13', '21', '26', '31', '47'],
    false,
    5000000.00,
    '2024-02-10',
    '{"premiacoes": [...]}'::jsonb,
    '{}'::jsonb
);
```

---

## 🐛 Troubleshooting

### Erro: "Failed to fetch"
**Causa**: Configuração incorreta da URL
**Solução**: Verifique se a URL está correta (com https://)

### Erro: "Invalid API key"
**Causa**: anon key incorreta
**Solução**: Copie novamente do Supabase Dashboard

### Erro: "Permission denied"
**Causa**: RLS está bloqueando
**Solução**: Verifique as políticas de segurança (passo Segurança acima)

### Dados não aparecem
1. Verifique console do navegador (F12)
2. Verifique Supabase Dashboard → Table Editor
3. Rode sincronização manual (botão 🔄)

### Sincronização não funciona
1. Verifique se Supabase foi inicializado (console)
2. Verifique conexão com internet
3. Verifique logs no Supabase: Settings → Logs

---

## 📈 Monitoramento

### Ver Logs de Sincronização

No Supabase SQL Editor:

```sql
-- Últimas sincronizações
SELECT
    tipo_loteria,
    numero_concurso,
    status,
    mensagem,
    created_at
FROM sync_log
ORDER BY created_at DESC
LIMIT 20;

-- Estatísticas
SELECT
    tipo_loteria,
    COUNT(*) as total_concursos,
    MAX(numero_concurso) as ultimo_concurso
FROM loterias
GROUP BY tipo_loteria
ORDER BY tipo_loteria;
```

### Dashboard do Supabase

Acesse **Table Editor** para:
- Ver dados em tempo real
- Editar manualmente (se necessário)
- Exportar dados (CSV, JSON)

---

## 💰 Limites do Plano Gratuito

O Supabase Free tier inclui:
- ✅ 500 MB de banco de dados
- ✅ 1 GB de armazenamento de arquivos
- ✅ 2 GB de banda mensal
- ✅ 50.000 usuários ativos mensais

**Para este projeto:**
- ~1 KB por concurso
- 9 loterias × 365 dias × 1 KB = ~3 MB/ano
- **Você tem espaço para ~166 anos de dados!** 🎉

---

## 🔄 Backup

### Exportar Dados

```sql
-- No SQL Editor:
COPY (SELECT * FROM loterias) TO STDOUT WITH CSV HEADER;
```

Ou use o Supabase CLI:

```bash
supabase db dump -f backup.sql
```

### Restaurar Dados

```bash
supabase db reset
psql < backup.sql
```

---

## 🚀 Deploy para Produção

Quando fizer deploy (Netlify, Vercel, etc.):

1. Configure as variáveis de ambiente:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`

2. Não commite `config/supabase-config.js` no Git!

3. Use HTTPS sempre (obrigatório para Supabase)

---

## 📚 Recursos Úteis

- [Documentação Supabase](https://supabase.com/docs)
- [Supabase JavaScript Client](https://supabase.com/docs/reference/javascript)
- [PostgreSQL Tutorial](https://www.postgresql.org/docs/current/tutorial.html)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

---

## ✅ Checklist Final

- [ ] Conta Supabase criada
- [ ] Projeto criado (região São Paulo)
- [ ] Schema executado (tabelas criadas)
- [ ] Credenciais copiadas
- [ ] Configuração adicionada ao projeto
- [ ] Scripts adicionados ao index.html
- [ ] Teste local funcionando
- [ ] Console mostra "Supabase inicializado"
- [ ] Dados aparecendo no Table Editor
- [ ] Sincronização automática ativa

---

**Parabéns! Seu Supabase está configurado! 🎉**

Agora o Site da Sorte tem um banco de dados profissional com histórico completo!
