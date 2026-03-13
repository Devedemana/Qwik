import { z } from 'zod';

// For updating the cafeteria's live status (Congestion Control)
export const updateCafeteriaStatusSchema = z.object({
  body: z.object({
    isOpen: z.boolean().optional(),
    capacityStatus: z.enum(['GREEN', 'YELLOW', 'RED']).optional(),
  })
});

// For managing individual menu items
export const menuItemSchema = z.object({
  body: z.object({
    name: z.string().min(2),
    price: z.number().positive(),
    description: z.string().optional(),
    isAvailable: z.boolean().default(true),
    allergenTags: z.array(z.string()).default([]), // Automated allergen tags
    category: z.enum(['Breakfast', 'Lunch', 'Drinks', 'Snacks']),
  })
});