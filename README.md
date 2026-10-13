# IBAGY DP · Departamento Pessoal

Sistema de lançamentos mensais, conferência da folha, benefícios, custos/provisões e exportações para contabilidade. Migração da versão 77 de Cloudflare D1/R2 para Next.js na Vercel e PostgreSQL/Storage no Supabase.

## Documentação

- [PRD](docs/PRD.md): produto, requisitos, critérios de aceite e prioridades.
- [Design System](docs/DESIGN-SYSTEM.md): identidade, componentes, padrões e acessibilidade.
- [Architecture](docs/ARCHITECTURE.md): camadas, dados, transações e segurança.
- [Agent Instructions](AGENTS.md): instruções operacionais para agentes e colaboradores.
- [Segurança: resultados e pendências](docs/security-validation-2026-10-13.md).
- [Inventário e limpeza do repositório](docs/repository-cleanup.md).

## Executar e validar

Node >=22.13; pnpm conforme `packageManager` em package.json. `pnpm install --frozen-lockfile` respeita a política de dependências. Configure `SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY` apenas no servidor/ambiente da hospedagem; nunca no repositório ou em variáveis NEXT_PUBLIC.

O caminho Vercel usa `npm run build:vercel`. Os comandos dev/build/start genéricos mantêm o ambiente legado Sites/Cloudflare; não são equivalentes ao preview Next.js da Vercel. Consulte Architecture antes de trocar scripts.

Testes: `test:migration`, `test:fields`, `test:files`, `test:record-actions`, `test:employee-edit`, `test:priority-actions`, `test:commissions`, `test:health-export`, `test:dsr-city` e `test:security` em package.json. Os testes HTTP simulados não substituem o teste real da aplicação.

## Regras de trabalho

Somente dados fictícios nos testes. Preservar competências anteriores e fechadas. Não modificar cálculos sem conferir a versão 77. Não executar seeds/reset em produção. Nenhuma senha padrão é distribuída. Alterações devem passar por build, testes e revisão antes de qualquer decisão de merge.

O pacote SheetJS 0.20.3 é mantido em `vendor/xlsx-0.20.3.tgz`; arquivos e avisos da biblioteca estão preservados nesse pacote e no LICENSE existente. O README anterior era material do fornecedor, não documentação do sistema.
