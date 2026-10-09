/**
 * Verificação de conectividade somente leitura.
 * Execute em ambiente de servidor com SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY.
 * Não exibe nem grava segredos, e não altera dados.
 */
const url = process.env.SUPABASE_URL;
const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!url || !key) {
  console.error('Faltam SUPABASE_URL ou SUPABASE_SERVICE_ROLE_KEY.');
  process.exitCode = 1;
} else {
  try {
    const endpoint = new URL('/rest/v1/periods?select=month&limit=0', url);
    if (endpoint.protocol !== 'https:') throw new Error('A URL do Supabase deve usar HTTPS.');
    const response = await fetch(endpoint, {
      headers: { apikey: key, ...(key.startsWith('sb_secret_') ? {} : {Authorization: `Bearer ${key}`}), Accept: 'application/json' },
      signal: AbortSignal.timeout(10000),
    });
    if (!response.ok) throw new Error(`Supabase respondeu HTTP ${response.status}.`);
    console.log('Conectividade Supabase OK; consulta somente leitura à tabela periods.');
  } catch (error) {
    console.error(error instanceof Error ? error.message : 'Falha de conexão.');
    process.exitCode = 1;
  }
}
