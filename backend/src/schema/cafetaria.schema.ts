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

export const createCafeteriaSchema = z.object({
    name: z.string().min(2),
    isOpen: z.boolean(),
    userId: z.string()
});

export const cafeteriaIdSchema = z.object({
  id: z.string('Cafetaria id must be a valid string ')
})

export const CafeteriaAvailabilitySchema = z.object({
  isOpne: z.boolean().default(true),
  cafeteriaId: z.string()
})