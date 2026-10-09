import {secureResponse} from '../lib/security-headers';
import {consumeRateLimit,clientAddress} from '../lib/rate-limit';
import {assertSameSiteRead,checkRequestLength,securityError} from '../lib/request-security';
import handler from "vinext/server/fetch-handler";
import { runWithConnectorBinding } from "../lib/connector-context";
import type { ConnectorBinding } from "../lib/connector-contract.mjs";

export default {
  async fetch(request: Request, env: Cloudflare.Env, ctx: ExecutionContext<{ CONNECTORS?: ConnectorBinding }>) {
    let binding = ctx.props?.CONNECTORS;
    // Local preview emulates the same request-scoped capability. This branch and
    // the auxiliary service binding are absent from production builds.
    if (import.meta.env.DEV && !binding && env.CONNECTORS) {
      const preview = env.CONNECTORS;
      const expiresAt = Date.now() + 60_000;
      binding = {
        async getContext() {
          if (Date.now() >= expiresAt) return { status: "request_context_expired" };
          return preview.getContext?.() ?? { status: "binding_unavailable" };
        },
        async invoke(connectorId, actionName, args) {
          if (Date.now() >= expiresAt) {
            return { status: "request_context_expired", message: "This request has expired. Please try again." };
          }
          return preview.invoke(connectorId, actionName, args);
        },
      };
    }
    try{
      const path=new URL(request.url).pathname;
      // This application uses authenticated API routes; server actions and remote
      // image optimization are unused and must not expose additional endpoints.
      if((request.method!=='GET'&&request.method!=='HEAD'&&!path.startsWith('/api/'))||path==='/_next/image'||path==='/_vinext/image')return secureResponse(new Response(null,{status:405}),request);
      if(path.endsWith('.map')||/(?:^|\/)\.(?:env|git)(?:[./]|$)/.test(path))return secureResponse(new Response(null,{status:404}),request);
      if(path.startsWith('/api/')){
        if(!['GET','POST'].includes(request.method))return secureResponse(new Response(null,{status:405,headers:{Allow:'GET, POST'}}),request);
        if(request.method==='GET')assertSameSiteRead(request);
        checkRequestLength(request,path==='/api/documents'?16*1024*1024:1024*1024);
        if(env.DB)await consumeRateLimit(env.DB,'api-ip',clientAddress(request),240,60000);
      }
      return secureResponse(await runWithConnectorBinding(binding, () => handler.fetch(request, env, ctx)),request);
    }catch(error){const response=securityError(error);if(response)return secureResponse(response,request);console.error('Request processing failed');return secureResponse(Response.json({error:'Não foi possível concluir a requisição.'},{status:503}),request);}
  },
};
