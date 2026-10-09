# IBAGY · Departamento Pessoal

Sistema de controle financeiro de pessoal para uma empresa: colaboradores, lançamentos, comissões, DSR, planos de saúde, empréstimos SEREFI, rescisões, conferência da folha, custos, provisões e exportações para contabilidade.

## Estado atual

- Código importado da versão publicada em 08/10/2026, commit de origem `5caf1bb7ecf989a79a805bf7200e8efba065194f`.
- Aplicação React/Vinext, hospedada em Cloudflare Workers pelo Sites.
- Banco em uso: Cloudflare D1 (SQLite). Arquivos: Cloudflare R2.
- Migração para Supabase iniciada: 22 tabelas criadas no schema privado `ibagy` do projeto DP - Ibagy. **O site ainda não usa o Supabase.**
- Nenhum dado do banco, arquivo anexado, chave de produção ou token de sessão é incluído nesta cópia do código.

## Desenvolvimento

Use Node.js >=22.13 e a versão do pnpm indicada em package.json.

```sh
pnpm install
pnpm dev
pnpm exec tsc --noEmit
pnpm build
```

O ambiente de desenvolvimento exige as configurações Cloudflare D1/R2 e as migrações correspondentes. Consulte scripts/ e .openai/hosting.json. Não substitua IDs de recursos gerenciados nem reaplique migrações históricas em produção.

## Supabase

Os SQLs em supabase/ reproduzem a estrutura já preparada no projeto, sem copiar os dados. Leia supabase/README.md antes de executá-los. As migrações antigas em drizzle/ são de SQLite, contêm sementes de teste e **não devem ser executadas no PostgreSQL**.

Ainda faltam a adaptação das consultas e transações, a configuração segura do acesso do servidor, a transferência dos dados e os testes de equivalência dos cálculos. O login próprio da aplicação continua ativo durante a transição.

## Segurança

Credenciais ficam exclusivamente na configuração secreta do servidor. Não use NEXT_PUBLIC_ para chaves secretas. Não publique .env, dumps do banco nem backups de arquivos.

Consulte docs/security-review.md para as proteções implementadas e limitações conhecidas.

## Relação com o site publicado

Este repositório guarda o código completo. O envio ao GitHub, por si só, não publica mudanças no site. A hospedagem Sites continua usando seu fluxo próprio; a sincronização entre os dois repositórios deve ser realizada explicitamente.
