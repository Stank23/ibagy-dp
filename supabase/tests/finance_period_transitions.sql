-- Executar em transação, sem persistir dados fictícios.
begin;
insert into public.periods(month,status,commission_status) values ('2099-10','open','open');
do $$
declare
 n integer;
begin
 if not public.transition_finance_period('2099-10','commission_close','integration-test','') then raise exception 'Falha ao fechar comissão'; end if;
 if not public.transition_finance_period('2099-10','commission_reopen','integration-test','motivo de teste') then raise exception 'Falha ao reabrir comissão'; end if;
 if not public.transition_finance_period('2099-10','close','integration-test','') then raise exception 'Falha ao fechar competência'; end if;
 if not public.transition_finance_period('2099-10','reopen','integration-test','motivo de teste') then raise exception 'Falha ao reabrir competência'; end if;
 if public.transition_finance_period('2099-10','reopen','integration-test','motivo de teste') then raise exception 'Reabertura duplicada permitida'; end if;
 select count(*) into n from public.audit where month='2099-10';
 if n<>4 then raise exception 'Auditoria incompleta: %',n; end if;
end $$;
rollback;
