import { type JWTPayload, SignJWT, jwtVerify } from "jose";
import { createSecretKey } from "node:crypto";
import { env } from "./../../env.ts";

export interface JWT_Payload {
  id: string;
  username: string;
  email: string;
}

export function generateToken(payload: JWT_Payload) {
  const secret = env.JWT_SECRET;
  const secretKey = createSecretKey(secret, "utf8");
  return new SignJWT(payload as unknown as JWTPayload)
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime(env.JWT_EXPIRES_IN || "7d")
    .sign(secretKey);
}


export async function verifyToken(token: string): Promise<JWT_Payload>{
  try {
    const secretKey = createSecretKey(env.JWT_SECRET, 'utf-8');
    const payload = await jwtVerify(token, secretKey) as unknown as JWT_Payload;
    // return
    return payload;
  } catch (err) {
    throw err; 
  }
}