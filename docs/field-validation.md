# Validação de campos — IBAGY DP v77

Branch: migracao-vercel-supabase. Main preservada. Testes exclusivamente fictícios.

118 campos do catálogo e 19 controles adicionais passaram por normalização, edição/cálculo do motor original e comparação após gravação e leitura via RPC no Supabase. Campos calculados, preservados e imutáveis têm expectativas distintas; passar não significa que sejam editáveis. 118 entradas inválidas foram rejeitadas.

O teste real de banco executou 137 cenários em transação com ROLLBACK, verificando JSON integral, revisão, auditoria, recarga do snapshot e histórico de uma competência anterior. Não alterou os registros de 09/2026 e 10/2026. Pode ser reproduzido gerando fixtures com test:fields e SQL com scripts/build-field-database-test.mjs; revisar guardas antes de executar no banco.

137 cenários também passaram pelos handlers HTTP reais com transporte Supabase simulado, incluindo POST, GET e histórico. Isso não comprova a comunicação REST real nem o navegador. 33 ações foram verificadas e 19 continuam retornando 503 sem gravar dados.

Correções: salário normativo agora usa o RPC existente save_normative_wage; admissão anterior a 2000 aceita no handler e no cadastro transacional, como na versão original. Persistência do salário normativo e cadastro fictício de 1995 foram validados no banco com rollback; a migração preserve_v77_pre2000_employee_admission foi aplicada.

Ações sem integração: employee_edit, include, commission_value, dsr_setting, health_base, health_sync, health_copart, health_copart_bulk, health_monthly_bulk, childcare_child, childcare_sync, event_plan, salary_preview, salary_adjust, salary_rows_preview, salary_rows_apply, termination_preview, termination_save, export.

A revisão também encontrou que a troca obrigatória de senha fraca envia newPassword na interface, mas a API Supabase não o processa. Continua pendente de implementação e testes HTTP. Documentos ainda dependem do armazenamento antigo. Nenhuma dessas funcionalidades está concluída.

O preview do commit 2eb34c0 está READY. A abertura pelo conector falha com 403 ao obter autorização para deployment protegido, inclusive após reconexão. Testes pela interface, uploads, exportações e todos os controles dos fluxos ainda incompletos permanecem pendentes. Não liberar produção.

Suites executadas: test:migration (aritmética, paridade v77, edição e segurança HTTP) e test:fields. Build local não executado porque dependências não puderam ser instaladas neste ambiente. Verificar build do novo commit na Vercel.
