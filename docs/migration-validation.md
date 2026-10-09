# Validação da migração — avanço de 09/10/2026

Base remota: `f630a6f12a0846cc4ecbf1ee884087e16753ab60`, exclusivamente na branch `migracao-vercel-supabase`. A branch `main` não foi alterada.

## Abertura e recálculo de competências

`period` e `recalculate` agora usam a função completa `calculate()` da versão 77. Os arquivos originais `finance-service`, `rules`, `payroll`, `benefits`, `health-pricing`, `provisions`, `childcare` e `event-installments` foram comparados byte a byte com `IBAGY-DP-codigo-completo-v77.zip`: todos idênticos. Nenhuma fórmula foi substituída.

O servidor obtém todos os insumos em uma única consulta PostgreSQL. Depois de calcular, a RPC verifica novamente o token dos insumos, as revisões, a relação completa de colaboradores e o estado da competência. Folha e auditoria são gravadas na mesma transação. Uma competência já existente não é sobrescrita; recálculo exige competência aberta e só altera o mês solicitado.

As funções `finance_calculation_snapshot` e `save_calculated_finance_period` foram aplicadas no projeto de testes `fyaogkhkykntzparaojd`, pela migração remota `atomic_v77_payroll_calculation`. O SQL versionado está em `supabase/payroll-calculation.sql`. Ambas são `SECURITY INVOKER`, executáveis apenas por `service_role`; a rota exige sessão administrativa, mesma origem e limite de requisições.

Os bloqueios de tabela duram somente a transação de validação/gravação, depois do cálculo. Eles serializam escritas nos insumos da folha; medir contenção antes do uso com maior volume. Falha/deadlock provoca rollback, sem gravação parcial.

## Resultados realmente executados

- `node scripts/test-payroll-rules.mjs`: passou, oito verificações aritméticas existentes.
- `node scripts/test-supabase-calculation.mjs`: passou, paridade com o caminho original D1 usando insumos fictícios, salário proporcional, quinquênio, VA, SEREFI, empréstimos, parcelas, auxílio-creche, Unimed, Uniodonto, provisões, elegibilidade, recálculo sem duplicar parcelas, revisões e rejeição de mês fechado/inválido.
- `node --experimental-transform-types scripts/test-finance-calculation-route.mjs`: passou, testes HTTP com mocks de sessão e transporte, cobrindo origem, login, permissão, mês, limite, chamada RPC, auditor, conflito, mês fechado, cache e sanitização de erros. Não é teste de navegador nem sessão real.
- `supabase/tests/payroll_calculation.sql`: passou antes e depois da aplicação das funções, no PostgreSQL do projeto de testes, com fixtures sintéticas de 2000/01 e 2000/02 e `ROLLBACK`. Cobriu abertura, recálculo, permissões, token/revisão obsoletos, origem alterada, colaborador ausente/duplicado, JSON inválido, mês fechado e histórico anterior intacto. Não mede dois clientes realmente simultâneos.
- Advisor de segurança: 22 avisos informativos de RLS sem políticas (acesso de cliente negado por padrão); nenhuma liberação de acesso foi acrescentada para eliminar esses avisos.
- `git diff --check`: passou.

Os testes não recalcularam nem sobrescreveram os registros existentes de 09/2026 e 10/2026. Use Node 24 para os scripts de teste. `npm run test:migration` executa as três suítes locais sem acesso ao banco.

## Bloqueios e funcionalidades pendentes

O preview do commit de base `f630a6f` (`dpl_BLNrnurqUJxSCGQkkHGYMXF8yCJ6`) estava em `ERROR`, com `lint_or_type_error`, antes deste avanço. A leitura dos logs retornou HTTP 403 para o escopo Vercel `marcelostank3-1898`, inclusive com o team ID explícito. O CLI Vercel não está instalado no ambiente.

O ambiente local não tem as dependências da aplicação. O acesso Git falhou por indisponibilidade do proxy; a tentativa de instalar dependências retornou EPERM no registry e foi interrompida. A branch foi recuperada pelo conector GitHub. Build Next.js, verificação TypeScript completa e testes reais na Vercel permanecem pendentes; testes locais não comprovam que o preview funciona.

Edição de colaboradores/lançamentos, operações de comissão, alterações de saúde, cadastro de filhos, dissídio, rescisões, exportações/Storage e ensaios de concorrência com clientes simultâneos ainda precisam de integração e validação. O cálculo dessas entradas existentes usa a v77, mas isso não significa que seus fluxos de edição estejam migrados.

**Migração incompleta. Não liberar produção.**
