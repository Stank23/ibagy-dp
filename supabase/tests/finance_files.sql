begin;
do $$
declare token text;before_records text;id1 text:='00000000-0000-4000-8000-000000000001';id2 text:='00000000-0000-4000-8000-000000000002';
begin
 assert not exists(select 1 from public.periods where month='2000-02'),'Synthetic month exists';
 insert into public.periods(month,status,commission_status) values('2000-02','open','open');
 select md5(coalesce(jsonb_agg(to_jsonb(r) order by month,employee)::text,'[]')) into before_records from public.records r;
 token:=public.finance_calculation_snapshot('2000-02')->>'token';
 assert not public.save_finance_file('2000-02','payroll',id1,'arquivo-teste.xls','exports/2000-02/'||id1||'.xls','test-files',repeat('a',32)),'Stale token accepted';
 assert public.save_finance_file('2000-02','payroll',id1,'arquivo-teste.xls','exports/2000-02/'||id1||'.xls','test-files',token),'Export metadata rejected';
 assert not public.save_finance_file('2000-02','payroll',id1,'arquivo-teste.xls','exports/2000-02/'||id1||'.xls','test-files',token),'Duplicate metadata';
 update public.periods set status='closed' where month='2000-02';
 assert not public.save_finance_file('2000-02','document',id2,'teste.txt','documents/2000-02/'||id2,'test-files',token),'Changed period accepted';
 token:=public.finance_calculation_snapshot('2000-02')->>'token';
 assert public.save_finance_file('2000-02','document',id2,'teste.txt','documents/2000-02/'||id2,'test-files',token),'Closed history document rejected';
 assert (select count(*)=2 from public.audit where actor='test-files'),'Missing audit';
 assert before_records=(select md5(coalesce(jsonb_agg(to_jsonb(r) order by month,employee)::text,'[]')) from public.records r),'Payroll mutated';
 assert not has_function_privilege('anon','public.save_finance_file(text,text,text,text,text,text,text)','execute');
 assert not has_function_privilege('authenticated','public.save_finance_file(text,text,text,text,text,text,text)','execute');
 begin
  perform public.save_finance_file('2000-02','document','00000000-0000-4000-8000-000000000003','invalid','../bad','test-files',token);
  raise exception 'Invalid path accepted';
 exception when raise_exception then
  if SQLERRM='Invalid path accepted' then raise;end if;
 end;
end $$;
select 'PASS: immutable file metadata/audit, stale token, duplicate, changed period, closed-month attachment, payroll unchanged and RPC restrictions' as result;
rollback;
