# Integração Supabase: progresso e pendências

Branch migracao-vercel-supabase. Main intacta. Produção bloqueada.

Novos caminhos implementados: exportações commission/health/payroll com layouts v77 intactos, Storage privado, metadados versionados, auditoria e download autenticado; documentos multipart; commission_value, health_sync, health_copart, health_copart_bulk e health_monthly_bulk.

Testes locais reais dos geradores: todos os valores e nomes de abas dos XLS/XLSX comparados aos layouts originais. Testes HTTP com transporte Storage/REST simulado: upload, download, privacidade, falhas, limpeza de objetos não confirmados, metadados, autorização e ausência de alterações nos lançamentos. Original commissionAmounts, applyHealthRates e validateBenefits reutilizados, sem fórmulas reescritas. Testes de comissões/saúde: DSR, comissão fechada, participantes removidos, plano incorreto, valores negativos, duplicatas, revisão e competência fechada.

Testes reais no banco (rollback): arquivos/auditoria atomicamente gravados, token e período alterado recusados, duplicata recusada, histórico e folha intactos; lote de saúde sem gravação parcial, calendário/revisões alterados recusados, comissão fechada, revisões/auditoria e privilégios service_role. Migrações immutable_finance_file_metadata e atomic_commission_health_record_actions aplicadas.

Nenhum bucket existia na inspeção inicial. O servidor cria ibagy-finance-private via API Storage privada na primeira operação e rejeita um bucket público existente. O ciclo real Storage → app → download ainda precisa ser executado na Vercel; mocks não provam esse ciclo. Não declarar exportações/documentos concluídos até a validação real. Nenhuma URL pública ou signed URL é enviada ao navegador neste caminho.

O limite original de documentos é 15MB; uploads multipart maiores que o limite de corpo da Vercel podem ser recusados antes do handler. Isso permanece pendente de um fluxo de upload direto autorizado ao Storage. Não afirmar suporte real a 15MB no preview atual.

Exportação é recusada se faltam cálculos automáticos. Portanto 09/2026 ainda pode retornar 409 por resultados ausentes, em vez do antigo 503 por ação inexistente; 10/2026 possui 20 registros calculados. Os registros mensais não são recalculados nem alterados durante exportação.

Ações que permanecem explicitamente bloqueadas na matriz HTTP: employee_edit, include, dsr_setting, health_base, childcare_child, childcare_sync, event_plan, salary_preview, salary_adjust, salary_rows_preview, salary_rows_apply, termination_preview, termination_save. Também permanecem pendentes a troca obrigatória de senha fraca e a integração completa da atualização mensal automática.

Validação executada: test:migration, test:fields (137 cenários +33 ações), test:files, test:record-actions, finance_files.sql e finance_record_actions.sql. Matriz reduziu de 19 para 13 ações bloqueadas; cadastro/edição e rescisões ainda são críticos. Segurança: advisory informativo RLS sem políticas (acesso cliente negado por padrão); funções novas não são executáveis por anon/authenticated.
