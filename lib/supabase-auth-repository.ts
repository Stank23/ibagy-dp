import 'server-only';
import {supabaseAdminRequest} from './supabase-admin';

export type AuthUser = {
  id: string;
  username: string;
  name: string;
  email: string;
  role: 'admin' | 'viewer';
  salt: string;
  password_hash: string;
  active: number;
};

function filterValue(value: string): string {
  if (!value || value.length > 256 || /[\u0000-\u001f,()]/.test(value)) throw new Error('Filtro inválido');
  return encodeURIComponent(value);
}

export async function findActiveUserByUsername(username: string): Promise<AuthUser | null> {
  const rows = await supabaseAdminRequest<AuthUser[]>(
    `/rest/v1/app_users?select=id,username,name,email,role,salt,password_hash,active&username=eq.${filterValue(username)}&active=eq.1&limit=1`,
  );
  return rows[0] ?? null;
}

export async function findActiveSessionUser(tokenHash: string, now = Date.now()): Promise<Pick<AuthUser, 'id' | 'username' | 'name' | 'role'> | null> {
  if (!/^[a-f0-9]{64}$/.test(tokenHash)) return null;
  const sessions = await supabaseAdminRequest<Array<{user_id: string}>>(
    `/rest/v1/app_sessions?select=user_id&token_hash=eq.${tokenHash}&expires=gt.${now}&limit=1`,
  );
  if (!sessions[0]) return null;
  const users = await supabaseAdminRequest<Array<Pick<AuthUser, 'id' | 'username' | 'name' | 'role'>>>(
    `/rest/v1/app_users?select=id,username,name,role&id=eq.${filterValue(sessions[0].user_id)}&active=eq.1&limit=1`,
  );
  return users[0] ?? null;
}

export async function createSession(tokenHash: string, userId: string, expires: number): Promise<void> {
  if (!/^[a-f0-9]{64}$/.test(tokenHash) || !Number.isSafeInteger(expires)) throw new Error('Sessão inválida');
  const user = await supabaseAdminRequest<Array<{id: string}>>(
    `/rest/v1/app_users?select=id&id=eq.${filterValue(userId)}&active=eq.1&limit=1`,
  );
  if (!user[0]) throw new Error('Conta inativa');
  await supabaseAdminRequest('/rest/v1/app_sessions', {
    method: 'POST',
    body: {token_hash: tokenHash, user_id: userId, expires},
    prefer: 'return=minimal',
  });
}

export async function revokeSession(tokenHash: string): Promise<void> {
  if (!/^[a-f0-9]{64}$/.test(tokenHash)) return;
  await supabaseAdminRequest(`/rest/v1/app_sessions?token_hash=eq.${tokenHash}`, {
    method: 'DELETE',
    prefer: 'return=minimal',
  });
}
