-- Immutable export/document versions; no payroll row is modified by this function.
create or replace function public.save_finance_file(p_month text,p_kind text,p_id text,p_name text,p_key text,p_actor text,p_token text)
returns boolean language plpgsql security invoker set search_path='' as $$
declare v_snapshot jsonb;
begin
 if p_month is null or p_month !~ '^20[0-9]{2}-(0[1-9]|1[0-2])$' or p_kind is null or p_kind not in('commission','health','payroll','document') or p_id is null or p_id !~ '^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$' or p_name is null or length(p_name) not between 1 and 200 or p_name ~ '[[:cntrl:]]' or p_actor is null or length(p_actor) not between 1 and 200 or p_token is null or p_token !~ '^[a-f0-9]{32}$' then raise exception 'Invalid file metadata';end if;
 if p_key is distinct from (case when p_kind='document' then 'documents/'||p_month||'/'||p_id else 'exports/'||p_month||'/'||p_id||case when p_kind='commission' then '.xlsx' else '.xls' end end) then raise exception 'Invalid object path';end if;
 lock table public.periods,public.employees,public.versions,public.records,public.allowances,public.minimum_wages,public.normative_wages,public.unimed_rates,public.uniodonto_fixed_rates,public.installments,public.event_plans,public.childcare_children in share row exclusive mode;
 v_snapshot:=public.finance_calculation_snapshot(p_month);
 if v_snapshot->>'token' is distinct from p_token or v_snapshot->'snapshot'->'period'='null'::jsonb then return false;end if;
 if exists(select 1 from public.files where id=p_id or key=p_key) then return false;end if;
 insert into public.files(id,month,kind,name,key,created) values(p_id,p_month,p_kind,p_name,p_key,now()::text);
 insert into public.audit(id,month,action,actor,created,detail) values(gen_random_uuid()::text,p_month,case when p_kind='document' then 'Documento anexado' else 'Arquivo exportado' end,p_actor,now()::text,jsonb_build_object('file',p_id,'kind',p_kind,'revisions',(select coalesce(jsonb_agg(jsonb_build_object('employee',r.employee,'revision',r.revision) order by r.employee),'[]'::jsonb) from public.records r where r.month=p_month))::text);
 return true;
end $$;
revoke all on function public.save_finance_file(text,text,text,text,text,text,text) from public,anon,authenticated;
grant execute on function public.save_finance_file(text,text,text,text,text,text,text) to service_role;
