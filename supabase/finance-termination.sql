create or replace function public.finance_termination_snapshot(p_month text,p_employee text)
returns jsonb language sql stable security invoker set search_path='' as $$
 with s as(select (public.finance_calculation_snapshot(p_month)->'snapshot')||jsonb_build_object(
 'remaining_installments',coalesce((select jsonb_agg(to_jsonb(i) order by month,loan,number) from public.installments i where employee=p_employee and month>=p_month),'[]'),
 'remaining_event_plans',coalesce((select jsonb_agg(to_jsonb(e) order by id) from public.event_plans e where employee=p_employee and "end">=p_month),'[]'),
 'future_records',coalesce((select jsonb_agg(to_jsonb(r)||jsonb_build_object('status',p.status,'commission_status',p.commission_status) order by r.month) from public.records r join public.periods p on p.month=r.month where r.employee=p_employee and r.month>p_month),'[]')) state)
 select jsonb_build_object('snapshot',state,'token',md5(state::text)) from s;
$$;
revoke all on function public.finance_termination_snapshot(text,text) from public,anon,authenticated;
grant execute on function public.finance_termination_snapshot(text,text) to service_role;
create or replace function public.save_finance_termination(p_month text,p_employee text,p_actor text,p_token text,p_revision integer,p_data text,p_base text,p_date text)
returns boolean language plpgsql security invoker set search_path='' as $$
declare original jsonb;r record;next jsonb;
begin
 if p_actor is null or length(p_actor) not between 1 and 200 or p_employee is null or length(p_employee) not between 1 and 120 or p_token is null or p_token !~ '^[a-f0-9]{32}$' or p_revision is null or p_revision<1 or p_data is null or jsonb_typeof(p_data::jsonb)<>'object' or p_base is null or jsonb_typeof(p_base::jsonb)<>'object' or p_date is null or p_date !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' or left(p_date,7) is distinct from p_month then raise exception 'Invalid termination';end if;
 perform p_date::date;
 lock table public.allowances,public.childcare_children,public.employees,public.event_plans,public.installments,public.minimum_wages,public.normative_wages,public.periods,public.records,public.unimed_rates,public.uniodonto_fixed_rates,public.versions in share row exclusive mode;
 if public.finance_termination_snapshot(p_month,p_employee)->>'token' is distinct from p_token or not exists(select 1 from public.periods where month=p_month and status='open') then return false;end if;
 select data::jsonb into original from public.records where month=p_month and employee=p_employee and revision=p_revision;
 if original is null or coalesce(original->>'_terminationCarry','false')='true' or p_date<original->>'D' or not exists(select 1 from public.versions where employee=p_employee and month<=p_month) then return false;end if;
 if exists(select 1 from public.periods where month=p_month and commission_status='closed') and coalesce(nullif(original->>'U',''),'0')::numeric>0 then return false;end if;
 if exists(select 1 from public.records rec join public.periods p on p.month=rec.month where rec.employee=p_employee and rec.month>p_month and (p.status='closed' or p.commission_status='closed')) then return false;end if;
 update public.records set data=p_data,revision=revision+1 where month=p_month and employee=p_employee;
 insert into public.versions(employee,month,data) values(p_employee,p_month,p_base) on conflict(employee,month) do update set data=excluded.data;
 update public.employees set active=0 where id=p_employee;
 for r in select rec.* from public.records rec join public.periods p on p.month=rec.month where rec.employee=p_employee and rec.month>p_month and p.status='open' and p.commission_status='open' loop
  next:=r.data::jsonb||jsonb_build_object('_excluded',true,'_terminationCarry',true,'G','Rescisão','lastWorkedDay',p_date,'salaryCompetencia','0.00','AP','0.00','AL','0.00');
  update public.records set data=next::text,revision=revision+1 where month=r.month and employee=r.employee;
 end loop;
 insert into public.audit(id,month,action,actor,created,detail) values(gen_random_uuid()::text,p_month,'Rescisão registrada',p_actor,now()::text,jsonb_build_object('employee',p_employee,'date',p_date,'summary',p_data::jsonb->'_terminationSettlement')::text);
 return true;
end $$;
revoke all on function public.save_finance_termination(text,text,text,text,integer,text,text,text) from public,anon,authenticated;
grant execute on function public.save_finance_termination(text,text,text,text,integer,text,text,text) to service_role;
