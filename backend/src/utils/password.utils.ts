import  bcrypt from 'bcrypt'
import { env } from '../../env.ts'

export async function hashPassword(password: string){
    return bcrypt.hash(password, env.BCRYPT_ROUNDS)
}

// return boolean
export async function verifyPassword(password: string, hashedPassword: string) {
    return await bcrypt.compare(password, hashedPassword)
}