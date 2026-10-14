-- Only synthetic fixtures. No persistent test data.
BEGIN;
DO $$
DECLARE s jsonb;token text;updates jsonb;before_history text;
BEGIN
 ASSERT NOT EXISTS(SELECT 1 FROM public.periods WHERE month IN ('2000-01','2000-02','2000-03'));
 INSERT INTO public.employees(id,registration,active) VALUES('synthetic-settlement-employee','TEST-SETTLEMENT',1);
 INSERT INTO public.periods(month,status,commission_status) VALUES('2000-01','closed','closed'),('2000-02','open','closed'),('2000-03','open','open');
 INSERT INTO public.records(month,employee,data,revision) VALUES('2000-01','synthetic-settlement-employee','{"AI":"500.00"}',7),('2000-02','synthetic-settlement-employee','{"AI":"502.80","U":"100.00"}',2),('2000-03','synthetic-settlement-employee','{"AI":"500.00"}',2);
 INSERT INTO public.loans(id,employee,amount,count,start,"end",created) VALUES('synthetic-settlement-loan','synthetic-settlement-employee',150000,3,'2000-01','2000-03',now()::text);
 INSERT INTO public.installments(loan,employee,month,number,principal,fee,amount) VALUES('synthetic-settlement-loan','synthetic-settlement-employee','2000-01',1,50000,280,50280),('synthetic-settlement-loan','synthetic-settlement-employee','2000-02',2,50000,0,50000),('synthetic-settlement-loan','synthetic-settlement-employee','2000-03',3,50000,0,50000);
 SELECT md5(data||revision::text) INTO before_history FROM public.records WHERE month='2000-01' AND employee='synthetic-settlement-employee';
 updates:='[{"month":"2000-02","employee":"synthetic-settlement-employee","revision":2,"data":"{\"AI\":\"0.00\",\"U\":\"100.00\"}"},{"month":"2000-03","employee":"synthetic-settlement-employee","revision":2,"data":"{\"AI\":\"0.00\"}"}]';
 s:=public.finance_loan_settlement_snapshot('synthetic-settlement-loan','2000-02');token:=s->>'token';
 ASSERT NOT public.settle_finance_loan('synthetic-settlement-loan','2000-02','2000-02-15','TEST','synthetic-settlement',repeat('0',32),updates);
 ASSERT NOT public.settle_finance_loan('synthetic-settlement-loan','2000-02','2000-02-15','TEST','synthetic-settlement',token,'[]');
 UPDATE public.periods SET status='closed' WHERE month='2000-03';token:=public.finance_loan_settlement_snapshot('synthetic-settlement-loan','2000-02')->>'token';
 ASSERT NOT public.settle_finance_loan('synthetic-settlement-loan','2000-02','2000-02-15','TEST','synthetic-settlement',token,updates);
 ASSERT (SELECT settled_month IS NULL FROM public.loans WHERE id='synthetic-settlement-loan');
 UPDATE public.periods SET status='open' WHERE month='2000-03';token:=public.finance_loan_settlement_snapshot('synthetic-settlement-loan','2000-02')->>'token';
 ASSERT public.settle_finance_loan('synthetic-settlement-loan','2000-02','2000-02-15','TEST','synthetic-settlement',token,updates);
 ASSERT (SELECT settled_month='2000-02' AND settled_on='2000-02-15' AND settled_amount=100000 AND jsonb_array_length(settlement_schedule)=3 AND settlement_schedule->1->>'amount'='50000' FROM public.loans WHERE id='synthetic-settlement-loan');
 ASSERT (SELECT sum(amount)=50280 AND count(*)=3 FROM public.installments WHERE loan='synthetic-settlement-loan');
 ASSERT (SELECT count(*)=2 FROM public.installments WHERE loan='synthetic-settlement-loan' AND settled_early AND amount=0);
 ASSERT (SELECT md5(data||revision::text)=before_history FROM public.records WHERE month='2000-01' AND employee='synthetic-settlement-employee');
 ASSERT (SELECT data::jsonb->>'AI'='0.00' AND data::jsonb->>'U'='100.00' AND revision=3 FROM public.records WHERE month='2000-02' AND employee='synthetic-settlement-employee');
 token:=public.finance_loan_settlement_snapshot('synthetic-settlement-loan','2000-02')->>'token';
 ASSERT NOT public.settle_finance_loan('synthetic-settlement-loan','2000-02','2000-02-15','TEST','synthetic-settlement',token,updates);
 ASSERT (SELECT count(*)=1 FROM public.audit WHERE actor='synthetic-settlement' AND action='Quitação antecipada SEREFI');
 ASSERT NOT has_function_privilege('anon','public.settle_finance_loan(text,text,text,text,text,text,jsonb)','EXECUTE');
 ASSERT NOT has_function_privilege('authenticated','public.finance_loan_settlement_snapshot(text,text)','EXECUTE');
END $$;
SELECT 'PASS: external settlement, historical schedule, old closed records, future closed month, stale/incomplete/replayed saves, audit and private RPCs' AS result;
ROLLBACK;
