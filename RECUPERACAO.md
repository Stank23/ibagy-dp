# Recuperação e continuidade

A referência histórica é a versão 77. A branch main é a base protegida; o trabalho de migração permanece em migracao-vercel-supabase. O backup original não deve ser sobrescrito pela documentação ou pelos artefatos gerados.

## Fontes preservadas

O motor original em lib/finance-service.ts e seus módulos de regras continuam sendo a referência de cálculo. O caminho Cloudflare/D1/R2 ainda tem chamadas em código, scripts de build e configurações; foi preservado porque a migração não foi declarada concluída. drizzle/ e supabase/ contêm histórico e SQLs distintos, não equivalentes e não descartáveis como arquivos sem uso.

## Ambiente e dados

Segredos pertencem ao ambiente da hospedagem. Nenhum .env, senha padrão ou token deve entrar no Git. Seeds e testes SQL usam dados fictícios. Não aplicar reset ou seeds em produção. Um primeiro administrador deve ser criado por procedimento autorizado da instalação, sem senha compartilhada no código.

## Restaurar antes de liberar

Backup de banco/anexos, restauração em ambiente isolado e comparação de competências devem ser validados antes de produção. Esta limpeza não migra dados reais, não realiza backup nem comprova restauração. Veja docs/ARCHITECTURE.md e docs/security-validation-2026-10-13.md para as pendências.

Os inventários/checksums da exportação antiga foram removidos porque não descreviam a branch atual; seu conteúdo permanece no histórico Git. O relatório atual da limpeza registra os caminhos removidos e a razão.
