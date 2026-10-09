-- Supabase configuration writes: service-role-only, transactional, auditable.
create or replace function public.save_finance_configuration(p_month text,p_action text,p_values jsonb,p_actor text,p_revision integer default 0)
returns boolean language plpgsql security invoker set search_path=public as $$
declare v_amount integer; v_young integer; v_middle integer; v_senior integer; v_previous integer; v_label text; v_changed boolean:=false;
begin
 if p_month !~ '^20[0-9]{2}-(0[1-9]|1[0-2])$' or p_action not in ('minimum_wage','allowance','unimed_rates','uniodonto_fixed_rate') then raise exception 'Invalid configuration';end if;
 if p_actor is null or length(p_actor)>200 or length(p_actor)=0 then raise exception 'Invalid actor';end if;
 if p_action in ('minimum_wage','allowance') then
   if p_values->>'amount' !~ '^[0-9]{1,8}(\.[0-9]{1,2})?$' then raise exception 'Invalid amount';end if;
   v_amount:=round((p_values->>'amount')::numeric*100)::integer;
   if v_amount<0 or (p_action='minimum_wage' and v_amount=0) then raise exception 'Invalid amount';end if;
   if p_action='minimum_wage' then
     select amount into v_previous from minimum_wages where month<=p_month order by month desc limit 1;
     if v_previous is distinct from v_amount then insert into minimum_wages(month,amount) values(p_month,v_amount) on conflict(month) do update set amount=excluded.amount;v_changed:=true;end if;
     v_label:='Salário mínimo configurado';
   else
     select amount into v_previous from allowances where month<=p_month order by month desc limit 1;
     if v_previous is distinct from v_amount then insert into allowances(month,amount) values(p_month,v_amount) on conflict(month) do update set amount=excluded.amount;v_changed:=true;end if;
     v_label:='Vale-alimentação configurado';
   end if;
 else
   if p_revision<0 or p_revision is null then raise exception 'Invalid revision';end if;
   if p_action='unimed_rates' then
     if p_values->>'young' !~ '^[0-9]{1,8}(\.[0-9]{1,2})?$' or p_values->>'middle' !~ '^[0-9]{1,8}(\.[0-9]{1,2})?$' or p_values->>'senior' !~ '^[0-9]{1,8}(\.[0-9]{1,2})?$' then raise exception 'Invalid rates';end if;
     v_young:=round((p_values->>'young')::numeric*100)::integer;v_middle:=round((p_values->>'middle')::numeric*100)::integer;v_senior:=round((p_values->>'senior')::numeric*100)::integer;
     if p_revision=0 then
       insert into unimed_rates(month,young,middle,senior,revision) values(p_month,v_young,v_middle,v_senior,1) on conflict(month) do nothing;
     else
       update unimed_rates set young=v_young,middle=v_middle,senior=v_senior,revision=revision+1 where month=p_month and revision=p_revision;
     end if;
     v_label:='Valores da Unimed configurados';
   else
     if p_values->>'amount' !~ '^[0-9]{1,8}(\.[0-9]{1,2})?$' then raise exception 'Invalid rate';end if;
     v_amount:=round((p_values->>'amount')::numeric*100)::integer;
     if p_revision=0 then
       insert into uniodonto_fixed_rates(month,amount,revision) values(p_month,v_amount,1) on conflict(month) do nothing;
     else
       update uniodonto_fixed_rates set amount=v_amount,revision=revision+1 where month=p_month and revision=p_revision;
     end if;
     v_label:='Mensalidade da Uniodonto configurada';
   end if;
   v_changed:=found;
   if not v_changed then return false;end if;
 end if;
 if v_changed then insert into audit(id,month,action,actor,created,detail) values(gen_random_uuid()::text,p_month,v_label,p_actor,now()::text,p_values::text);end if;
 return true;
end $$;
revoke all on function public.save_finance_configuration(text,text,jsonb,text,integer) from public,anon,authenticated;
grant execute on function public.save_finance_configuration(text,text,jsonb,text,integer) to service_role;