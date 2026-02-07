// Configuração do Supabase - Site da Sorte
// COPIE este arquivo para supabase-config.js e preencha com suas credenciais

const SUPABASE_CONFIG = {
    // URL do seu projeto Supabase
    // Encontre em: https://app.supabase.com → Seu Projeto → Settings → API
    url: 'https://SEU-PROJETO.supabase.co',

    // Anon/Public Key
    // Encontre em: https://app.supabase.com → Seu Projeto → Settings → API → anon/public
    anonKey: 'SUA-ANON-KEY-AQUI',

    // Configurações opcionais
    options: {
        auth: {
            autoRefreshToken: true,
            persistSession: true,
            detectSessionInUrl: false
        }
    }
};

// Exportar configuração
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SUPABASE_CONFIG;
}
