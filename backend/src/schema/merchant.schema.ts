
import { z } from 'zod'; 

// Validating the QR scan at the counter
export const verifyPickupSchema = z.object({
  body: z.object({
    qrToken: z.string().min(32, "Invalid QR Token"), // Token generated on order payment
    cafeteriaId: z.string().regex(/^[0-9a-fA-F]{24}$/)
  })
});

// For moving orders through the kitchen cycle
export const updateOrderStateSchema = z.object({
  params: z.object({
    orderId: z.string().regex(/^[0-9a-fA-F]{24}$/)
  }),
  body: z.object({
    status: z.enum(['RECEIVED', 'PREPPING', 'READY', 'COMPLETED', 'CANCELLED'])
  })
});