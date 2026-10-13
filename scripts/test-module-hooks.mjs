// Resolve the application's extensionless TypeScript imports without dependencies.
import {registerHooks} from 'node:module';
import {existsSync,readFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
registerHooks({
 resolve(specifier,context,next){
  if(specifier.startsWith('.')&&context.parentURL?.startsWith('file:')){
   const url=new URL(specifier,context.parentURL);
   if(existsSync(fileURLToPath(url)+'.ts'))return next(url.href+'.ts',context);
  }
  return next(specifier,context);
 },
 load(url,context,next){
  if(url.endsWith('/lib/fields.json'))return {format:'module',source:'export default '+readFileSync(fileURLToPath(url),'utf8'),shortCircuit:true};
  return next(url,context);
 }
});
