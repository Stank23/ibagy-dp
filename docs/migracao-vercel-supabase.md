# Migração IBAGY DP v77 — Vercel + Supabase

## Preservação obrigatória
- A branch `main` mantém a versão 77 atual, sem alterações nesta etapa.
- As mudanças são preparadas na branch `migracao-vercel-supabase`.
- Não remover telas, eventos, fórmulas, permissões, histórico por competência, relatórios ou exportações.
- Não utilizar a aplicação publicada com dados reais enquanto autenticação, banco e arquivos não forem validados.

## Diagnóstico confirmado no código
- `scripts/run-framework.mjs` executa `vinext build` em ambiente portátil.
- `vite.config.ts` e `build/sites-worker.ts` usam o plugin de Cloudflare e um worker.
- `lib/store.ts` importa `env` de `cloudflare:workers` e expõe D1 (`DB`) e R2 (`BUCKET`).
- `lib/local-auth.ts` consulta sessões e usuários por SQL de D1.
- `app/page.tsx` depende de autenticação; `app/login/page.tsx` é a tela de entrada.
- A implantação anterior chegou a READY, mas o endereço apresentou 404: compilação não equivale a roteamento válido.

## Sequência técnica (não concluída)
1. Inventariar todas as rotas `app/api/**`, tabelas, consultas D1 e operações R2.
2. Criar esquema PostgreSQL novo no Supabase, preservando a semântica dos dados mensais e das regras da v77. Definir políticas de acesso e armazenamento privado.
3. Implementar camada de acesso a dados compatível com a API utilizada pelos módulos existentes; substituir consultas SQLite/D1 por PostgreSQL de forma controlada.
4. Substituir armazenamento R2 por Supabase Storage, preservando exportações e anexos.
5. Adaptar o build e a execução para Next.js na Vercel; remover dependências Cloudflare apenas depois da substituição correspondente.
6. Migrar autenticação e sessões com proteção adequada, sem liberar rotas privadas publicamente.
7. Validar cadastro, folha principal, comissão, Unimed, Uniodonto, SEREFI, provisões, relatórios e histórico por competência contra a versão 77.
8. Publicar em produção somente após testes funcionais e de segurança.

## Regras de negócio a preservar
- Comissão antecipada paga no dia 20 e reapresentada na folha principal.
- Quinquênio de 5% do salário-base por cinco anos completos, a partir da competência de aniversário.
- Proporcionalidade em base de 30 dias; VA proporcional na competência de admissão e fixo nas seguintes.
- Unimed e Uniodonto: participação da empresa de 30% apenas para titular; dependentes seguem o valor estabelecido; eventos empresa 344.
- Empréstimo SEREFI: taxa bancária de R$ 2,80 na primeira parcela.
- FGTS: salário total sem auxílio-creche, somado à comissão líquida conforme regra atual.
- Histórico de competências imutável por sobreposição de mês e exportação para contabilidade.

Este arquivo é um registro de planejamento e proteção de escopo; não indica migração concluída.
