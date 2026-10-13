# Integração Supabase: progresso e pendências

Branch migracao-vercel-supabase. Main intacta. Produção bloqueada.

Novos caminhos implementados: exportações commission/health/payroll com layouts v77 intactos, Storage privado, metadados versionados, auditoria e download autenticado; documentos multipart; commission_value, health_sync, health_copart, health_copart_bulk e health_monthly_bulk.

Testes locais reais dos geradores: todos os valores e nomes de abas dos XLS/XLSX comparados aos layouts originais. Testes HTTP com transporte Storage/REST simulado: upload, download, privacidade, falhas, limpeza de objetos não confirmados, metadados, autorização e ausência de alterações nos lançamentos. Original commissionAmounts, applyHealthRates e validateBenefits reutilizados, sem fórmulas reescritas. Testes de comissões/saúde: DSR, comissão fechada, participantes removidos, plano incorreto, valores negativos, duplicatas, revisão e competência fechada.

Testes reais no banco (rollback): arquivos/auditoria atomicamente gravados, token e período alterado recusados, duplicata recusada, histórico e folha intactos; lote de saúde sem gravação parcial, calendário/revisões alterados recusados, comissão fechada, revisões/auditoria e privilégios service_role. Migrações immutable_finance_file_metadata e atomic_commission_health_record_actions aplicadas.

Nenhum bucket existia na inspeção inicial. O servidor cria ibagy-finance-private via API Storage privada na primeira operação e rejeita um bucket público existente. O ciclo real Storage → app → download ainda precisa ser executado na Vercel; mocks não provam esse ciclo. Não declarar exportações/documentos concluídos até a validação real. Nenhuma URL pública ou signed URL é enviada ao navegador neste caminho.

O limite original de documentos é 15MB; uploads multipart maiores que o limite de corpo da Vercel podem ser recusados antes do handler. Isso permanece pendente de um fluxo de upload direto autorizado ao Storage. Não afirmar suporte real a 15MB no preview atual.

Exportação é recusada se faltam cálculos automáticos. Portanto 09/2026 ainda pode retornar 409 por resultados ausentes, em vez do antigo 503 por ação inexistente; 10/2026 possui 20 registros calculados. Os registros mensais não são recalculados nem alterados durante exportação.

As 12 ações financeiras antes bloqueadas foram integradas: include, dsr_setting, health_base, childcare_child, childcare_sync, event_plan, salary_preview, salary_adjust, salary_rows_preview, salary_rows_apply, termination_preview e termination_save. A matriz HTTP passa pelas 33 ações com transporte simulado; zero ações dessa matriz retornam 503 por ausência de integração. Isso não comprova interface ou transporte real da aplicação.

Validação executada: test:migration, test:fields (137 cenários +33 ações), test:files, test:record-actions, finance_files.sql e finance_record_actions.sql. Matriz atual: 33 ações testadas, zero bloqueadas por ausência de integração; validação de interface continua pendente. Segurança: advisory informativo RLS sem políticas (acesso cliente negado por padrão); funções novas não são executáveis por anon/authenticated.

Edição de cadastro: controle de versão esperado no formulário, RPC atômica e vigência mensal. Testes de regras e banco com rollback preservam salário mensal, competências anteriores, períodos fechados e versões futuras; alterações concorrentes são recusadas. Migração atomic_employee_edit_preserve_monthly_history aplicada. Teste de interface permanece pendente.

Prioridade das 12 ações: motor calculate, comissão, validação de benefícios, preços de saúde, reajustes, resumo de rescisão e saldos reutilizados da versão 77. SQL PostgreSQL do auxílio-creche e eventos conferido contra as consultas originais. Atualizações de filhos começam na competência selecionada e eventos não podem iniciar antes dela para preservar registros anteriores. Auxílio-creche pode atualizar períodos posteriores abertos; rescisão marca lançamentos posteriores abertos como carry conforme v77 e rejeita períodos posteriores fechados.

Testes novos: test:priority-actions; banco real com rollback finance_inclusion_dsr.sql, finance_health_childcare.sql e finance_salary_events_termination.sql. CAS, revisão, idempotência, auditoria, acesso service_role, registros anteriores e fechados foram verificados. Falha SQL inicial por alias do loop no auxílio-creche corrigida por fix_childcare_record_alias. Todos os testes locais anteriores também passaram. RLS segue negando acesso direto ao cliente; advisors apenas INFO sem políticas.

Permanecem pendentes fora das 12 ações: troca obrigatória de senha, atualização mensal automática no GET, armazenamento real e limite de upload, testes de interface e concorrência sob carga. Build do novo commit precisa ser confirmado. Não liberar produção nem declarar migração completa.
