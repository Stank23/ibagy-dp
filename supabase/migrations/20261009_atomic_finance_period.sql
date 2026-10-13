-- Execute somente após revisão no projeto Supabase de testes.
-- A alteração de status e a auditoria precisam ser atômicas.
create or replace function public.transition_finance_period(
  p_month text, p_action text, p_actor text, p_reason text default ''
) returns boolean
language plpgsql security invoker set search_path = public
as $$
declare
  current_period public.periods%rowtype;
begin
  if p_month !~ '^20[0-9]{2}-(0[1-9]|1[0-2])$' then
    raise exception 'Competência inválida';
  end if;
  if p_action not in ('close','reopen','commission_close','commission_reopen') then
    raise exception 'Ação inválida';
  end if;
  if p_action in ('reopen','commission_reopen') and length(trim(coalesce(p_reason,''))) < 5 then
    raise exception 'Motivo obrigatório';
  end if;

  select * into current_period from public.periods
    where month = p_month for update;
  if not found then return false; end if;

  if p_action = 'close' and current_period.status = 'open' then
    update public.periods set status = 'closed', commission_status = 'closed' where month = p_month;
  elsif p_action = 'reopen' and current_period.status = 'closed' then
    update public.periods set status = 'open' where month = p_month;
  elsif p_action = 'commission_close' and current_period.status = 'open' and current_period.commission_status = 'open' then
    update public.periods set commission_status = 'closed' where month = p_month;
  elsif p_action = 'commission_reopen' and current_period.status = 'open' and current_period.commission_status = 'closed' then
    update public.periods set commission_status = 'open' where month = p_month;
  else
    return false;
  end if;

  insert into public.audit(id,month,action,actor,created,detail)
  values (
    gen_random_uuid()::text, p_month,
    case p_action
      when 'close' then 'Competência fechada'
      when 'reopen' then 'Competência reaberta'
      when 'commission_close' then 'Comissão fechada'
      else 'Comissão reaberta'
    end,
    p_actor, now()::text,
    jsonb_build_object('reason',coalesce(p_reason,''))::text
  );
  return true;
end;
$$;
revoke all on function public.transition_finance_period(text,text,text,text) from public,anon,authenticated;
grant execute on function public.transition_finance_period(text,text,text,text) to service_role;
