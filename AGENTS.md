# Agent instructions · IBAGY DP

## Prioridade e escopo

As instruções explícitas do usuário prevalecem sobre este arquivo. Trabalhar na branch `migracao-vercel-supabase`. A tarefa atual não autoriza modificar `main`, fazer merge ou publicar produção. Não liberar enquanto houver funcionalidades críticas ou validações incompletas.

Leia [PRD](docs/PRD.md), [Design System](docs/DESIGN-SYSTEM.md), [Architecture](docs/ARCHITECTURE.md) e [relatório de segurança](docs/security-validation-2026-10-13.md). O [guia visual de agentes](docs/AGENT-INSTRUCTIONS.md) explica o processo; este arquivo é a fonte operacional concisa.

## Regras obrigatórias

- Testar somente com dados fictícios. Não expor usuários reais, valores pessoais, senhas, hashes de senha, cookies, tokens de compartilhamento, chaves Supabase ou arquivos .env em logs/documentos/commits.
- Conferir a versão 77 antes de alterar fórmulas, arredondamentos ou regras de DP. `lib/finance-service.ts`, `lib/rules.ts`, `lib/benefits.ts`, `lib/commission.ts` e `lib/provisions.ts` são referências ativas, não arquivos descartáveis.
- Preservar competências anteriores e fechadas. Usar vigência, revisão e snapshot/CAS; não contornar conflitos sobrescrevendo dados. GET não deve gravar/recalcular a folha silenciosamente.
- Não executar reset ou seeds em produção. SQL de teste usa fixtures fictícias e rollback. Contas/arquivos temporários de teste devem ser removidos e a limpeza confirmada.
- A chave service_role permanece no servidor. RLS não a limita; toda API verifica autenticação/perfil. Não abrir privilégios públicos para corrigir erro de integração.
- Não considerar uma funcionalidade pronta sem testes relevantes. Informar o tipo de evidência: código/HTTP simulado, banco real ou interface real.

## Fluxo de trabalho

1. Verificar `git status`, branch e HEAD. Preservar trabalho do usuário.
2. Localizar chamadas com `rg`; ler consumidores, domínio, scripts, configuração e imports dinâmicos.
3. Implementar o escopo autorizado em mudanças pequenas. Testes, commits e operações reversíveis na branch de migração já autorizados não exigem confirmação repetida.
4. Rodar verificações proporcionais à mudança e conferir build/deploy do commit correto. Se o ambiente impedir a execução, registrar o erro e usar evidência equivalente disponível, sem declarar o teste executado.
5. Publicar somente a branch de migração. Com conectores GitHub, construir árvore sobre HEAD atual e atualizar ref com `expected_sha`, sem force. Não sobrescrever alteração concorrente.
6. Manter os quatro documentos consistentes com o código. Registrar pendências de merge/produção e links úteis.

Se uma escrita expirar ou perder resposta, consultar o estado antes de repetir. Se um teste de navegador ainda estiver executando, acompanhar a mesma execução. Não inventar sucesso nem transformar limitação da ferramenta em falha confirmada do sistema.

## Verificações disponíveis

- Motor/campos: `npm run test:migration`, `npm run test:fields`.
- Cadastro: `npm run test:employee-edit`.
- Comissão/saúde: `npm run test:record-actions`, `npm run test:commissions`, `npm run test:health-export`.
- DSR: `npm run test:dsr-city`.
- Integrações: `npm run test:priority-actions`.
- Arquivos: `npm run test:files`.
- Segurança: `npm run test:security`.
- Alvo Vercel: `npm run build:vercel` e conferir READY do SHA correto.

Não ampliar/repetir testes sem nova alteração, falha ou dúvida relevante. Não escrever teste que apenas espelha uma mudança visual simples. Conferir referências/build e fluxo quando apropriado.

## Organização e limpeza

`app/`, `components/ui/`, `lib/` e `proxy.ts` formam o caminho ativo. `scripts/`, `tools/ui-tests/` e `supabase/tests/` sustentam a validação. `supabase/` e `drizzle/` são estruturas/migrações diferentes; não executar todos os SQLs indiscriminadamente. A ordem de aplicação exige revisão, especialmente as substituições de DSR e autenticação.

`build/`, Cloudflare, connectors e `db/` ainda são referenciados pelo caminho legado e por scripts. Não removê-los até existir um plano verificado para aposentá-los. Vercel usa Next; os comandos dev/build/start genéricos não são automaticamente o mesmo ambiente.

Antes de excluir um arquivo, conferir referências transitivas, build/testes/deploy, migrations, assets e licenças. Registrar caminho e motivo. `vendor/xlsx-0.20.3.tgz` é o pacote usado: não substituir por cópia da raiz ou pacote desatualizado. Não enfraquecer a política de dependências para instalar offline.

## Evidência e comunicação

Resumir o que mudou, por quê, testes reais e seus limites. Fazer atualizações curtas durante trabalho prolongado. Não divulgar credenciais em mensagens ou relatórios. Preservar a interface e as regras, salvo alteração expressamente solicitada. Não declarar a migração ou a validação completa antes da evidência.
