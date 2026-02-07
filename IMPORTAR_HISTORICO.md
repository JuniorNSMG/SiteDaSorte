# 📚 Importar Histórico de Loterias

Guia para importar histórico completo de todos os concursos das loterias para o Supabase.

---

## 🎯 O Que Faz?

Importa os últimos **100 concursos** de cada loteria (configurável):
- Mega-Sena
- Lotofácil
- Quina
- Lotomania
- Timemania
- Dupla Sena
- Dia de Sorte
- Super Sete
- +Milionária

**Total:** ~900 concursos importados!

---

## 🚀 Como Usar

### 1️⃣ **Via Interface (Mais Fácil)**

1. Acesse: https://juniornsmg.github.io/SiteDaSorte/
2. Aguarde carregar (Supabase deve estar ativo)
3. Clique no botão **"📚 Importar Histórico"** no canto superior direito
4. Confirme na caixa de diálogo
5. Aguarde 1-2 minutos ⏱️
6. Página recarrega automaticamente!

### 2️⃣ **Via Console (Avançado)**

Abra o Console (F12) e execute:

```javascript
// Importar últimos 100 concursos (padrão)
startHistoricImport();

// OU configurar quantidade personalizada primeiro:
IMPORT_CONFIG.maxConcursosPorLoteria = 500; // Importar 500
startHistoricImport();

// Importar TODOS os concursos (CUIDADO: muito lento!)
IMPORT_CONFIG.maxConcursosPorLoteria = 0; // 0 = todos
startHistoricImport();
```

---

## ⚙️ Configurações

Edite `src/js/import-history.js`:

```javascript
const IMPORT_CONFIG = {
    // Quantos concursos importar (0 = todos)
    maxConcursosPorLoteria: 100,

    // Delay entre requisições (ms)
    delayEntreRequisicoes: 1000, // 1 segundo

    // Concursos salvos por vez
    batchSize: 10
};
```

### Recomendações:

| Quantidade | Tempo Estimado | Uso |
|-----------|----------------|-----|
| 10 | ~1 minuto | Teste |
| 100 | ~2-3 minutos | **Recomendado** |
| 500 | ~10-15 minutos | Histórico extenso |
| 0 (todos) | ~1-2 horas | Histórico completo |

---

## 📊 Progresso

Durante a importação você verá:

```
┌─────────────────────────────────┐
│ Importando Histórico            │
├─────────────────────────────────┤
│ Importando Mega-Sena:           │
│ Concurso 2850/2969              │
├─────────────────────────────────┤
│ ████████████░░░░░░░ 65%        │
│                      [Cancelar] │
└─────────────────────────────────┘
```

**Informações mostradas:**
- Loteria atual
- Concurso sendo importado
- Porcentagem completa
- Botão para cancelar

---

## ✅ Verificar Importação

### No Supabase:

1. Acesse: https://supabase.com/dashboard/project/kbczmmgfkbnuyfwrlmtu/editor/loterias
2. Você deve ver ~900 registros (9 loterias × 100 concursos)

### Via SQL:

```sql
-- Ver total de concursos por loteria
SELECT
    tipo_loteria,
    COUNT(*) as total_concursos,
    MIN(numero_concurso) as primeiro,
    MAX(numero_concurso) as ultimo
FROM loterias
GROUP BY tipo_loteria
ORDER BY tipo_loteria;

-- Ver concursos mais antigos importados
SELECT tipo_loteria, numero_concurso, data_sorteio
FROM loterias
ORDER BY data_sorteio ASC
LIMIT 10;
```

---

## 🎨 Visualizar Histórico

Após importar, você pode:

1. **Ver estatísticas** no dashboard do Supabase
2. **Criar visualizações** de números mais sorteados
3. **Analisar padrões** ao longo do tempo
4. **Comparar períodos** diferentes

### Exemplo de Consulta:

```sql
-- Números mais sorteados na Mega-Sena (histórico)
SELECT
    unnest(dezenas) as numero,
    COUNT(*) as vezes_sorteado
FROM loterias
WHERE tipo_loteria = 'megasena'
GROUP BY numero
ORDER BY vezes_sorteado DESC
LIMIT 10;
```

---

## ⏸️ Cancelar Importação

Se precisar parar:

**Via Interface:**
- Clique no botão **"Cancelar"** na barra de progresso

**Via Console:**
```javascript
stopImport();
```

A importação para imediatamente, mas os concursos já importados são mantidos.

---

## 🐛 Troubleshooting

### Importação muito lenta

**Causa:** API externa pode estar lenta

**Solução:**
1. Reduza `delayEntreRequisicoes` para 500ms
2. Importe em horários de menos uso (madrugada)

### Erros 404

**Causa:** Alguns concursos podem não existir na API

**Solução:** Normal! O importador pula automaticamente

### Duplicados

**Causa:** Tentou importar concursos que já existem

**Solução:** O importador verifica e pula automaticamente

### Supabase retorna erro

**Causa:** Pode atingir limite de requisições

**Solução:**
1. Aumente `delayEntreRequisicoes` para 2000ms
2. Reduza `batchSize` para 5
3. Importe em partes menores

---

## 📈 Estatísticas Pós-Importação

Ao final você verá:

```
✅ Importação concluída!
📊 Estatísticas:
   Total processado: 900
   ✅ Sucesso: 845
   ⏭️ Pulados (já existem): 50
   ❌ Erros: 5
```

**Legenda:**
- **Sucesso:** Novos concursos importados
- **Pulados:** Já existiam no banco
- **Erros:** Não encontrados ou falha na API

---

## 🔄 Re-Importação

Para atualizar dados antigos:

1. Delete os dados antigos no Supabase (via SQL):
   ```sql
   DELETE FROM loterias WHERE tipo_loteria = 'megasena';
   ```

2. Rode a importação novamente

**OU** importe apenas concursos faltantes aumentando `maxConcursosPorLoteria`

---

## 💡 Dicas Pro

### Importação Noturna Automática

Adicione em `src/js/app.js`:

```javascript
// Importar automaticamente à meia-noite
const now = new Date();
if (now.getHours() === 0 && now.getMinutes() < 5) {
    startHistoricImport();
}
```

### Importação Seletiva

Importar apenas uma loteria:

```javascript
const megasena = LOTTERIES.find(l => l.id === 'megasena');
importLotteryHistory(megasena);
```

### Backup Antes de Importar

```sql
-- Exportar dados atuais
COPY loterias TO '/tmp/backup-loterias.csv' CSV HEADER;
```

---

## 🎯 Próximos Passos

Após importar o histórico:

1. ✅ Ver todos os concursos no Supabase
2. 📊 Criar análises de números frequentes
3. 📈 Fazer gráficos de evolução de prêmios
4. 🔍 Buscar padrões nos sorteios
5. 🎲 Criar gerador inteligente de jogos

---

## 🆘 Suporte

Se tiver problemas:

1. Verifique console do navegador (F12)
2. Veja logs no Supabase: Settings → Logs
3. Confira se atingiu limites do plano gratuito
4. Teste com quantidade menor primeiro (10 concursos)

---

**Boa sorte com a importação! 🍀**

Qualquer dúvida, verifique os logs detalhados no console.
