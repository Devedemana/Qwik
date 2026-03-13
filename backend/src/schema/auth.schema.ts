import { z } from 'zod';

export const loginSchema = z.object({
  body: z.object({
    email: z.string().email("Please provide a valid Ashesi email"),
    password: z.string().min(8, "Password must be at least 8 characters"),
  }),
});

export const registerSchema = z.object({
  body: z.object({
    name: z.string().min(2),
    email: z.string().email().refine((val) => val.endsWith('@ashesi.edu.gh'), {
      message: "Only Ashesi email addresses are permitted",
    }),
    password: z.string().min(8),
    role: z.enum(['STUDENT', 'STAFF', 'ADMIN']).default('STUDENT'),
  }),
});