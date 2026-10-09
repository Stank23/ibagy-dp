import 'server-only';
/** Fail closed until routes are migrated to PostgreSQL and Supabase Storage. */
export function database(): any { throw new Error('D1 indisponível na Vercel; migração em andamento'); }
export function bucket(): any { throw new Error('R2 indisponível na Vercel; migração em andamento'); }
