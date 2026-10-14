# Reinício reversível do IBAGY DP

Aplicado em 13/10/2026, mediante autorização explícita. Projeto Supabase: `fyaogkhkykntzparaojd`.

## O que mudou

Vinte tabelas financeiras foram movidas, sem exclusão de registros, de `public` para `ibagy_archive_20261013`. Tabelas novas e vazias, com a mesma estrutura, índices, restrições e vínculos, foram criadas em `public`. As funções da aplicação foram recompiladas para usar as tabelas ativas.

O administrador `adm` e as tabelas de autenticação permaneceram ativos. Nenhuma senha ou chave integra este documento. Configurações financeiras também começaram vazias e precisam ser cadastradas antes do uso da folha.

## Evidência

- Ensaio de arquivamento com rollback: área ativa vazia; 25 colaboradores preservados; acesso ao esquema privado negado para `service_role`.
- Ensaio de restauração com rollback: 25 colaboradores e 82 lançamentos recuperados.
- Aplicação efetiva: zero colaboradores, competências e lançamentos na área ativa; 25 colaboradores, quatro competências e 82 lançamentos arquivados.
- Contagens e resumos criptográficos das vinte tabelas conferidos durante a transação, sem imprimir conteúdo pessoal.
- RLS habilitada em todas as tabelas públicas e privadas; acesso ao arquivo negado a `anon`, `authenticated` e `service_role`.
- RPC de snapshot executada com o perfil do servidor após a alteração.

## Recuperação

Somente o proprietário do banco pode executar `supabase/restore-finance-archive.sql` dentro de uma transação. Revisar primeiro alterações de esquema e de funções feitas depois deste arquivamento. O procedimento preserva também os novos registros: move as tabelas atuais para `ibagy_after_archive_20261013`, antes de devolver as antigas para `public`. Não combina duas histórias automaticamente.

Arquivamento: `supabase/archive-finance-reversible.sql`. Esses arquivos são procedimentos operacionais de execução única, não scripts para rodar a cada deployment. O arquivamento exige exatamente as 23 tabelas originais e um único administrador ativo.

## Limite importante

Os sete arquivos físicos removidos anteriormente do Storage não são recuperáveis por este arquivamento. Seus metadados órfãos já foram removidos. Os registros financeiros foram preservados, não apagados. O teste completo pela interface continua pendente.
