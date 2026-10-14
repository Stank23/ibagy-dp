-- External payment only. Retain the original contract and schedule permanently.
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS settled_month text;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS settled_on text;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS settled_amount bigint;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS settlement_schedule jsonb;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS settlement_reference text;
ALTER TABLE public.installments ADD COLUMN IF NOT EXISTS settled_early boolean NOT NULL DEFAULT false;

CREATE OR REPLACE FUNCTION public.finance_loan_settlement_snapshot(p_loan text,p_month text)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY INVOKER SET search_path='' AS $$
DECLARE s jsonb;
BEGIN
 IF p_loan IS NULL OR length(p_loan) NOT BETWEEN 1 AND 120 OR p_month IS NULL OR p_month !~ '^20[0-9]{2}-(0[1-9]|1[0-2])$' THEN RAISE EXCEPTION 'Invalid settlement context'; END IF;
 SELECT jsonb_build_object(
  'loan',(SELECT to_jsonb(l) FROM public.loans l WHERE id=p_loan),
  'installments',coalesce((SELECT jsonb_agg(to_jsonb(i) ORDER BY month,number) FROM public.installments i WHERE loan=p_loan),'[]'::jsonb),
  'calculations',(SELECT jsonb_agg(jsonb_build_object('month',m.month,'snapshot',public.finance_calculation_snapshot(m.month)->'snapshot') ORDER BY m.month) FROM (SELECT p_month AS month UNION SELECT month FROM public.installments WHERE loan=p_loan AND month>=p_month) m)
 ) INTO s;
 RETURN jsonb_build_object('snapshot',s,'token',md5(s::text));
END $$;

CREATE OR REPLACE FUNCTION public.settle_finance_loan(p_loan text,p_month text,p_date text,p_reference text,p_actor text,p_token text,p_records jsonb)
RETURNS boolean LANGUAGE plpgsql SECURITY INVOKER SET search_path='' AS $$
DECLARE s jsonb;l public.loans%rowtype;total bigint;expected jsonb;provided jsonb;item jsonb;calc jsonb;
BEGIN
 IF p_date IS NULL OR p_date !~ '^20[0-9]{2}-(0[1-9]|1[0-2])-[0-3][0-9]$' OR left(p_date,7) IS DISTINCT FROM p_month OR to_char(p_date::date,'YYYY-MM-DD')<>p_date OR p_reference IS NULL OR length(p_reference)>200 OR p_actor IS NULL OR length(p_actor) NOT BETWEEN 1 AND 200 OR p_token IS NULL OR p_token !~ '^[a-f0-9]{32}$' OR p_records IS NULL OR jsonb_typeof(p_records)<>'array' THEN RAISE EXCEPTION 'Invalid settlement request'; END IF;
 LOCK TABLE public.allowances,public.childcare_children,public.employees,public.event_plans,public.installments,public.loans,public.minimum_wages,public.normative_wages,public.periods,public.records,public.unimed_rates,public.uniodonto_fixed_rates,public.versions IN SHARE ROW EXCLUSIVE MODE;
 s:=public.finance_loan_settlement_snapshot(p_loan,p_month);
 IF s->>'token' IS DISTINCT FROM p_token THEN RETURN false; END IF;
 SELECT * INTO l FROM public.loans WHERE id=p_loan;
 IF NOT FOUND OR l.settled_month IS NOT NULL OR NOT EXISTS(SELECT 1 FROM public.periods WHERE month=p_month AND status='open') THEN RETURN false; END IF;
 SELECT coalesce(sum(amount),0) INTO total FROM public.installments WHERE loan=p_loan AND month>=p_month;
 IF total<=0 OR EXISTS(SELECT 1 FROM public.installments i JOIN public.periods p ON p.month=i.month WHERE i.loan=p_loan AND i.month>=p_month AND i.amount>0 AND p.status='closed') THEN RETURN false; END IF;
 IF EXISTS(SELECT 1 FROM public.records WHERE employee=l.employee AND month IN (SELECT c->>'month' FROM jsonb_array_elements(s->'snapshot'->'calculations') c) AND coalesce(data::jsonb->>'_termination','false')='true') THEN RETURN false; END IF;
 SELECT coalesce(jsonb_agg(jsonb_build_array(r.month,r.employee) ORDER BY r.month,r.employee),'[]'::jsonb) INTO expected FROM public.records r JOIN public.periods p ON p.month=r.month WHERE r.employee=l.employee AND r.month IN (SELECT c->>'month' FROM jsonb_array_elements(s->'snapshot'->'calculations') c) AND p.status='open' AND coalesce(r.data::jsonb->>'_excluded','false')<>'true';
 SELECT coalesce(jsonb_agg(jsonb_build_array(r->>'month',r->>'employee') ORDER BY r->>'month',r->>'employee'),'[]'::jsonb) INTO provided FROM jsonb_array_elements(p_records) r;
 IF expected IS DISTINCT FROM provided THEN RETURN false; END IF;
 FOR item IN SELECT value FROM jsonb_array_elements(p_records) LOOP
  IF jsonb_typeof(item->'data') IS DISTINCT FROM 'string' OR jsonb_typeof((item->>'data')::jsonb) IS DISTINCT FROM 'object' OR coalesce(item->>'revision','') !~ '^[1-9][0-9]*$' THEN RAISE EXCEPTION 'Invalid calculated record'; END IF;
  IF NOT EXISTS(SELECT 1 FROM public.records WHERE month=item->>'month' AND employee=l.employee AND revision=(item->>'revision')::integer) THEN RETURN false; END IF;
  calc:=(item->>'data')::jsonb;
  IF round(coalesce(nullif(calc->>'AI',''),'0')::numeric*100)<>(SELECT coalesce(sum(amount),0) FROM public.installments WHERE employee=l.employee AND month=item->>'month' AND loan<>p_loan) THEN RAISE EXCEPTION 'Invalid remaining payroll balance'; END IF;
 END LOOP;
 UPDATE public.loans SET settled_month=p_month,settled_on=p_date,settled_amount=total,settlement_reference=trim(p_reference),settlement_schedule=s->'snapshot'->'installments' WHERE id=p_loan;
 UPDATE public.installments SET amount=0,settled_early=true WHERE loan=p_loan AND month>=p_month;
 UPDATE public.records r SET data=i.value->>'data',revision=r.revision+1 FROM jsonb_array_elements(p_records) i WHERE r.month=i.value->>'month' AND r.employee=i.value->>'employee';
 INSERT INTO public.audit(id,month,action,actor,created,detail) VALUES(gen_random_uuid()::text,p_month,'Quitação antecipada SEREFI',p_actor,now()::text,jsonb_build_object('loan',p_loan,'employee',l.employee,'amount',total,'paymentDate',p_date,'reference',trim(p_reference),'paymentMode','outside_payroll','engine','v77')::text);
 RETURN true;
END $$;
REVOKE ALL ON FUNCTION public.finance_loan_settlement_snapshot(text,text) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION public.settle_finance_loan(text,text,text,text,text,text,jsonb) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.finance_loan_settlement_snapshot(text,text) TO service_role;
GRANT EXECUTE ON FUNCTION public.settle_finance_loan(text,text,text,text,text,text,jsonb) TO service_role;
NOTIFY pgrst,'reload schema';
