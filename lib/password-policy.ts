export const PASSWORD_RULE='A senha deve ter de 9 a 256 caracteres, pelo menos um número, uma letra maiúscula e um caractere especial.';
export function validPassword(value:string){return value.length>=9&&value.length<=256&&/[0-9]/.test(value)&&/\p{Lu}/u.test(value)&&/[^\p{L}\p{N}\s]/u.test(value);}
