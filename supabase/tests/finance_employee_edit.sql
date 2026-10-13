begin;
do $$
declare token text;v_data jsonb;updates jsonb;
begin
 assert not exists(select 1 from public.periods where month in('2000-01','2000-02','2000-03','2000-04')),'Synthetic periods exist';
 insert into public.periods(month,status,commission_status) values('2000-01','closed','closed'),('2000-02','open','open'),('2000-03','open','open'),('2000-04','closed','closed');
 insert into public.employees(id,registration,active) values('test-employee-edit','TEST-EDIT',1);
 insert into public.versions(employee,month,data) values('test-employee-edit','1999-01','{"B":"TEST-EDIT","C":"Pessoa fictícia","D":"1999-01-01","E":"000.000.001-91","H":"Loja fictícia","receivesVA":false}');
 insert into public.records(month,employee,data,revision) values('2000-01','test-employee-edit','{"historic":true}',77),('2000-02','test-employee-edit','{"K":"100.00"}',1),('2000-03','test-employee-edit','{"K":"100.00"}',1),('2000-04','test-employee-edit','{"historic":true}',77);
 token:=public.finance_employee_edit_snapshot('2000-02','test-employee-edit')->>'token';
 v_data:='{"B":"TEST-EDIT","C":"Pessoa fictícia editada","D":"1999-01-01","E":"000.000.001-91","H":"Loja fictícia","receivesVA":false,"K":"200.00"}';
 updates:=jsonb_build_array(jsonb_build_object('month','2000-02','employee','test-employee-edit','revision',1,'data','{"K":"100.00","gender":"Masculino"}'),jsonb_build_object('month','2000-03','employee','test-employee-edit','revision',1,'data','{"K":"100.00","gender":"Masculino"}'));
 assert not public.save_finance_employee_edit('2000-02','test-employee-edit','test-edit',repeat('a',32),v_data,0,updates),'Stale snapshot accepted';
 assert not public.save_finance_employee_edit('2000-02','test-employee-edit','test-edit',token,jsonb_set(v_data,'{B}','"OTHER"'),0,updates),'Registration changed';
 assert public.save_finance_employee_edit('2000-02','test-employee-edit','test-edit',token,v_data,0,updates),'Edit rejected';
 assert (select active=0 from public.employees where id='test-employee-edit');
 assert (select data::jsonb->>'K'='200.00' from public.versions where employee='test-employee-edit' and month='2000-02');
 assert (select count(*)=2 and bool_and(revision=2 and data::jsonb->>'K'='100.00') from public.records where employee='test-employee-edit' and month in('2000-02','2000-03')),'Open salary snapshot changed';
 assert (select count(*)=2 and bool_and(revision=77 and data='{"historic":true}') from public.records where employee='test-employee-edit' and month in('2000-01','2000-04')),'Closed or previous history changed';
 assert (select data::jsonb->>'C'='Pessoa fictícia' from public.versions where employee='test-employee-edit' and month='1999-01'),'Prior version changed';
 assert not public.save_finance_employee_edit('2000-02','test-employee-edit','test-edit',token,v_data,0,updates),'Duplicate stale edit accepted';
 assert not has_function_privilege('anon','public.save_finance_employee_edit(text,text,text,text,jsonb,integer,jsonb)','execute');
 assert not has_function_privilege('authenticated','public.finance_employee_edit_snapshot(text,text)','execute');
end $$;
select 'PASS: employee version/active/open records atomic, registration guard, stale/duplicate edits, unchanged prior and closed monthly history, prior version and restricted RPCs' as result;
rollback;
