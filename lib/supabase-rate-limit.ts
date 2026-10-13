import 'server-only';
import {supabaseAdminRequest} from './supabase-admin';

/**
 * Reserva atômica de tentativas de autenticação no PostgreSQL.
 * Invocar exclusivamente no servidor antes de verificar senhas.
 * A função RPC não é executável por anon/authenticated.
 */
export async function reserveAuthAttempt(
  namespace: string,
  subject: string,
  maxAttempts: number,
  windowMs: number,
  now = Date.now(),
): Promise<boolean> {
  if (!namespace || !subject || !Number.isSafeInteger(maxAttempts) || maxAttempts < 1 ||
      !Number.isSafeInteger(windowMs) || windowMs < 1) {
    throw new Error('Parâmetros de proteção inválidos');
  }
  const bytes = new TextEncoder().encode(`${namespace}|${subject}`);
  const digest = await crypto.subtle.digest('SHA-256', bytes);
  const key = 'rate:' + Array.from(new Uint8Array(digest), b => b.toString(16).padStart(2, '0')).join('');
  return supabaseAdminRequest<boolean>('/rest/v1/rpc/reserve_auth_attempt', {
    method: 'POST',
    body: {p_key: key, p_now: now, p_cutoff: now - windowMs, p_max: maxAttempts},
  });
}
