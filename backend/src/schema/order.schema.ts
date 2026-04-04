import { z } from 'zod';

export const CreateOrderBodySchema = z.object({
  cafeteriaId: z.string().uuid("Invalid cafeteria ID"),
  pickupWindow: z.string().datetime().refine((date) => new Date(date) > new Date(), {
    message: "Pickup window must be in the future",
  }),
  items: z.array(z.object({
    menuItemId: z.string().uuid("Invalid menu item ID"),
    quantity: z.number().int().positive().max(10),
  })).min(1),
});

export const OrderIdParamSchema = z.object({
  id: z.string().uuid("Invalid order ID"),
});
