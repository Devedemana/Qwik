import { z } from 'zod';

export const UpdatePreferencesSchema = z.object({
  dietaryLifestyle: z.array(z.enum(['VEGAN', 'KETO', 'HALAL', 'VEGETARIAN'])).optional(),
  allergies: z.array(z.string()).optional(),
});
