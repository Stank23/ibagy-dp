# Alterações do IBAGY DP

## Versão 2.00.01

- Identificação pública da versão no cabeçalho e metadados do sistema. O pacote utiliza a versão SemVer equivalente `2.0.1`.
- As referências históricas à versão 77 continuam identificando o motor original de cálculo.

## 14/10/2026 · Quitação SEREFI e conferência

- Quitação antecipada por pagamento fora da folha: prévia, data e referência, cronograma original preservado, atualização de folhas abertas pelo motor v77, auditoria e proteção contra conflitos/repetições.
- Conferência com colunas alternadas sem cor e rosa pastel, incluindo cabeçalhos e ações.
- Testes fictícios de domínio, HTTP e transação PostgreSQL com rollback; validação visual autenticada ainda pendente.

## Branch de migração · ainda não liberada para produção

- Senha temporária com troca obrigatória no primeiro acesso: bloqueio antes da sessão financeira, senha pessoal distinta, revogação e criação de sessão em transação auditada.

- Integrações financeiras com Supabase, transações, revisões e preservação do histórico mensal.
- Comissão com botão único; calendários DSR por cidade com Florianópolis como padrão e exceções individuais.
- Exportações de saúde com colunas conforme a quantidade de dependentes.
- Proteções de APIs na Vercel; autenticação e auditoria transacionais; privilégios públicos removidos.
- Limpeza de componentes/demonstrações/duplicatas sem referência funcional e documentação do sistema.
- Validação com quatro novos cadastros fictícios em 12/2026; comissão e SEREFI pela interface. Correção da atualização automática do auxílio-creche ao alterar salário normativo, preservando o comportamento v77 e meses anteriores/fechados.
- Total de custos atualizado na mesma gravação do auxílio-creche ou de uma edição que altere a elegibilidade, usando as provisões originais da versão 77.
- Alteração de calendário DSR também atualiza os custos/provisões pelo motor original. Rodada fictícia inclui exportações e fechamento/reabertura pela interface, e exemplos de reajuste, cursos/multa e rescisão gravados pelo motor/RPC.

Os resultados detalhados, commits e limites de validação estão em docs/. O histórico original da versão 77 e da biblioteca SheetJS permanece no Git e no pacote vendor. Nenhuma regra financeira foi alterada pela limpeza.
