# Preparação do PostgreSQL

Projeto: DP - Ibagy. Referência: bvoyrulflvlirwbtnkku. Preparado em 09/10/2026.

schema.sql e backend-policies.sql são cópias dos SQLs já aplicados pelas migrações remotas ibagy_initial_private_schema e ibagy_backend_policies_and_indexes. Não reaplique no projeto existente: CREATE SCHEMA/TABLE/POLICY não é idempotente. Eles servem para revisão e reprodução em um banco novo.

22 tabelas ficam no schema ibagy, sem USAGE ou SELECT para anon/authenticated. Todas possuem RLS e política exclusiva service_role. O acesso deve passar pelo servidor da aplicação, com aprovação/permissões verificadas por operação; a chave secret/service_role nunca pode ir ao cliente. O schema não precisa ser aberto à Data API do navegador.

Valores financeiros mantêm a representação em centavos. JSON permanece como texto validado, para conservar o formato da aplicação durante a portabilidade. IDs e competências mantêm suas chaves e relacionamentos. Timestamps numéricos usam bigint para suportar milissegundos.

Verificação após aplicação: 22 tabelas com RLS, zero tabelas legíveis por clientes, zero alertas de segurança no Advisor. O banco ainda não contém os registros financeiros do D1 nem usuários importados.

Próximas etapas: adaptar SQLite/D1 para PostgreSQL; escolher acesso do servidor compatível com HTTP (Sites não suporta conexão TCP direta); preservar transações e controle de revisão; migrar dados com conferência por tabela; validar login, rate limiting, cálculos e exportações; somente então alterar o provedor em produção.
