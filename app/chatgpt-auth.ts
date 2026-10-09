import {redirect} from 'next/navigation';
import {localUser} from '@/lib/local-auth';
export type ChatGPTUser={userId:string,email:string,displayName:string,fullName:string|null,role?:string};
export const getChatGPTUser=localUser;
export async function requireChatGPTUser(returnTo:string):Promise<ChatGPTUser>{const user=await localUser();if(user)return user;redirect('/login');}
export function chatGPTSignInPath(returnTo:string){return '/login';}
export function chatGPTSignOutPath(returnTo='/'){return '/login';}
