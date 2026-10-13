# Alterações do IBAGY DP

## Branch de migração · ainda não liberada para produção

- Integrações financeiras com Supabase, transações, revisões e preservação do histórico mensal.
- Comissão com botão único; calendários DSR por cidade com Florianópolis como padrão e exceções individuais.
- Exportações de saúde com colunas conforme a quantidade de dependentes.
- Proteções de APIs na Vercel; autenticação e auditoria transacionais; privilégios públicos removidos.
- Limpeza de componentes/demonstrações/duplicatas sem referência funcional e documentação do sistema.
- Validação com quatro novos cadastros fictícios em 12/2026; comissão e SEREFI pela interface. Correção da atualização automática do auxílio-creche ao alterar salário normativo, preservando o comportamento v77 e meses anteriores/fechados.
- Total de custos atualizado na mesma gravação do auxílio-creche ou de uma edição que altere a elegibilidade, usando as provisões originais da versão 77.

Os resultados detalhados, commits e limites de validação estão em docs/. O histórico original da versão 77 e da biblioteca SheetJS permanece no Git e no pacote vendor. Nenhuma regra financeira foi alterada pela limpeza.
