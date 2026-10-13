begin;
do $$
declare u text:='synthetic-first-login';
begin
 assert not exists(select 1 from public.app_users where id=u);
 insert into public.app_users(id,username,name,role,salt,password_hash,active,must_change_password) values(u,u,'TESTE','admin',repeat('a',32),repeat('a',64),1,true);
 insert into public.app_sessions(token_hash,user_id,expires) values(repeat('1',64),u,2000);
 assert not public.create_finance_auth_session(u,repeat('a',64),repeat('2',64),2000,1000,null),'Temporary password created unrestricted session';
 assert not public.change_finance_password_and_session(u,repeat('x',64),repeat('b',32),repeat('b',64),repeat('3',64),2000,1000,null),'Stale current hash accepted';
 begin
  perform public.change_finance_password_and_session(u,repeat('a',64),repeat('b',32),repeat('b',64),repeat('3',64),500,1000,null);
  raise exception 'Invalid session accepted';
 exception when raise_exception then
  assert (select password_hash=repeat('a',64) and must_change_password from public.app_users where id=u),'Failed session partially changed password';
 end;
 assert public.change_finance_password_and_session(u,repeat('a',64),repeat('b',32),repeat('b',64),repeat('3',64),2000,1000,null);
 assert (select password_hash=repeat('b',64) and salt=repeat('b',32) and not must_change_password from public.app_users where id=u);
 assert (select count(*)=1 from public.app_sessions where user_id=u);
 assert not exists(select 1 from public.app_sessions where token_hash=repeat('1',64));
 assert not public.change_finance_password_and_session(u,repeat('a',64),repeat('c',32),repeat('c',64),repeat('4',64),2000,1000,null),'Temporary password replay accepted';
 assert public.create_finance_auth_session(u,repeat('b',64),repeat('4',64),2000,1000,null);
 assert (select count(*)=1 from public.audit where actor=u and action='Senha pessoal definida');
 assert not exists(select 1 from public.audit where actor=u and detail like '%password_hash%');
 assert not has_function_privilege('anon','public.change_finance_password_and_session(text,text,text,text,text,bigint,bigint,text)','execute');
 assert not has_function_privilege('authenticated','public.change_finance_password_and_session(text,text,text,text,text,bigint,bigint,text)','execute');
end $$;
select 'PASS: first-login gate, password/session atomicity, stale hash and replay, old session revocation, personal login and private audited RPC' as result;
rollback;
