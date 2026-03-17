import { z } from 'zod';
import { Role } from '../../prisma/generated/prisma/enums.ts';

export const loginSchema = z.object({
    email: z.string().email("Please provide a valid Ashesi email"),
  password: z.string().min(8, "Password must be at least 8 characters"),
});

export const registerSchema = z.object({
    name: z.string(),
    cardId: z.coerce.number(),
    email: z.string().email().refine((val) => val.endsWith('@ashesi.edu.gh'), {
      message: "Only Ashesi email addresses are permitted",
    }),
    password: z.string().min(8),
    role: z.enum(Role).default('CUSTOMER'),
});