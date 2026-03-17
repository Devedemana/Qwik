import { type JWTPayload, SignJWT, jwtVerify } from "jose";
import { createSecretKey } from "node:crypto";
import { env } from "./../../env.ts";
import { Role } from "../../prisma/generated/prisma/enums.ts";

export interface TokenPayload extends JWTPayload {
  id: string;
  role: Role;
  email: string;
}

export function generateToken(payload: TokenPayload) {
  const secret = env.JWT_SECRET;
  const secretKey = createSecretKey(secret, "utf8");
  return new SignJWT(payload as unknown as JWTPayload)
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime(env.JWT_EXPIRES_IN || "7d")
    .sign(secretKey);
}


export async function verifyToken(token: string): Promise<TokenPayload>{
  try {
    const secretKey = createSecretKey(env.JWT_SECRET, 'utf-8');
    const payload = await jwtVerify(token, secretKey) as unknown as TokenPayload;
    // return
    return payload;
  } catch (err) {
    throw new Error(err); 
  }
}