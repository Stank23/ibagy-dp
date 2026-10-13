# Senha temporária e primeiro acesso

Após uma redefinição, `app_users.must_change_password=true` impede criar uma sessão normal. A senha temporária correta abre a tela de definição da senha pessoal, sem liberar acesso financeiro. A senha pessoal precisa atender à política vigente e ser diferente da temporária.

`change_finance_password_and_session` confere o hash atual e a conta ativa dentro da transação, troca o hash/salt, retira a obrigação, revoga todas as sessões antigas, cria a sessão e audita sem registrar senha/hash. Uma redefinição concorrente ou reutilização da senha temporária é recusada. Falha ao criar sessão reverte toda a operação.

Aplicar `supabase/finance-first-login.sql` após `security-hardening.sql`. A alteração é aditiva; contas existentes continuam sem obrigação até uma redefinição explícita. Nunca salvar senha temporária em Git, logs ou documentação.

Verificações: `npm run test:security` e `supabase/tests/finance_first_login.sql` (dados fictícios e rollback). Casos de desafio sem acesso, senha incorreta/fraca/igual, hash antigo, revogação, falha atômica e senha pessoal foram conferidos. O build deve ser READY antes de redefinir o administrador no ambiente que executa esse código.

A limpeza total foi autorizada pelo proprietário para o projeto fyaogkhkykntzparaojd, mantendo apenas adm. Não executar esse procedimento como seed, na abertura da aplicação ou como endpoint público. Manter estruturas, RLS e funções. Remover arquivos pela API Storage; apagar metadados SQL não remove os objetos físicos.
