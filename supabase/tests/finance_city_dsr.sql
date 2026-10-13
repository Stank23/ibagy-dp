begin;
do $$
declare token text;items jsonb;result boolean;old_hash text;
begin
 assert not exists(select 1 from public.periods where month='2000-02');
 select md5(coalesce(jsonb_agg(to_jsonb(r) order by month,employee)::text,'')) into old_hash from public.records r;
 insert into public.periods(month,status,commission_status) values('2000-02','open','open');
 insert into public.employees(id,registration,active) values('test-city-big','TEST-CITY-BIG',1),('test-city-sj','TEST-CITY-SJ',1);
 insert into public.versions(employee,month,data) values('test-city-big','2000-02','{"H":"Biguaçu"}'),('test-city-sj','2000-02','{"H":"Kobrasol"}');
 insert into public.records(month,employee,data,revision) values('2000-02','test-city-big','{"H":"Biguaçu","U":"100.00","P":"Comissão","commissionNet":"90.00","T":"20.00"}',1),('2000-02','test-city-sj','{"H":"Kobrasol","U":"100.00","P":"Comissão","T":"20.00"}',1);
 assert public.finance_dsr_city('Agência Biguaçu')='biguacu';assert public.finance_dsr_city('Kobrasol')='sao-jose';assert public.finance_dsr_city('Palhoça')='palhoca';assert public.finance_dsr_city('Matriz')='florianopolis';
 token:=public.finance_record_action_snapshot('2000-02')->>'token';
 items:='[{"employee":"test-city-big","revision":1,"data":"{\"H\":\"Biguaçu\",\"U\":\"100.00\",\"P\":\"Comissão\",\"T\":\"20.83\",\"commissionUseful\":24,\"commissionRest\":5,\"commissionNet\":\"90.00\",\"commissionIR\":\"30.83\"}"}]';
 assert not public.save_finance_city_dsr('2000-02','biguacu','test-city',repeat('0',32),24,5,0,items);
 assert public.save_finance_city_dsr('2000-02','biguacu','test-city',token,24,5,0,items);
 assert (select data::jsonb->>'T'='20.83' and revision=2 from public.records where employee='test-city-big' and month='2000-02');
 assert (select revision=1 and data::jsonb->>'T'='20.00' from public.records where employee='test-city-sj' and month='2000-02');
 assert not public.save_finance_city_dsr('2000-02','biguacu','test-city',token,24,5,0,items);
 assert not exists(select 1 from public.dsr_city_settings where month='2000-02' and city='sao-jose');
 assert not exists(select 1 from public.dsr_settings where month='2000-02');
 update public.periods set commission_status='closed' where month='2000-02';token:=public.finance_record_action_snapshot('2000-02')->>'token';
 assert not public.save_finance_city_dsr('2000-02','biguacu','test-city',token,24,5,1,jsonb_set(items,'{0,revision}','2'));
 assert not has_function_privilege('anon','public.save_finance_city_dsr(text,text,text,text,integer,integer,integer,jsonb)','execute');
 assert not has_function_privilege('authenticated','public.save_finance_city_dsr(text,text,text,text,integer,integer,integer,jsonb)','execute');
 assert (select relrowsecurity from pg_class where oid='public.dsr_city_settings'::regclass);
 assert (select md5(coalesce(jsonb_agg(to_jsonb(r) order by month,employee)::text,'')) from public.records r where employee not like 'test-city-%')=old_hash;
end $$;
select 'PASS: city calendar atomic CAS/revision, correct agency isolation, legacy preserved, closed commission, RLS, service-only access and original records unchanged' as result;
rollback;
