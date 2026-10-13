-- Run after payroll-calculation.sql. Synthetic fixtures only; always roll back.
begin;
do $$
begin
 if exists(select 1 from public.versions where month<='2000-02') or exists(select 1 from public.periods where month in ('2000-01','2000-02')) then
  raise exception 'Synthetic test months are not empty; choose an isolated test database';
 end if;
end $$;
insert into public.employees(id,registration,active) values('test-v77-calculation','TEST-V77-CALCULATION',1);
insert into public.versions(employee,month,data) values('test-v77-calculation','2000-01','{"B":"TEST-V77-CALCULATION","C":"Pessoa fictícia","D":"2000-01-01","K":"1000.00"}');
insert into public.periods(month,status,commission_status) values('2000-01','closed','closed');
insert into public.records(month,employee,data,revision) values('2000-01','test-v77-calculation','{"history":"preserve"}',9);
set local role service_role;
do $$
declare token text; rows jsonb; changed boolean; audit_count integer;
begin
 assert not has_function_privilege('anon','public.finance_calculation_snapshot(text)','EXECUTE');
 assert not has_function_privilege('authenticated','public.save_calculated_finance_period(text,text,text,text,jsonb)','EXECUTE');
 token:=public.finance_calculation_snapshot('2000-02')->>'token';
 rows:='[{"employee":"test-v77-calculation","revision":0,"data":"{\"K\":\"1000.00\"}"}]'::jsonb;
 assert public.save_calculated_finance_period('2000-02','period','synthetic-test',token,rows);
 assert (select count(*)=1 from public.records where month='2000-02');
 assert (select count(*)=1 from public.audit where month='2000-02');
 assert not public.save_calculated_finance_period('2000-02','period','synthetic-test',token,rows),'Duplicate/stale creation must reject';
 token:=public.finance_calculation_snapshot('2000-02')->>'token';
 rows:='[{"employee":"test-v77-calculation","revision":1,"data":"{\"K\":\"1100.00\"}"}]'::jsonb;
 assert public.save_calculated_finance_period('2000-02','recalculate','synthetic-test',token,rows);
 assert (select revision=2 from public.records where month='2000-02' and employee='test-v77-calculation');
 assert not public.save_calculated_finance_period('2000-02','recalculate','synthetic-test',token,rows),'Concurrent stale revision must reject';
 token:=public.finance_calculation_snapshot('2000-02')->>'token';
 assert not public.save_calculated_finance_period('2000-02','recalculate','synthetic-test',token,rows),'Wrong revision must reject even with fresh token';
 assert not public.save_calculated_finance_period('2000-02','recalculate','synthetic-test',token,'[]'::jsonb),'Missing employee must reject';
 assert not public.save_calculated_finance_period('2000-02','recalculate','synthetic-test',token,rows||rows),'Duplicate employee must reject';
 update public.versions set data='{"B":"TEST-V77-CALCULATION","C":"Pessoa fictícia","D":"2000-01-01","K":"1200.00"}' where employee='test-v77-calculation';
 assert not public.save_calculated_finance_period('2000-02','recalculate','synthetic-test',token,rows),'Changed source data must reject';
 token:=public.finance_calculation_snapshot('2000-02')->>'token';
 select count(*) into audit_count from public.audit where month='2000-02';
 begin
  perform public.save_calculated_finance_period('2000-02','recalculate','synthetic-test',token,'[{"employee":"test-v77-calculation","revision":2,"data":"not-json"}]'::jsonb);
  raise exception 'Invalid JSON was accepted';
 exception when invalid_text_representation then null;
 end;
 assert (select count(*)=audit_count from public.audit where month='2000-02'),'Rejected write must not create audit';
 assert (select revision=2 from public.records where month='2000-02' and employee='test-v77-calculation'),'Rejected write must not change records';
 token:=public.finance_calculation_snapshot('2000-02')->>'token';
 assert public.save_calculated_finance_period('2000-02','record','synthetic-test',token,'[{"employee":"test-v77-calculation","revision":2,"data":"{\"K\":\"1250.00\"}"}]'::jsonb);
 assert (select revision=3 and data::jsonb->>'K'='1250.00' from public.records where month='2000-02' and employee='test-v77-calculation');
 assert (select count(*)=1 from public.audit where month='2000-02' and action='Lançamento atualizado' and detail::jsonb->>'employee'='test-v77-calculation');
 assert not public.save_calculated_finance_period('2000-02','record','synthetic-test',token,'[{"employee":"test-v77-calculation","revision":2,"data":"{}"}]'::jsonb),'Stale edit must reject';
 update public.records set data='{"_excluded":true}' where month='2000-02' and employee='test-v77-calculation';
 token:=public.finance_calculation_snapshot('2000-02')->>'token';
 assert not public.save_calculated_finance_period('2000-02','record','synthetic-test',token,'[{"employee":"test-v77-calculation","revision":3,"data":"{}"}]'::jsonb),'Excluded record edit must reject';
 update public.periods set status='closed' where month='2000-02';
 token:=public.finance_calculation_snapshot('2000-02')->>'token';
 assert not public.save_calculated_finance_period('2000-02','recalculate','synthetic-test',token,'[{"employee":"test-v77-calculation","revision":2,"data":"{}"}]'::jsonb),'Closed period must reject';
 assert (select revision=9 and data='{"history":"preserve"}' from public.records where month='2000-01' and employee='test-v77-calculation'),'History must be unchanged';
end $$;
reset role;
select 'PASS: transactional create/recalculate/edit, audit, service_role access, stale token/revision, changed sources, complete employee set, duplicates, excluded record, invalid JSON rollback, closed period and history' as result;
rollback;
