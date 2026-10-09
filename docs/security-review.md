# Revisão de segurança — 08/10/2026

A aplicação é pública na plataforma de hospedagem, mas seus dados exigem uma conta local ativa. Cadastros novos ficam pendentes até aprovação de um administrador. Permissões são verificadas no servidor.

## Correções

- Limites persistentes e atômicos de requisições, incluindo tentativas simultâneas: login por IP (30/15 minutos) e conta (10/15 minutos), cadastro (5/15 minutos), APIs (240/minuto), escritas financeiras (120/minuto por usuário), uploads (10/minuto) e exportações (10/minuto). A origem de rede usa o cabeçalho sobrescrito pela borda Cloudflare, nunca `X-Forwarded-For` fornecido pelo cliente.
- POST exige Origin do próprio site. GET de API rejeita origem explicitamente externa e contexto cross-site. Corpo JSON limitado e validado; uploads limitados mesmo sem Content-Length.
- Cookies de sessão com prefixo __Host-, Secure, HttpOnly e Partitioned. Apenas hashes dos tokens ficam no banco. Rotação no login, máximo de cinco sessões por usuário e revogação na alteração de senha ou permissão e desativação da conta.
- Registro público nunca aceita papel de administrador. Respostas genéricas evitam indicar se um cadastro ou login existe. Contas legadas com senha fraca precisam escolher uma senha adequada ao entrar.
- Downloads exigem autenticação, usam attachment e nosniff. Uploads restringem extensões e tamanho; não incluem antivírus.
- Cabeçalhos contra interpretação indevida de conteúdo, vazamento de referência e enquadramento por terceiros; respostas privadas não são armazenadas em cache. CSP restringe recursos ao próprio site. Scripts inline continuam necessários para renderização Vinext; não há avaliação dinâmica liberada.
- Server Actions e otimização remota de imagens, recursos não usados pelo sistema, não aceitam chamadas públicas. Source maps e caminhos .env/.git são bloqueados pelo Worker.
- Atualização de Next, React/RSC, Vite, SheetJS e dependências transitivas com versões corrigidas. SheetJS 0.20.3 vem do pacote oficial, versionado em vendor.

## Verificação

Testes locais de origem/CSRF, formato e limite do corpo, quotas atômicas, tentativas por conta/IP, flags de cookie, hashes de sessão, registro pendente, autorização e logout passaram. Compilação e TypeScript passaram; exportações XLS/XLSX mantiveram valores e estilos. Pacote cliente examinado: sem chaves privadas, padrões de credenciais de provedores, tabelas/tokens de sessão ou hashes de senha; sem arquivos source map.

A execução do Worker via Wrangler local foi impedida por erro do ambiente (`uv_interface_addresses`). Não foi realizado teste visual no navegador nem teste de intrusão externo independente.

## Limitação conhecida

`braces` 3.0.3, usada por ferramentas de compilação/lint, tem alerta de esgotamento de pilha com padrões profundamente aninhados, sem versão corrigida no registro consultado. O código de compilação não recebe padrões de usuários do sistema. A atualização deve ser acompanhada. Esta revisão reduz riscos e não constitui garantia de ausência de vulnerabilidades.
