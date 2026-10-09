# Recuperação completa do código

Origem: última versão publicada do IBAGY · Departamento Pessoal, versão 77.
Commit original: 5caf1bb7ecf989a79a805bf7200e8efba065194f.

Este pacote inclui o código-fonte integral, configurações, package.json, lockfile pnpm, logo, pacote oficial SheetJS e scripts necessários para reconstruir o site. Inclui também os SQLs da estrutura inicial preparada no Supabase, ainda não ligada ao site.

A única remoção no código funcional é o INSERT com credenciais do administrador inicial em drizzle/0007_local_login.sql, atendendo ao pedido de não incluir senhas/chaves. Identificadores de campos password_hash/salt e funções de autenticação são código necessário, não credenciais. A documentação README e a regra de ignorar arquivos gerados foram atualizadas para explicar a migração e a importação.

Não inclui dados reais do banco, anexos do R2, contas, sessões, arquivos .env, tokens, chaves privadas, node_modules, arquivos temporários de compilação ou histórico .git. As dependências são instaladas pelo pnpm a partir de package.json/pnpm-lock.yaml.

## Primeiro administrador em uma instalação nova

Use a tela de cadastro para criar sua conta com uma senha própria. Um administrador do banco deve promover apenas essa conta para role=admin e active=1. Não há senha padrão incluída. Não execute migrações de criação/reset em um banco de produção já existente.

## Uso no GitHub

Extraia o ZIP, mantenha arquivos ocultos como .gitignore/.openai e envie o conteúdo da pasta ibagy-dp ao repositório privado. A conexão do site e os segredos do servidor precisam ser configurados na hospedagem; enviá-los ao GitHub não é necessário nem seguro.

## Supabase

A migração não está concluída. O código publicado continua usando D1/R2. Os SQLs em supabase/ representam a preparação do banco PostgreSQL. A camada de acesso, transferência dos dados e validação precisam ser concluídas antes de trocar o banco em produção.
