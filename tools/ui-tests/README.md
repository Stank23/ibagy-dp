# Testes pela interface no Windows

Executar exclusivamente na branch `migracao-vercel-supabase`. Não modifica main. Requer Node.js 22+ e Git. Instala Playwright/Chromium em um pacote separado; não altera as dependências da aplicação nem o lockfile principal.

## Primeira execução: leitura

Na pasta do repositório, abra PowerShell e execute:

```powershell
git switch migracao-vercel-supabase
git pull --ff-only origin migracao-vercel-supabase
.\testar-interface-windows.cmd
```

Se o Git indicar alterações locais ou conflito, pare e informe a mensagem; não use reset ou force. O arquivo `.cmd` verifica a branch antes de instalar qualquer pacote.

Um Chrome separado abre o preview verificado do commit d255abc. Faça login nessa janela; a sessão do Chrome habitual não é reaproveitada. Digite usuário/senha apenas no navegador. Depois de ver o painel, volte ao terminal e pressione Enter. O teste não salva cookies ou senha e fecha a sessão ao terminar. Acesso externo que exija POST (por exemplo SSO da Vercel) é bloqueado por proteção do teste; nesse caso informe a falha, sem desativar a proteção do deployment.

O teste verifica a sessão real, percorre as telas e abas acessíveis ao perfil, inventaria controles visíveis e registra erros HTTP/JavaScript. POST de login/logout é permitido; outras gravações são bloqueadas. Não clica em salvar, gerar arquivo ou aprovar contas. Controles desabilitados são inventariados; não se afirma que funcionam. Uma falha de tela não impede a inspeção das outras.

Relatório: `tools/ui-tests/reports/ui-report.json`. Envie somente esse JSON. Não há screenshots, valores de folha, mensagens completas de servidor, cookies, tokens ou senha. Rótulos e identificadores de controles são registrados para localizar campos sem vínculo. Não envie arquivos de sessão ou .env.

## Gravação opcional, isolada

Não execute este modo na primeira rodada. Precisa de uma competência exclusiva `2099-12`, aberta, e exatamente um registro com matrícula `TEST-UI-001` e nome começando por `TESTE UI`. A conta deve ter edição. O script não cria competências, colaboradores nem configurações. Prepare essa fixture somente após revisão da primeira rodada; não use funcionário real e não transforme funcionário existente em fixture.

```powershell
.\testar-interface-windows.cmd --write --registration=TEST-UI-001
```

O guard permite exclusivamente POST `record` desse colaborador em `2099-12`. Todos os outros meses, colaboradores e ações (inclusive configurações, exportações e criação de período) são bloqueados. Testa os campos monetários `W`, `Z` e `AA` pelo formulário de Conferência da Folha, salva, recarrega pela API real e reabre o formulário. Restaura os valores iniciais e compara o histórico anterior desse colaborador. A gravação aumenta revisões e produz auditoria mesmo ao restaurar valores; não promete desfazer auditoria. Se a restauração falhar, o relatório marca revisão manual necessária. Não testa todos os campos, motor completo, concorrência, uploads ou exportações.

## Validação deste pacote

Executados no ambiente de desenvolvimento: sintaxe de run.mjs e testes de guardas (domínio de produção, tokens na URL, acesso externo, gravação histórica, colaborador errado, fixture não fictícia e competência fechada/ausente). Playwright e Chromium não foram executados neste ambiente: a rede local não alcança o proxy e as dependências não estão disponíveis. Os resultados de navegador só podem ser registrados após executar no Windows.
