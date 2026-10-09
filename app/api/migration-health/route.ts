/**
 * Endpoint público sem acesso a credenciais, banco ou dados de pessoal.
 * Serve apenas para diagnosticar se o Next.js está atendendo rotas na Vercel.
 */
export const dynamic = 'force-dynamic';
export async function GET(): Promise<Response> {
  return Response.json(
    {application: 'ibagy-dp', migration: 'preview', runtime: 'nextjs', databaseTested: false},
    {headers: {'Cache-Control': 'no-store', 'X-Content-Type-Options': 'nosniff'}},
  );
}
