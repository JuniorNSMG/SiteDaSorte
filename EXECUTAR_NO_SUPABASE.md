# ⚡ Execute Isto no Supabase AGORA

## 🎯 Passo a Passo Rápido:

### 1️⃣ Acesse o SQL Editor do Supabase

Vá para: https://supabase.com/dashboard/project/kbczmmgfkbnuyfwrlmtu/sql/new

### 2️⃣ Cole o SQL Abaixo

Copie **TODO** o conteúdo do arquivo `database/schema.sql` ou o SQL abaixo:

```sql
-- COPIE E COLE ISTO NO SUPABASE SQL EDITOR:
```

### 3️⃣ Clique em "Run" (ou Ctrl/Cmd + Enter)

Você verá: ✅ **"Success. No rows returned"**

### 4️⃣ Verificar

Vá para: https://supabase.com/dashboard/project/kbczmmgfkbnuyfwrlmtu/editor

Você deve ver as tabelas:
- ✅ `loterias`
- ✅ `sync_log`

---

## 🚀 Teste Rápido

Depois de executar o schema, você pode testar com:

```sql
-- Inserir um teste
INSERT INTO loterias (
    tipo_loteria,
    numero_concurso,
    data_sorteio,
    dezenas,
    acumulou
) VALUES (
    'megasena',
    9999,
    '2024-02-07',
    ARRAY['01', '02', '03', '04', '05', '06'],
    false
);

-- Ver se funcionou
SELECT * FROM loterias LIMIT 1;

-- Deletar o teste
DELETE FROM loterias WHERE numero_concurso = 9999;
```

---

## ✅ Pronto!

Depois que executar o SQL:

1. Volte para o terminal
2. Execute:
   ```bash
   cd ~/Documents/SiteDaSorte
   git pull
   python3 -m http.server 8000
   ```
3. Abra: http://localhost:8000
4. Abra Console (F12)
5. Você verá: ✅ **"Supabase inicializado com sucesso"**

---

## 📊 Ver Dados Sendo Salvos

Acesse: https://supabase.com/dashboard/project/kbczmmgfkbnuyfwrlmtu/editor/loterias

Você verá os resultados sendo salvos em tempo real! 🎉
