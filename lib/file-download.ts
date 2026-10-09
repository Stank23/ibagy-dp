export async function downloadFile(id:string,fallbackName='IBAGY-exportacao.xlsx'){
 const response=await fetch('/api/finance?file='+encodeURIComponent(id),{credentials:'same-origin',cache:'no-store'});
 if(!response.ok){const data:any=await response.json().catch(()=>null);throw Error(data?.error||'Não foi possível baixar o arquivo. Tente novamente.');}
 const type=response.headers.get('content-type')||'';if(type.includes('text/html')||type.includes('application/json'))throw Error('Sua sessão expirou. Atualize a página e entre novamente para baixar.');
 const blob=await response.blob();if(!blob.size)throw Error('O arquivo está vazio. Gere uma nova exportação.');
 const disposition=response.headers.get('content-disposition')||'';const encoded=disposition.match(/filename\*=UTF-8''([^;]+)/i)?.[1];const plain=disposition.match(/filename="([^"]+)"/i)?.[1];let name=plain||fallbackName;try{if(encoded)name=decodeURIComponent(encoded);}catch{}
 const url=URL.createObjectURL(blob),link=document.createElement('a');link.href=url;link.download=name;document.body.appendChild(link);link.click();link.remove();setTimeout(()=>URL.revokeObjectURL(url),60000);
}
