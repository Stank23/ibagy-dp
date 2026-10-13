# Validação de segurança — IBAGY DP — 13/10/2026

Escopo: branch migracao-vercel-supabase, Supabase fyaogkhkykntzparaojd e preview Vercel. Sem publicação em produção. Testes usam dados fictícios; os testes SQL são revertidos por rollback. Nenhuma senha de conta existente foi alterada.

## Problemas confirmados e correções

1. Os papéis anon/authenticated tinham 308 concessões em 22 tabelas, incluindo TRUNCATE, que não depende de RLS. O REST comum não oferece TRUNCATE, mas essas permissões eram desnecessárias e não devem ser tratadas como protegidas por RLS. Concessões públicas removidas das 23 tabelas. O servidor mantém acesso e verifica a conta/perfil.
2. Cabeçalhos de segurança, restrições de origem de GET e limites globais da versão Cloudflare não estavam no caminho Next/Vercel. Proxy adiciona CSP, HSTS, nosniff, política de referência/permissões, proteção de métodos, bloqueio de source maps/dotfiles, origem de API e quota por IP. Identificação de IP no Vercel ignora cabeçalho Cloudflare fornecido pelo cliente. POSTs continuam validando origem/corpo no próprio handler.
3. Diagnóstico migration-health era anônimo e criava chaves aleatórias na tabela de tentativas. Agora exige administrador, limita chamadas por usuário e não cria uma chave nova por acesso.
4. Criação de sessão não reconferia senha/estado dentro da transação. RPC confere hash esperado, conta ativa, revoga token anterior, limpa sessões expiradas da conta e limita a cinco sessões. Uma senha alterada durante login invalida a tentativa.
5. Alterações de contas não eram atômicas com a revogação e não tinham auditoria. RPC reconfere administrador dentro da transação, impede autodesativação/autorrebaixamento, altera conta, revoga sessões e grava evento sem senha/hash. O service_role pode inserir/consultar auditoria, mas não alterar, excluir ou truncar seus eventos. O proprietário do banco continua privilegiado.

## Evidências

- Banco: 23 tabelas public com RLS; zero funções public executáveis por anon/authenticated; bucket ibagy-finance-private não público; nenhuma view public; papéis comuns não podem criar objetos no esquema public; funções têm search_path configurado; zero contas com formato estrutural inválido.
- Após correção: zero concessões diretas públicas às tabelas. Isso não autoriza acesso direto do navegador: a arquitetura continua usando autenticação própria e service_role exclusivamente no servidor.
- test:security: handlers reais com transporte simulado verificam login, senha incorreta, CAS, cookies, registro pendente sem escalada de perfil, limites, anônimo/viewer/admin, CSRF de leitura/escrita, erros sanitizados e proxy.
- supabase/tests/security_hardening.sql: banco real com rollback verifica permissões, bucket privado, limite de sessões, login com hash antigo recusado, revogação atômica por senha/perfil, conta inativa, proteções de administrador e auditoria sem hash.
- Arquivo de download: nome com CR/LF não injeta cabeçalho e entrega é attachment/nosniff. Nome de colaborador começando com fórmula foi lido do Excel como texto, sem célula de fórmula.
- Advisors do Supabase: apenas 23 avisos INFO de RLS sem políticas, coerentes com acesso exclusivo pelo backend; nenhum WARN/ERROR reportado.
- Suítes de migração, 137 campos/33 ações, arquivos, edição, prioridades financeiras, DSR e exportação de saúde passaram após as mudanças.

## Limites e verificações ainda necessárias

Build do commit 6dd4778 confirmado READY na Vercel. O teste TinyFish 477e796b-6f43-46ac-8e77-991c42a488b5 foi bloqueado pela autenticação de equipe da Vercel, antes de chegar à aplicação. O conector retornou 403 ao solicitar acesso temporário, incluindo tentativa com a equipe explícita. Portanto status/cabeçalhos e login/perfis/logout no deployment não foram comprovados. Duas contas fictícias temporárias foram criadas para essa tentativa; ambas foram removidas e não chegaram a gerar sessões. É necessário um link temporário de acesso ao preview ou conexão Vercel com acesso ao projeto/equipe para continuar.

O transporte HTTP do shell não alcança o proxy de rede; npm audit/consulta atualizada ao registro de dependências não foi executada. Não afirmar ausência de dependências vulneráveis.

Senhas existentes que não atendem à política não recebem sessão; o fluxo de troca obrigatória na interface ainda está incompleto. Nenhuma senha foi redefinida durante esta revisão.

CSP de HTML mantém unsafe-inline para compatibilidade com a aplicação; migração para nonce e testes de XSS com navegador permanecem necessários. Proteções não substituem validação/escape; React escapa dados renderizados e arquivos são entregues como attachment/nosniff.

Os testes de revisão/CAS cobrem conflitos e atomicidade no banco, mas não constituem teste de carga concorrente multi-processo. Teste independente de intrusão, recuperação de backups, limites de retenção e rotação de credenciais permanecem fora desta evidência.

Não considerar o sistema liberado para produção com base neste relatório.
