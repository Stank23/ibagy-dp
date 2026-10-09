// Builds rollback-only SQL from synthetic outputs of test-all-fields.mjs.
import {readFile,writeFile} from 'node:fs/promises';
const [fixturePath,outputPath]=process.argv.slice(2);
if(!fixturePath||!outputPath)throw Error('Usage: node scripts/build-field-database-test.mjs <synthetic-fixtures.json> <output.sql>');
const fixture=JSON.parse(await readFile(fixturePath,'utf8'));
if(fixture.employee!=='test-all-fields-v77'||fixture.month!=='2000-02')throw Error('Only the isolated synthetic fixture is allowed');
const literal=v=>"'"+JSON.stringify(v).replaceAll("'","''")+"'::jsonb";
const sql=`-- Generated synthetic field tests. Never remove ROLLBACK.
begin;
do $$ begin
 if exists(select 1 from public.versions where month<='2000-02') or exists(select 1 from public.periods where month in ('2000-01','2000-02')) then
  raise exception 'Test months are not isolated';
 end if;
end $$;
create temporary table field_fixture as select ${literal(fixture.baseline)} as baseline,${literal(fixture.raw)} as registration,${literal(fixture.cases)} as cases;
insert into public.employees(id,registration,active) values('test-all-fields-v77','TEST-ALL-FIELDS',1);
insert into public.versions(employee,month,data) select 'test-all-fields-v77','1995-02',registration::text from field_fixture;
insert into public.periods(month,status,commission_status) values('2000-01','closed','closed'),('2000-02','open','open');
insert into public.records(month,employee,data,revision) values('2000-01','test-all-fields-v77','{"historical":"unchanged"}',77);
insert into public.records(month,employee,data,revision) select '2000-02','test-all-fields-v77',baseline::text,1 from field_fixture;
do $$
declare f record; item jsonb; expected jsonb; actual jsonb; token text; counter integer:=0;
begin
 select * into f from field_fixture;
 for item in select value from jsonb_array_elements(f.cases) loop
  -- Isolate each field against the same fixture, without changing other months.
  update public.records set data=f.baseline::text,revision=1 where month='2000-02' and employee='test-all-fields-v77';
  token:=public.finance_calculation_snapshot('2000-02')->>'token';
  expected:=f.baseline||(item->'patch');
  assert public.save_calculated_finance_period('2000-02','record','synthetic-field-test',token,
   jsonb_build_array(jsonb_build_object('employee','test-all-fields-v77','revision',1,'data',expected::text))), 'Field write rejected: '||(item->>'key');
  select data::jsonb into actual from public.records where month='2000-02' and employee='test-all-fields-v77';
  assert actual=expected,'Stored data differs: '||(item->>'key');
  assert (select revision=2 from public.records where month='2000-02' and employee='test-all-fields-v77');
  assert (public.finance_calculation_snapshot('2000-02')->'snapshot'->'records'->0->>'data')::jsonb=expected,'Snapshot reload differs: '||(item->>'key');
  assert (select revision=77 and data='{"historical":"unchanged"}' from public.records where month='2000-01' and employee='test-all-fields-v77'),'Historical record changed';
  counter:=counter+1;
 end loop;
 assert counter=137,'Catalog or extra coverage changed';
 assert (select count(*)=counter from public.audit where month='2000-02' and actor='synthetic-field-test'),'Missing audit';
end $$;
select jsonb_build_object('result','PASS','fields',137,'catalog_fields',118,'extra_fields',19,'tests','RPC write, record JSON reload, snapshot reload, revision, audit and closed historical month') as field_result;
rollback;
`;
await writeFile(outputPath,sql);
console.log('Generated rollback-only PostgreSQL coverage for 137 synthetic field scenarios.');
