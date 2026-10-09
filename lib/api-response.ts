export class AccessRequiredError extends Error {
 constructor(){super('Seu acesso precisa ser renovado. Clique em Atualizar acesso e entre novamente, se solicitado. Depois, tente reabrir o mês.');this.name='AccessRequiredError';}
}
export async function readApiResponse(response:Response):Promise<any>{
 const text=await response.text();
 const html=/^\s*</.test(text);
 if(response.status===401||response.status===403||response.redirected||html&&/Log in to access|Continuar com o ChatGPT|signin-with-chatgpt|sign_in_required/i.test(text))throw new AccessRequiredError();
 if(html)throw Error('O servidor retornou uma página em vez da resposta do sistema. Atualize a página e tente novamente.');
 let result:any;
 try{result=JSON.parse(text);}catch{throw Error('Não foi possível confirmar a operação. Atualize os dados antes de tentar novamente.');}
 if(!response.ok)throw Error(result?.error||'Não foi possível concluir a operação. Tente novamente.');
 if(!result||typeof result!=='object'||Array.isArray(result))throw Error('Resposta inválida do sistema. Atualize a página e tente novamente.');
 return result;
}
