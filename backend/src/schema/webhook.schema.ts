import { z } from 'zod'; 

export const paymentWebhookSchema = z.object({
  body: z.object({
    event: z.string(),
    data: z.object({
      reference: z.string(), // This will be your Order ID
      status: z.string(),
      amount: z.number(),
      currency: z.string().default('GHS'),
      customer: z.object({
        email: z.string().email()
      })
    })
  })
});