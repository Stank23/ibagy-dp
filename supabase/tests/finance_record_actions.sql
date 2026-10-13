begin;
do $$
declare token text;updates jsonb;
begin
 assert not exists(select 1 from public.periods where month in('2000-01','2000-02')),'Synthetic periods exist';
 insert into public.periods(month,status,commission_status) values('2000-01','closed','closed'),('2000-02','open','open');
 insert into public.employees(id,registration,active) values('test-action-a','TEST-ACTION-A',1),('test-action-b','TEST-ACTION-B',1);
 insert into public.records(month,employee,data,revision) values('2000-01','test-action-a','{"historical":"unchanged"}',77),('2000-02','test-action-a','{"C":"Pessoa fictícia","U":"0.00"}',1),('2000-02','test-action-b','{"C":"Pessoa fictícia","U":"0.00"}',1);
 token:=public.finance_record_action_snapshot('2000-02')->>'token';
 updates:=jsonb_build_array(jsonb_build_object('employee','test-action-a','revision',1,'data','{"C":"Pessoa fictícia","U":"100.00"}'),jsonb_build_object('employee','test-action-b','revision',99,'data','{"C":"Pessoa fictícia","U":"100.00"}'));
 assert not public.save_finance_record_action('2000-02','health_copart_bulk','test-actions',token,updates),'Stale bulk accepted';
 assert (select bool_and(revision=1) from public.records where month='2000-02'),'Partial update committed';
 insert into public.dsr_settings(month,useful,rest,revision,write_id) values('2000-02',25,4,1,'test-dsr');
 updates:=jsonb_set(updates,'{1,revision}','1');
 assert not public.save_finance_record_action('2000-02','health_copart_bulk','test-actions',token,updates),'Calendar change ignored';
 token:=public.finance_record_action_snapshot('2000-02')->>'token';
 assert public.save_finance_record_action('2000-02','health_copart_bulk','test-actions',token,updates),'Bulk update rejected';
 assert (select bool_and(revision=2 and data::jsonb->>'U'='100.00') from public.records where month='2000-02'),'Updates incomplete';
 assert (select revision=77 and data='{"historical":"unchanged"}' from public.records where month='2000-01' and employee='test-action-a'),'History changed';
 update public.periods set commission_status='closed' where month='2000-02';
 token:=public.finance_record_action_snapshot('2000-02')->>'token';
 assert not public.save_finance_record_action('2000-02','commission_value','test-actions',token,jsonb_build_array(jsonb_build_object('employee','test-action-a','revision',2,'data','{}'))),'Closed commission accepted';
 assert (select count(*)=3 from public.audit where actor='test-actions'),'Missing audits';
 assert not has_function_privilege('anon','public.save_finance_record_action(text,text,text,text,jsonb)','execute');
 assert not has_function_privilege('authenticated','public.finance_record_action_snapshot(text)','execute');
end $$;
select 'PASS: atomic bulk, stale revision and DSR, locked commission, revisions, audit, previous-month history and restricted RPCs' as result;
rollback;
