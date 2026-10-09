# Recuperação dos cálculos automáticos

Diagnóstico de 09/10/2026: os 19 lançamentos fictícios de setembro e 20 de outubro não continham salaryCompetencia, M e os resultados de custos/provisões. Não eram resultados calculados iguais a zero. O GET original v77 executava refreshMonth antes de ler a folha; o caminho Supabase de leitura ainda não realiza essa atualização. O motor completo original existe e é acionado por abertura, edição e recálculo explícito.

Correção de dados: somente a competência mais recente e aberta, 10/2026, passou pelo calculate original v77 e pelo RPC transacional save_calculated_finance_period, action=recalculate. Os 20 nomes foram verificados como sintéticos antes da operação. Ator de auditoria: migration-v77-synthetic-calculation-recovery. Nenhuma fórmula foi alterada.

Validações reais: 20 resultados comparados com chamada direta ao motor original; presença e validade numérica de salário proporcional, quinquênio e todos os campos automaticCostKeys; repetição idempotente do cálculo; snapshot de origem intacto. Gravação recusaria alterações concorrentes pelo token e revisões. Na transação, hashes dos registros fora de 10/2026 e de todas as versões foram comparados antes/depois e ficaram iguais. Consulta posterior: outubro 20/20 com resultados; setembro 0/19. Setembro permaneceu intacto, em cumprimento da preservação das competências anteriores.

Correção de interface: Conferência da Folha avisa quando faltam resultados de salário/custos/provisões e aponta o botão de atualização já existente. Zero é reconhecido como resultado válido; registros excluídos não entram na contagem. O botão fica desabilitado durante carregamento, para perfis sem edição e em competências fechadas. Não há recálculo silencioso ao ler o histórico. Não se confunde cálculo de exibição com resultado persistido.

Testes: test:migration e test:fields passaram antes da correção de interface; teste novo test-calculation-status passou após a alteração e está incluído em test:migration. Browser E2E continua pendente. Verificar build Vercel do novo commit. Esses resultados não concluem migração, comissões, rescisões ou outros fluxos pendentes.
