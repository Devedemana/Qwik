import { prisma } from "../lib/prisma.ts";
import { hashPassword, verifyPassword } from "utils/password.utils.ts";
import { registerSchema } from "schema/auth.schema.ts";
import {  z } from 'zod'; 

export const AuthService = {
    async registerUser(userDetails: z.infer<typeof registerSchema>) {
        const { password, ...theRest } = userDetails; 
        const hashedPassword = await hashPassword(password); 
        return await prisma.user.create({
            data: {
                password: hashedPassword,
                ...theRest
            },
            select: {
                id: true,
                email: true,
                role: true,
                name: true,
                dietaryLifestyle: true,
                allergies: true,
                createdAt: true
            }
        });
    },

     async isValidUser(userDetails: z.infer<typeof registerSchema>) {
        const { password,email, ...theRest } = userDetails; 
         const user =  await prisma.user.findUnique({
             where: { email: email },
             select: {
                 password: true
             }
         });
        return  await verifyPassword(password, user.password);
    },
  
};
