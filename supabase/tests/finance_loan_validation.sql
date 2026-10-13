-- Fictional SEREFI registration, monthly persistence and closed-period protection.
begin;
do $$
declare parts jsonb := '[{"month":"2000-02","number":1,"principal":50000,"fee":280,"amount":50280},{"month":"2000-03","number":2,"principal":50000,"fee":0,"amount":50000}]';
begin
 assert not exists(select 1 from periods where month in ('2000-01','2000-02','2000-03'));
 insert into employees(id,registration,active) values ('synthetic-full-loan','TEST-FULL-LOAN',1);
 insert into periods(month,status,commission_status) values ('2000-01','closed','closed'),('2000-02','open','open'),('2000-03','open','open');
 insert into records(month,employee,data,revision) values ('2000-01','synthetic-full-loan','{"AI":"10.00"}',77),('2000-02','synthetic-full-loan','{"AI":"10.00"}',1),('2000-03','synthetic-full-loan','{"AI":"0.00"}',1);
 assert public.register_finance_loan('synthetic-full-loan-1','synthetic-full-loan','2000-02','2000-03',100000,parts,'synthetic-full-validation');
 assert (select count(*)=2 and sum(principal)=100000 and sum(fee)=280 and sum(amount)=100280 from installments where loan='synthetic-full-loan-1');
 assert (select data::jsonb->>'AI'='512.80' and data::jsonb->>'_serefiAuto'='50280' and revision=2 from records where employee='synthetic-full-loan' and month='2000-02');
 assert (select data::jsonb->>'AI'='500.00' and revision=2 from records where employee='synthetic-full-loan' and month='2000-03');
 assert (select data='{"AI":"10.00"}' and revision=77 from records where employee='synthetic-full-loan' and month='2000-01');
 update periods set status='closed' where month='2000-03';
 assert not public.register_finance_loan('synthetic-full-loan-blocked','synthetic-full-loan','2000-02','2000-03',100000,parts,'synthetic-full-validation');
 assert not exists(select 1 from loans where id='synthetic-full-loan-blocked');
 assert (select count(*)=1 from audit where actor='synthetic-full-validation' and month='2000-02');
 assert not has_function_privilege('anon','public.register_finance_loan(text,text,text,text,integer,jsonb,text)','execute');
end $$;
select 'PASS: fictional SEREFI installments, original fee, monthly persistence/revisions, historical preservation, closed future month and audit' as result;
rollback;
