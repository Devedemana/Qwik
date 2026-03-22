import { z } from 'zod';
// import  { OrderItem } from '../../prisma/generated/prisma/client.ts';

export const createOrderSchema =z.object({
    userId: z.string(),
    cafeteriaId: z.string("Invalid ID format"),
    pickupWindow: z.string().datetime().refine((date) => new Date(date) > new Date(), {
      message: "Pickup window must be in the future",
    }),
    items: z.array(z.object({
     menuItemId: z.string(),
     quantity:z.coerce.number()
    })).min(1, "Atleast on valid order must be passed"),

    totalAmount: z.coerce.number()
});

export const OrderHistorySchema = z.object({
  page: z.coerce.number("Page must be valid number"),
  limit: z.coerce.number("limit should be a valid number")
})