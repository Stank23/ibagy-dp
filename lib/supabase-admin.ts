import 'server-only';

/**
 * Acesso exclusivo do servidor ao Supabase.
 * Nunca importe este módulo em componentes client ou exponha a chave service_role.
 * O adaptador não substitui automaticamente as consultas D1/SQLite existentes.
 */
const baseUrl = process.env.SUPABASE_URL;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

export function isSupabaseConfigured(): boolean {
  return Boolean(baseUrl && serviceKey);
}

export async function supabaseAdminRequest<T>(
  path: string,
  options: { method?: 'GET' | 'POST' | 'PATCH' | 'DELETE'; body?: unknown; prefer?: string } = {},
): Promise<T> {
  if (!baseUrl || !serviceKey) throw new Error('Supabase não configurado no servidor');
  if (!path.startsWith('/') || path.startsWith('//')) throw new Error('Caminho Supabase inválido');
  const response = await fetch(new URL(path, baseUrl), {
    method: options.method ?? 'GET',
    headers: {
      apikey: serviceKey,
      // Legacy service_role is a JWT; modern sb_secret_ keys authenticate via apikey only.
      ...(serviceKey.startsWith('sb_secret_') ? {} : {Authorization: `Bearer ${serviceKey}`}),
      ...(options.body !== undefined ? { 'Content-Type': 'application/json' } : {}),
      ...(options.prefer ? { Prefer: options.prefer } : {}),
    },
    ...(options.body !== undefined ? { body: JSON.stringify(options.body) } : {}),
    cache: 'no-store',
  });
  if (!response.ok) {
    // Não retornar detalhes internos nem credenciais ao cliente.
    throw new Error(`Falha de operação no Supabase (HTTP ${response.status})`);
  }
  if (response.status === 204) return undefined as T;
  const text = await response.text();
  return text ? JSON.parse(text) as T : undefined as T;
}
