# Validação com cadastros fictícios · 13/10/2026

Branch: `migracao-vercel-supabase`. Sem merge ou liberação para produção.

## Cadastros para validação

Competência exclusiva desta rodada: **12/2026**. Novos cadastros identificados por `TEST-FULL-001` a `TEST-FULL-004`, nomes começando com TESTE VALIDACAO, nas agências Centro, Biguaçu, Kobrasol e Palhoça. A última fixture tem admissão em 15/12 para conferir proporcionalidade. Não utilizar esses cadastros em operação real.

O primeiro cadastro foi salvo pelo formulário do preview e confirmado no banco. Os demais foram preparados pelas RPCs da aplicação. A aba salarial do primeiro formulário não foi concluída pelo navegador; a preparação salarial e do tipo de comissão foi feita por RPC. Esses passos não são classificados como testes de interface.

O motor original v77 gerou a competência, com gravação por `save_calculated_finance_period`, token de snapshot e transação. A competência contém os colaboradores fictícios ativos elegíveis já existentes e os quatro novos; nenhuma alteração foi feita nas folhas anteriores.

| Matrícula fictícia | Agência | Salário base | Salário da competência | CQ calculado |
| --- | --- | ---: | ---: | ---: |
| TEST-FULL-001 | Centro | 3.000,00 | 3.000,00 | 240,00 |
| TEST-FULL-002 | Biguaçu | 3.200,00 | 3.200,00 | 256,00 |
| TEST-FULL-003 | Kobrasol | 3.400,00 | 3.400,00 | 272,00 |
| TEST-FULL-004 | Palhoça | 3.600,00 | 1.920,00 | 153,60 |

## Evidências concluídas

- Dez suítes locais passaram: motor/migração, campos, arquivos, lançamentos, edição, prioridades financeiras, comissões, exportação saúde, DSR e segurança. Transporte HTTP simulado não é prova de interação no preview.
- 137 cenários de campos passaram no PostgreSQL real: RPC, gravação/releitura do JSON, snapshot, revisão, auditoria e preservação de uma folha fechada fictícia.
- SQLs reais com rollback passaram para cálculo/criação/edição, inclusão/DSR, cidade/padrão Florianópolis, saúde/creche, reajustes/eventos/rescisão, comissões em lote, fechamento/reabertura, arquivos e segurança.
- Novo teste `supabase/tests/finance_loan_validation.sql` passou: empréstimo fictício de 1.000,00 em duas parcelas, 502,80 e 500,00; preservação do mês anterior; bloqueio de mês futuro fechado; auditoria e acesso privado.
- Testes de exportação leram arquivos XLS/XLSX realmente serializados, com dependentes dinâmicos. Storage nessas suítes usa transporte simulado; SQL de arquivos verifica metadados reais, não upload real.

## Interface real e limitações

Run `6daf7f14-ef7c-49fb-abf7-a591b5ab5350`: comissão bruta de 600,00 e líquida de 500,00 salva pelo botão único e conferida após recarga em TEST-FULL-001; DSR 115,38 confirmado no banco. Empréstimo de 1.000,00 em duas parcelas cadastrado pela interface para TEST-FULL-002, cronograma conferido em Ver parcelas e confirmado no banco (502,80 em 12/2026 e 500,00 em 01/2027). Logout concluído. Nenhuma outra linha foi editada nesse run.

Run `c1570cf3-ed34-415c-9572-8ee6f6e9685e`: mensalidades salvas e recarregadas para TEST-FULL-001, com titular/dependente Unimed (420,00 cada) e titular/dependente Uniodonto (45,00 cada). Nome vazio do dependente foi recusado; após preencher, gravação aprovada. Coparticipação Unimed de 10,00/20,00 persistiu. Filho fictício nascido em 15/01/2020 salvo pela interface, último crédito 01/2027 e situação Elegível em 12/2026. Banco confirmou quatro participantes, uma criança, AG 420,00 e revisão 5. Logout não foi executado antes do limite da ferramenta; sessão deve ser revogada na limpeza da conta temporária. Nenhum teste de duplicação de criança foi feito nessa interação.

Run `6286d3c0-d2b9-40ac-828d-d313bda4ba96`: login e cadastro TEST-FULL-001 com sucesso; rejeição de CPF inválido observada. Persistência confirmada por consulta ao banco. Salário, abertura do mês, recarga e logout não concluídos nesta execução.

Run `5eabfe22-1e7c-4fe0-987d-cecfc9836d1c`: diálogo de competência acessado, mas a ferramenta terminou com erro interno ao manipular o mês. Nenhuma competência foi gravada nessa tentativa. Não caracteriza falha comprovada da aplicação. A abertura foi realizada posteriormente pelo motor e pela RPC, com verificação no banco.

Ainda não declarar validação completa da interface, todas as configurações globais, anexos/Storage, concorrência real, restauração ou liberação de produção. Não aplicar reajuste global nem rescisão em colaborador existente para obter cobertura de teste.

## Proteção do histórico

Referência dos registros até 11/2026: `c823c340dbce652e26d504d3ce2f054c`.
Referência das versões até 11/2026: `60c33a9bd9a10830ffd89d75117a72cc`.
Método: MD5 de `jsonb_agg(to_jsonb(linha) order by month,employee)::text`. As referências permaneceram iguais após a preparação e criação da competência.

Fixtures de SQL com rollback não persistiram. A conta administrativa temporária de automação deve ser removida ao terminar a rodada e a ausência de suas sessões deve ser conferida. Não incluir senha, hash, cookie ou token de compartilhamento nos relatórios.

## Falha encontrada e corrigida

O teste real `finance_configuration_validation.sql` falhou inicialmente: **Normative wage did not refresh eligible childcare**. `save_normative_wage` gravava a referência, mas omitia `childcareRefresh`, presente no caminho original v77 em `lib/finance-service.ts`. Correção em `supabase/finance-normative-wage.sql`, aplicada ao Supabase: bloqueia os períodos envolvidos, salva referência, chama `refresh_finance_childcare` e audita na mesma transação. A fórmula original de 20% foi preservada.

Após a correção, o mesmo teste passou: AG 400,00 → 600,00 no mês aberto, salário preservado, revisão incrementada, mês aberto anterior e fechado intactos, repetição sem alteração adicional. Configurações de mínimo, alimentação, Unimed, Uniodonto e função também foram gravadas e relidas em rollback; conflito de revisão de saúde recusado. A aplicação da função não recalculou dados existentes automaticamente.

Uma segunda falha foi observada no registro fictício após cadastrar a criança: AG 420,00 estava salvo, mas DF 6.096,49 ainda não incluía esse auxílio. A soma dos componentes existentes era 6.516,49. O teste foi ampliado e falhou com **Childcare did not refresh total cost**. `refresh_finance_childcare` agora atualiza DF na mesma gravação, usando a expressão original de `lib/provisions.ts`: CS + AG + CT + CY + AP + DE em centavos. A edição de cadastro também aplica `applyProvisions` original após modificar a elegibilidade do auxílio. GET continua sem gravação; nenhuma regra de cálculo foi substituída.

Regressão real inclui componentes de custo não zerados: salário normativo muda AG 400,00 → 600,00 e DF 5.670,00 → 5.870,00, com salário, meses anteriores e fechados preservados. Teste de edição compara DF com o motor v77 quando o gênero muda e o auxílio deixa de ser devido.

Advisors de segurança executados após a primeira alteração: sem WARN/ERROR; somente INFO de RLS sem política, conforme a arquitetura de acesso exclusivo pelo servidor. As funções continuam sem EXECUTE público.
