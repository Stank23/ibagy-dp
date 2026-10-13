# Validação com cadastros fictícios · 13/10/2026

Branch: `migracao-vercel-supabase`. Sem merge ou liberação para produção.

## Cadastros para validação

Competência exclusiva desta rodada: **12/2026**. Novos cadastros identificados por `TEST-FULL-001` a `TEST-FULL-004`, nomes começando com TESTE VALIDACAO, nas agências Centro, Biguaçu, Kobrasol e Palhoça. A última fixture tem admissão em 15/12 para conferir proporcionalidade. Não utilizar esses cadastros em operação real.

O primeiro cadastro foi salvo pelo formulário do preview e confirmado no banco. Os demais foram preparados pelas RPCs da aplicação. A aba salarial do primeiro formulário não foi concluída pelo navegador; a preparação salarial e do tipo de comissão foi feita por RPC. Esses passos não são classificados como testes de interface.

O motor original v77 gerou a competência, com gravação por `save_calculated_finance_period`, token de snapshot e transação. A competência contém os colaboradores fictícios ativos elegíveis já existentes e os quatro novos; nenhuma alteração foi feita nas folhas anteriores.

Valores na abertura, antes dos exemplos posteriores de reajuste e rescisão:

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

Run `4015965c-563f-47f7-ac26-b1eb8b506e28`: calendários salvos para Florianópolis 25/6 e Biguaçu 24/7; comissão de TEST-FULL-001 passou a DSR 144,00 e IR 244,00; comissão fechada/reaberta. Campo “Adiantamento salarial” não localizado, nenhuma edição mensal feita. Não foram concluídos exportações, fechamento da folha ou logout nesse run. São José/Palhoça foram relatadas como 26/5 pela ferramenta, sem confirmação de recarga/competência do calendário; não declarar falha de herança. Consulta real mostrou commissionUseful/Rest 25/6 nos registros TEST-FULL-003/004, sem calendários individuais, e 24/7 no TEST-FULL-002.

Run `d4aaf181-b75f-4a95-9ab8-bbb143a39002`: três exportações geradas pela interface, confirmadas na lista e no banco; folha fechada e consultada com status Fechada, reaberta com motivo fictício; comissão reaberta; logout concluído. 12/2026 terminou aberta. Não houve inspeção do conteúdo dos arquivos pelo navegador nem tentativa de escrita pela API enquanto o mês estava fechado nesta interação; bloqueios têm evidência separada nos testes de código/banco.

Arquivos privados desta rodada, gerados antes dos exemplos posteriores de reajuste/rescisão: `IBAGY-Comissao-dia20-2026-12-7c12e1.xlsx`, `IBAGY-Unimed-Uniodonto-2026-12-13f34d.xls`, `IBAGY-Folha-principal-2026-12-d64f76.xls`. São versões fictícias do estado naquele momento, não arquivos contábeis para uso real.

Ainda não declarar validação completa da interface, todas as configurações globais, anexos/Storage, concorrência real, restauração ou liberação de produção. Não aplicar reajuste global nem rescisão em colaborador existente para obter cobertura de teste.

## Proteção do histórico

Referência dos registros até 11/2026: `c823c340dbce652e26d504d3ce2f054c`.
Referência das versões até 11/2026: `60c33a9bd9a10830ffd89d75117a72cc`.
Método: MD5 de `jsonb_agg(to_jsonb(linha) order by month,employee)::text`. As referências permaneceram iguais após a preparação e criação da competência.

Fixtures de SQL com rollback não persistiram. Ao terminar os runs, a conta administrativa temporária foi removida e suas sessões revogadas; consultas confirmaram zero contas e zero sessões desse identificador. Não incluir senha, hash, cookie ou token de compartilhamento nos relatórios.

## Falha encontrada e corrigida

O teste real `finance_configuration_validation.sql` falhou inicialmente: **Normative wage did not refresh eligible childcare**. `save_normative_wage` gravava a referência, mas omitia `childcareRefresh`, presente no caminho original v77 em `lib/finance-service.ts`. Correção em `supabase/finance-normative-wage.sql`, aplicada ao Supabase: bloqueia os períodos envolvidos, salva referência, chama `refresh_finance_childcare` e audita na mesma transação. A fórmula original de 20% foi preservada.

Após a correção, o mesmo teste passou: AG 400,00 → 600,00 no mês aberto, salário preservado, revisão incrementada, mês aberto anterior e fechado intactos, repetição sem alteração adicional. Configurações de mínimo, alimentação, Unimed, Uniodonto e função também foram gravadas e relidas em rollback; conflito de revisão de saúde recusado. A aplicação da função não recalculou dados existentes automaticamente.

Uma segunda falha foi observada no registro fictício após cadastrar a criança: AG 420,00 estava salvo, mas DF 6.096,49 ainda não incluía esse auxílio. A soma dos componentes existentes era 6.516,49. O teste foi ampliado e falhou com **Childcare did not refresh total cost**. `refresh_finance_childcare` agora atualiza DF na mesma gravação, usando a expressão original de `lib/provisions.ts`: CS + AG + CT + CY + AP + DE em centavos. A edição de cadastro também aplica `applyProvisions` original após modificar a elegibilidade do auxílio. GET continua sem gravação; nenhuma regra de cálculo foi substituída.

Regressão real inclui componentes de custo não zerados: salário normativo muda AG 400,00 → 600,00 e DF 5.670,00 → 5.870,00, com salário, meses anteriores e fechados preservados. Teste de edição compara DF com o motor v77 quando o gênero muda e o auxílio deixa de ser devido.

Terceira falha: salvar calendário DSR alterava T/IR, mas omitia a atualização dos custos/provisões. A fixture tinha T 144,00 com custo ainda do DSR anterior. A regressão falhou com **DSR must update salary cost in the same write**. `lib/supabase-dsr.ts` agora aplica `applyProvisions` original ao montar a gravação de cada comissão, preservando o comportamento de registros excluídos. Testes de prioridades e DSR passaram após a correção. Apenas TEST-FULL-001 em 12/2026 foi reparado com o motor original/RPC de revisão: CS 3.744,00 e DF 6.545,11.

O arquivo `lib/provisions.ts` permanece idêntico ao ZIP original v77 (SHA-256 `66875ada26b0ef70e5557868c258bd8331f7e844a701f0bd6f93d0314c03c171`). As correções integram suas chamadas; não alteram fórmulas.

Advisors de segurança executados após as alterações SQL: sem WARN/ERROR; somente INFO de RLS sem política, conforme a arquitetura de acesso exclusivo pelo servidor. As funções continuam sem EXECUTE público.

## Exemplos adicionais gravados pelo motor/RPC

Essas operações usaram os módulos originais da aplicação e as RPCs reais, com snapshot/revisão; **não foram testes de interface**:

- TEST-FULL-003: prévia e confirmação de salário individual 3.400,00 → 3.500,00, atualizando somente esse cadastro e sua folha de 12/2026.
- Cursos CK: TEST-FULL-003, duas parcelas de 100,00 em 12/2026–01/2027; CK 100,00 confirmado na folha.
- Multa AM: TEST-FULL-001, duas parcelas de 50,00 em 12/2026–01/2027; AM 50,00 confirmado na folha.
- TEST-FULL-004: prévia e confirmação de rescisão em 20/12/2026, salário proporcional 720,00 e cadastro inativo. Nenhum colaborador existente foi desligado.

Os registros de 09/2026–11/2026 e suas versões continuaram com os hashes originais após essas gravações. Os quatro cadastros e as versões de exportação permanecem como exemplos fictícios para revisão; não são contas de acesso temporárias.

## O que ainda não está validado por esta rodada

Não foram testados todos os 137 cenários pela interface. Reajustes/eventos/rescisão têm gravação real por motor/RPC e testes automatizados, mas falta o ciclo completo de formulário para esses exemplos. Edição mensal da tentativa com campo não localizado foi pulada. Upload de anexos, conteúdo dos três arquivos no navegador, matriz HTTP real de permissões, carga concorrente e restauração continuam pendentes. A sugestão automática de DSR deve ser distinguida do valor salvo/herdado em nova conferência visual.

Deploys dos commits `ee5da88` e `31bfac5` confirmados READY na Vercel. A correção adicional de custos ao salvar DSR exige conferir seu próprio deployment. Main continua protegida; não houve merge nem liberação de produção.
