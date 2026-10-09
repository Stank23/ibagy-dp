create or replace function public.save_finance_health_base(p_month text,p_employee text,p_actor text,p_token text,p_data text,p_records jsonb)
returns boolean language plpgsql security invoker set search_path='' as $$
declare expected_count integer;item jsonb;
begin
 if p_employee is null or length(p_employee) not between 1 and 120 or p_actor is null or length(p_actor) not between 1 and 200 or p_token is null or p_token !~ '^[a-f0-9]{32}$' or p_data is null or jsonb_typeof(p_data::jsonb)<>'object' or p_records is null or jsonb_typeof(p_records)<>'array' then raise exception 'Invalid health base';end if;
 lock table public.allowances,public.childcare_children,public.employees,public.event_plans,public.installments,public.minimum_wages,public.normative_wages,public.periods,public.records,public.unimed_rates,public.uniodonto_fixed_rates,public.versions in share row exclusive mode;
 if public.finance_calculation_snapshot(p_month)->>'token' is distinct from p_token or not exists(select 1 from public.versions where employee=p_employee and month<=p_month) then return false;end if;
 select count(*) into expected_count from public.records r where employee=p_employee and month=p_month and exists(select 1 from public.periods where month=p_month and status='open');
 if jsonb_array_length(p_records)<>expected_count then return false;end if;
 if expected_count=1 then
  item:=p_records->0;
  if item->>'employee' is distinct from p_employee or jsonb_typeof((item->>'data')::jsonb) is distinct from 'object' or not exists(select 1 from public.records where month=p_month and employee=p_employee and revision=(item->>'revision')::integer) then return false;end if;
  update public.records set data=item->>'data',revision=revision+1 where month=p_month and employee=p_employee;
 end if;
 insert into public.versions(employee,month,data) values(p_employee,p_month,p_data) on conflict(employee,month) do update set data=excluded.data;
 insert into public.audit(id,month,action,actor,created,detail) values(gen_random_uuid()::text,p_month,'Cadastro dos planos atualizado',p_actor,now()::text,jsonb_build_object('employee',p_employee,'synced',expected_count=1)::text);
 return true;
end $$;
revoke all on function public.save_finance_health_base(text,text,text,text,text,jsonb) from public,anon,authenticated;
grant execute on function public.save_finance_health_base(text,text,text,text,text,jsonb) to service_role;
