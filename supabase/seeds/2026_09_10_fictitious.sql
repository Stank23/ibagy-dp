-- Fictitious test data. Payroll records are not calculated by v77 engine.
begin;
create temporary table fixture_people on commit drop as
with src as (
 select n,
 (array['Ana Teste','Bruno Exemplo','Carla Simulação','Diego Demonstração','Elisa Fictícia','Felipe Cenário','Gabriela Modelo','Hugo Amostra','Isabela Teste','João Exemplo','Karina Simulação','Luciana Demonstração','Marina Fictícia','Nicolas Cenário','Olívia Modelo','Paulo Amostra','Renata Teste','Sérgio Exemplo','Tatiana Simulação','Vitor Demonstração'])[n] as full_name,
 (array['Normal','Normal','Normal','Normal','Normal','Normal','Normal','Normal','Aprendiz','Diretoria','Estagiário','Licença maternidade','Perícia','Rescisão','Normal','Normal','Normal','Normal','Normal','Normal'])[n] as situation,
 (array['Matriz','Biguaçu','Campeche','Centro','Ingleses','Kobrasol','Palhoça','Trindade'])[1+(n-1)%8] as store,
 (array['Financeiro','Comercial','Administrativo','RH','Jurídico','Locação','Vistoria Ocupação','Recepção','Arquivo','Diretora','CPD','Relacionamento','Qualidade','Manutenção','Comercial Captador','Desocupação','Seguro','Agente de Visitas','Administrativo IPTU','Limpeza'])[n] as department,
 (array[300000,450000,280000,320000,420000,350000,310000,250000,170000,850000,180000,370000,330000,290000,270000,260000,390000,340000,300000,220000])[n] as salary,
 case when n=1 then '2021-10-15' when n=2 then '2016-08-10' when n=15 then '2026-09-16' when n=16 then '2026-10-10' else '2023-01-12' end as admission
 from generate_series(1,20) as n
)
select 'fixture-ibagy-2026-'||lpad(n::text,3,'0') as id,
 'T'||lpad(n::text,4,'0') as registration,
 case when n=14 then 0 else 1 end as active,
 left(admission,7) as effective,
 jsonb_build_object('B','T'||lpad(n::text,4,'0'),'C','[TESTE] '||full_name,'D',admission,
 'E',lpad((900000000+n*1723)::text,9,'0'),'F','','G',situation,'H',store,'I','','J',department,
 'K',to_char(salary/100.0,'FM9999990.00'),'gender',case when n%2=0 then 'Masculino' else 'Feminino' end,
 'receivesVA',n<>10,'chargeSerefi',n<>11,'supportGroup',n=3,
 'commissionType',case when n in(2,6,10,14,18) then 'Comissão Resultado' else '' end,
 'healthMembers',
 (case when n in(1,2,4,6,7,8) then jsonb_build_array(jsonb_build_object('id','fixture-um-'||n,'plan','unimed','role','titular','name','[TESTE] '||full_name,'birthDate','1990-05-10','monthly','500.00')) else '[]'::jsonb end) ||
 (case when n in(1,4) then jsonb_build_array(jsonb_build_object('id','fixture-um-dep-'||n,'plan','unimed','role','dependente','name','[TESTE] Dependente','birthDate',case when n=1 then '2026-09-20' else '2018-06-10' end,'monthly','350.00')) else '[]'::jsonb end) ||
 (case when n in(1,3,5,6,8) then jsonb_build_array(jsonb_build_object('id','fixture-ud-'||n,'plan','uniodonto','role','titular','name','[TESTE] '||full_name,'birthDate','1990-05-10','monthly','45.00')) else '[]'::jsonb end) ||
 (case when n in(1,5) then jsonb_build_array(jsonb_build_object('id','fixture-ud-dep-'||n,'plan','uniodonto','role','dependente','name','[TESTE] Dependente Odonto','birthDate','2024-01-12','monthly','45.00')) else '[]'::jsonb end),
 'extraPericulosidade',case when n=4 then '900.00' else '0.00' end,
 'extraInsalubridade',case when n=5 then '250.00' else '0.00' end,
 'extraTeletrabalho',case when n=7 then '150.00' else '0.00' end,
 'extraCaixa',case when n=8 then '180.00' else '0.00' end,
 '_fixture',true
 ) as payload
from src;
insert into public.employees(id,registration,active) select id,registration,active from fixture_people on conflict(id) do nothing;
insert into public.versions(employee,month,data) select id,effective,payload::text from fixture_people on conflict(employee,month) do nothing;
insert into public.periods(month,status,commission_status) values('2026-09','open','open'),('2026-10','open','open') on conflict(month) do nothing;
insert into public.allowances(month,amount) values('2026-09',90000),('2026-10',90000) on conflict(month) do nothing;
insert into public.minimum_wages(month,amount) values('2026-09',162100) on conflict(month) do nothing;
insert into public.normative_wages(month,amount) values('2026-09',210000) on conflict(month) do nothing;
insert into public.unimed_rates(month,young,middle,senior) values('2026-09',42000,57000,80000) on conflict(month) do nothing;
insert into public.uniodonto_fixed_rates(month,amount) values('2026-09',4500) on conflict(month) do nothing;
insert into public.dsr_settings(write_id,month,useful,rest) values('fixture-dsr-2026-09','2026-09',25,5),('fixture-dsr-2026-10','2026-10',26,5) on conflict do nothing;
insert into public.job_functions(name,key) values('[TESTE] Analista','teste-analista'),('[TESTE] Assistente','teste-assistente'),('[TESTE] Consultor','teste-consultor') on conflict(key) do nothing;
insert into public.loans(id,employee,amount,count,start,"end",created) values
('fixture-loan-001','fixture-ibagy-2026-002',120000,4,'2026-09','2026-12',now()::text),
('fixture-loan-002','fixture-ibagy-2026-006',90000,3,'2026-10','2026-12',now()::text) on conflict(id) do nothing;
insert into public.installments(loan,employee,month,number,principal,fee,amount) values
('fixture-loan-001','fixture-ibagy-2026-002','2026-09',1,30000,280,30280),
('fixture-loan-001','fixture-ibagy-2026-002','2026-10',2,30000,0,30000),
('fixture-loan-001','fixture-ibagy-2026-002','2026-11',3,30000,0,30000),
('fixture-loan-001','fixture-ibagy-2026-002','2026-12',4,30000,0,30000),
('fixture-loan-002','fixture-ibagy-2026-006','2026-10',1,30000,280,30280),
('fixture-loan-002','fixture-ibagy-2026-006','2026-11',2,30000,0,30000),
('fixture-loan-002','fixture-ibagy-2026-006','2026-12',3,30000,0,30000) on conflict do nothing;
insert into public.event_plans(id,employee,event,amount,count,start,"end",created) values('fixture-event-001','fixture-ibagy-2026-003','1483',60000,3,'2026-09','2026-11',now()::text) on conflict(id) do nothing;
insert into public.childcare_children(id,employee,child_name,birth_date,start,last_credit,created) values('fixture-child-001','fixture-ibagy-2026-012','[TESTE] Criança Fictícia','2025-05-02','2026-09','',now()::text) on conflict(id) do nothing;
insert into public.records(month,employee,data)
 select m.month,p.id,(p.payload || jsonb_build_object(
 '_fixture',true,'_fixtureUncalculated',true,'_active',p.active=1,
 'AG','0.00','AH','0.00','AI','0.00','AL','0.00','AN',case when p.active=1 then '1.00' else '0.00' end,
 'U',case when right(p.registration,1) in('2','6','8') then '1200.00' else '0.00' end,
 'T','0.00','commissionNet','0.00','paid20',false,'paymentStatus','pending'))::text
 from fixture_people p cross join(values('2026-09'),('2026-10')) m(month)
 where p.effective<=m.month on conflict(month,employee) do nothing;
commit;