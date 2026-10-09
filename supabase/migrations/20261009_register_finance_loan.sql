create or replace function public.register_finance_loan(p_id text,p_employee text,p_month text,p_end text,p_total integer,p_parts jsonb,p_actor text)
returns boolean language plpgsql security invoker set search_path=public as $$
declare v_count integer;v_part jsonb;v_index integer:=0;v_month text;v_amount integer;v_fee integer;v_principal integer;v_expected_month text;v_sum integer:=0;
begin
 if p_id is null or length(p_id) not between 1 and 120 or p_employee is null or length(p_employee) not between 1 and 120 or p_month !~ '^20[0-9]{2}-(0[1-9]|1[0-2])$' or p_end !~ '^20[0-9]{2}-(0[1-9]|1[0-2])$' or p_actor is null or length(p_actor) not between 1 and 200 then raise exception 'Invalid loan context';end if;
 if p_total is null or p_total<=0 or jsonb_typeof(p_parts)<>'array' then raise exception 'Invalid loan';end if;
 v_count:=jsonb_array_length(p_parts);
 if v_count<1 or v_count>120 or p_total<v_count then raise exception 'Invalid installment count';end if;
 if to_char((to_date(p_month||'-01','YYYY-MM-DD')+(v_count-1)*interval '1 month')::date,'YYYY-MM')<>p_end then raise exception 'Incorrect final month';end if;
 perform 1 from employees where id=p_employee for update;
 if not found then return false;end if;
 perform 1 from periods where month between p_month and p_end and status='closed' for update;
 if found then return false;end if;
 for v_part in select value from jsonb_array_elements(p_parts) loop
  v_index:=v_index+1;
  v_expected_month:=to_char((to_date(p_month||'-01','YYYY-MM-DD')+(v_index-1)*interval '1 month')::date,'YYYY-MM');
  v_month:=v_part->>'month';
  if v_month is distinct from v_expected_month or (v_part->>'number')::integer<>v_index then raise exception 'Invalid installment order';end if;
  v_principal:=(v_part->>'principal')::integer;v_fee:=(v_part->>'fee')::integer;v_amount:=(v_part->>'amount')::integer;
  if v_principal<=0 or v_fee<>(case when v_index=1 then 280 else 0 end) or v_amount<>v_principal+v_fee or v_principal<>(case when v_index=v_count then p_total-(p_total/v_count)*(v_count-1) else p_total/v_count end) then raise exception 'Invalid installment arithmetic';end if;
  v_sum:=v_sum+v_principal;
 end loop;
 if v_sum<>p_total then raise exception 'Invalid total';end if;
 insert into loans(id,employee,amount,count,start,"end",created) values(p_id,p_employee,p_total,v_count,p_month,p_end,now()::text);
 for v_part in select value from jsonb_array_elements(p_parts) loop
  v_month:=v_part->>'month';v_amount:=(v_part->>'amount')::integer;
  insert into installments(loan,employee,month,number,principal,fee,amount) values(p_id,p_employee,v_month,(v_part->>'number')::integer,(v_part->>'principal')::integer,(v_part->>'fee')::integer,v_amount);
  update records set data=(
    jsonb_set(
      jsonb_set(data::jsonb,'{AI}',to_jsonb(to_char((coalesce(nullif(data::jsonb->>'AI',''),'0')::numeric*100+v_amount)/100,'FM9999999990.00'))),
      '{_serefiAuto}',to_jsonb(coalesce((data::jsonb->>'_serefiAuto')::integer,0)+v_amount)
    )
  )::text,revision=revision+1
  where employee=p_employee and month=v_month and exists(select 1 from periods where periods.month=v_month and status='open');
 end loop;
 insert into audit(id,month,action,actor,created,detail) values(gen_random_uuid()::text,p_month,'Empréstimo SEREFI cadastrado',p_actor,now()::text,jsonb_build_object('loan',p_id,'total',p_total,'count',v_count,'end',p_end,'fee',280)::text);
 return true;
end $$;
revoke all on function public.register_finance_loan(text,text,text,text,integer,jsonb,text) from public,anon,authenticated;
grant execute on function public.register_finance_loan(text,text,text,text,integer,jsonb,text) to service_role;