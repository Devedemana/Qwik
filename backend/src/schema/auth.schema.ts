import { z } from 'zod';

export const LoginSchema = z.object({
  email: z.string().email("Please provide a valid email"),
  password: z.string().min(8, "Password must be at least 8 characters"),
});

export const RegisterSchema = z.object({
  name: z.string().min(2),
  email: z.string().email().refine((val) => val.endsWith('@ashesi.edu.gh'), {
    message: "Only Ashesi email addresses are permitted",
  }),
  password: z.string().min(8),
  // role is always CUSTOMER on self-registration; STAFF/ADMIN assigned via DB only
});
