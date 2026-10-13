import {chromium} from 'playwright';
import {createInterface} from 'node:readline/promises';
import {stdin,stdout} from 'node:process';
import {mkdir,writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import assert from 'node:assert/strict';
import {targetURL,allowWrite,verifyFixture,previewHost} from './guards.mjs';
const args=process.argv.slice(2),write=args.includes('--write'),reg=args.find(a=>a.startsWith('--registration='))?.split('=')[1];
if(args.some(a=>a!=='--write'&&!a.startsWith('--registration=')))throw Error('Opção desconhecida.');
if(write&&!reg)throw Error('Informe --registration=TEST-UI-001 para testar gravação.');
const origin=targetURL('https://'+previewHost),mode={origin,enabled:false,employee:null};
const report={started:new Date().toISOString(),preview:origin,mode:write?'isolated-record':'read-only',checks:[],screens:[],fields:[],httpErrors:[],javascriptErrors:0,blockedWrites:0,limitations:['Não cobre todos os campos nem todos os fluxos de cálculo. Sem screenshots, cookies, senhas, nomes ou valores de folha no relatório.']};
const out=resolve('reports');await mkdir(out,{recursive:true});
const input=createInterface({input:stdin,output:stdout});
let browser;
const check=async(name,fn,fatal=true)=>{try{await fn();report.checks.push({name,status:'PASS'});}catch{report.checks.push({name,status:'FAIL'});process.exitCode=1;if(fatal)throw Error('Falha: '+name);}};
try{
 browser=await chromium.launch({headless:false});
 const context=await browser.newContext({viewport:{width:1440,height:1000},acceptDownloads:false});
 await context.route('**/*',async route=>{
  const r=route.request();let body;try{body=r.postDataJSON();}catch{}
  if(!allowWrite(r.url(),r.method(),body,mode)){report.blockedWrites++;return route.abort('blockedbyclient');}
  return route.continue();
 });
 const page=await context.newPage();page.setDefaultTimeout(15000);
 page.on('pageerror',()=>report.javascriptErrors++);
 page.on('response',r=>{const u=new URL(r.url());if(u.origin===origin&&u.pathname.startsWith('/api/')&&r.status()>=400)report.httpErrors.push({path:u.pathname,status:r.status()});});
 await page.goto(origin+'/configuracoes',{waitUntil:'domcontentloaded'});
 console.log('No Chrome aberto, faça login manualmente. Se a Vercel pedir autenticação, ela deverá ser concluída no navegador; o teste bloqueia gravações externas. Não digite senhas neste terminal.');
 await input.question('Quando o painel IBAGY DP estiver aberto, pressione ENTER aqui. ');
 await check('sessão mantida pela aplicação',async()=>{
  const r=await page.evaluate(async()=>{const x=await fetch('/api/auth?session=1',{cache:'no-store'});return {status:x.status,data:await x.json()};});
  assert.equal(r.status,200);assert.equal(r.data.authenticated,true);
 });
 const finance=async(month,extra='')=>page.evaluate(async({month,extra})=>{
  const r=await fetch('/api/finance?month='+month+extra,{cache:'no-store'});if(!r.ok)throw Error('Finance read rejected');return r.json();
 },{month,extra});
 const tabs=['Visão geral','Cadastro','Lançamentos','Conferência da Folha','Rescisões','Relatórios','Colaboradores','Comissões','Auxílio-creche','Plano de Saúde','Configurações','Empréstimos SEREFI','Reajustes','Administração'];
 const inventory=async(screen)=>{
  const controls=await page.locator('main input:visible,main select:visible,main textarea:visible,main [role="combobox"]:visible,main [role="checkbox"]:visible,[role="dialog"] input:visible').evaluateAll(nodes=>nodes.map(e=>({id:e.id,type:e.getAttribute('type')||e.getAttribute('role')||e.tagName.toLowerCase(),disabled:e.disabled===true||e.getAttribute('aria-disabled')==='true',label:e.getAttribute('aria-label')||e.labels?.[0]?.firstChild?.textContent?.trim()||e.closest('label')?.firstChild?.textContent?.trim()||'(sem rótulo)'})));
  // Only structural labels: suppress strings containing fixture or employee identifiers.
  for(const c of controls)if(/TEST|Matrícula|CPF/i.test(c.label)&&c.label.length>80)c.label='(rótulo omitido)';
  report.screens.push({screen,controls});
 };
 for(const tab of tabs){
  const button=page.getByRole('navigation',{name:'Navegação principal'}).getByRole('button',{name:tab,exact:true});
  if(await button.count()===0){report.checks.push({name:'tela '+tab,status:'NOT_AVAILABLE_FOR_ROLE'});continue;}
  await check('tela '+tab,async()=>{await button.click();await page.locator('#workspace-title').waitFor();await inventory(tab);const names=await page.locator('main').getByRole('tab').allTextContents();for(const name of [...new Set(names)]){const inner=page.locator('main').getByRole('tab',{name,exact:true});if(await inner.count()===1&&await inner.isVisible()){await inner.click();await inventory(tab+' / '+name);}}},false);
 }
 if(write){
  const data=await finance('2099-12');const fixture=verifyFixture(data,reg);mode.employee=fixture.employee;
  const historical=await finance('2099-12','&historyOnly=1&employee='+encodeURIComponent(fixture.employee));
  const before=historical.history.filter(r=>r.month!=='2099-12');
  await page.evaluate(()=>localStorage.setItem('ibagy-selected-month','2099-12'));await page.reload({waitUntil:'domcontentloaded'});
  await page.getByRole('navigation',{name:'Navegação principal'}).getByRole('button',{name:'Conferência da Folha',exact:true}).click();
  await page.getByLabel('Competência',{exact:true}).selectOption('2099-12');
  const open=async()=>{const row=page.getByRole('row').filter({has:page.getByRole('cell',{name:'TESTE UI',exact:false})}).filter({hasText:reg});assert.equal(await row.count(),1);await row.getByRole('button',{name:'Abrir',exact:true}).click();await page.getByRole('dialog').waitFor();};
  // Check editable monetary inputs through the UI, real POST, reload, and history; then restore their initial values.
  for(const key of ['W','Z','AA']){
   const current=await finance('2099-12');verifyFixture(current,reg);
   await open();const field=page.locator('#field-'+key);await field.waitFor();assert.equal(await field.isEnabled(),true);
   const original=await field.inputValue();
   let dirty=false;
   const save=async(value)=>{await field.fill(value);await field.blur();const response=page.waitForResponse(r=>r.url()===origin+'/api/finance'&&r.request().method()==='POST');await page.getByRole('dialog').getByRole('button',{name:'Salvar valores',exact:true}).click();const r=await response;assert.equal(r.status(),200);await page.getByRole('dialog').waitFor({state:'hidden'});};
   mode.enabled=true;
   try{
    await check('gravar e recarregar campo '+key,async()=>{dirty=true;await save('22.22');const saved=await finance('2099-12');assert.equal(JSON.parse(verifyFixture(saved,reg).data)[key],'22.22');await page.reload({waitUntil:'domcontentloaded'});await page.getByRole('navigation',{name:'Navegação principal'}).getByRole('button',{name:'Conferência da Folha',exact:true}).click();await open();assert.equal(await field.inputValue(),'22.22');await inventory('Lançamento fictício');});
   }finally{
    if(dirty){try{if(!await page.getByRole('dialog').isVisible())await open();await save(original);report.checks.push({name:'restaurar campo '+key,status:'PASS'});}catch{report.checks.push({name:'restaurar campo '+key,status:'FAIL_MANUAL_REVIEW_REQUIRED'});process.exitCode=1;}}
    mode.enabled=false;
   }
   const after=await finance('2099-12','&historyOnly=1&employee='+encodeURIComponent(fixture.employee));
   await check('histórico preservado após '+key,async()=>assert.deepEqual(after.history.filter(r=>r.month!=='2099-12'),before));
   report.fields.push({key,status:'BROWSER_SAVE_RELOAD_PASS',database:'VERIFIED_VIA_REAL_FINANCE_GET'});
  }
 }else report.checks.push({name:'salvar e recarregar valores',status:'NOT_RUN_READ_ONLY'});
 if(report.javascriptErrors||report.httpErrors.some(e=>e.path!=='/api/auth'))process.exitCode=1;
}catch{report.failure='Execução interrompida; veja o último check FAIL ou autenticação/acesso. Nenhuma senha ou conteúdo da folha registrado.';process.exitCode=1;console.error(report.failure);}
finally{input.close();if(browser)await browser.close();await writeFile(resolve(out,'ui-report.json'),JSON.stringify(report,null,2)+'\n');console.log('Relatório: tools/ui-tests/reports/ui-report.json. Envie apenas esse arquivo; não envie cookies ou credenciais.');}
