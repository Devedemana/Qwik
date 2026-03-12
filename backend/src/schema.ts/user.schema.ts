import { z } from 'zod'; 

export const updatePreferencesSchema = z.object({
  body: z.object({
    dietaryLifestyle: z.array(z.enum(['VEGAN', 'KETO', 'HALAL', 'VEGETARIAN'])).optional(),
    allergies: z.array(z.string()).optional(), // e.g., ["Peanuts", "Dairy"]
  }),
});