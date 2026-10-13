-- Restore the v77 normative_wage + childcareRefresh atomic behavior.
-- Requires finance-childcare.sql. Internal RPC; never grant public access.
create or replace function public.save_normative_wage(p_month text,p_amount text,p_actor text)
returns boolean language plpgsql set search_path='' as $$
declare v_amount integer;v_previous integer;
begin
 if p_month !~ '^20[0-9]{2}-(0[1-9]|1[0-2])$' or p_amount !~ '^[0-9]{1,8}(\.[0-9]{1,2})?$' or length(coalesce(p_actor,'')) not between 1 and 200 then raise exception 'Invalid normative wage';end if;
 v_amount:=round(p_amount::numeric*100)::integer;
 if v_amount<=0 then raise exception 'Normative wage must be positive';end if;
 perform pg_advisory_xact_lock(hashtext('normative-wage:'||p_month));
 select amount into v_previous from public.normative_wages where month=p_month;
 if v_previous is not distinct from v_amount then return true;end if;
 -- Serialize with close/reopen before selecting the open records to refresh.
 perform 1 from public.periods where month>=p_month order by month for update;
 insert into public.normative_wages(month,amount) values(p_month,v_amount) on conflict(month) do update set amount=excluded.amount;
 perform public.refresh_finance_childcare(p_month,null);
 insert into public.audit(id,month,action,actor,created,detail) values(gen_random_uuid()::text,p_month,'Salário normativo configurado',p_actor,now()::text,jsonb_build_object('amount',v_amount,'percent',20)::text);
 return true;
end $$;
revoke all on function public.save_normative_wage(text,text,text) from public,anon,authenticated;
grant execute on function public.save_normative_wage(text,text,text) to service_role;
