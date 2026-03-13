import { z } from 'zod';

export const createOrderSchema = z.object({
  body: z.object({
    cafeteriaId: z.string().regex(/^[0-9a-fA-F]{24}$/, "Invalid ID format"),
    pickupWindow: z.string().datetime().refine((date) => new Date(date) > new Date(), {
      message: "Pickup window must be in the future",
    }),
    items: z.array(z.object({
      menuItemId: z.string().regex(/^[0-9a-fA-F]{24}$/),
      quantity: z.number().int().positive().max(10),
    })).min(1),
  }),
});