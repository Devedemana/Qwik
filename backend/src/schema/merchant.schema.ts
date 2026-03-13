
import { z } from 'zod'; 
import { CapacityStatus } from '../../prisma/generated/prisma/enums.ts';

// Validating the QR scan at the counter
export const VerifyPickupSchema = z.object({
  body: z.object({
    qrToken: z.string().min(32, "Invalid QR Token"), // Token generated on order payment
    cafeteriaId: z.string().regex(/^[0-9a-fA-F]{24}$/)
  })
});

// For moving orders through the kitchen cycle
export const UpdateOrderStateSchema = z.object({
  params: z.object({
    orderId: z.string().regex(/^[0-9a-fA-F]{24}$/)
  }),
  body: z.object({
    status: z.enum(['RECEIVED', 'PREPPING', 'READY', 'COMPLETED', 'CANCELLED'])
  })
});

export const MerchantStatusSchema = z.object({
  cafeteriaId:z.string().nonempty(),
  status: z.enum(CapacityStatus)
})

export const InventoryUpdateSchema = z.object({
  itemId: z.string(),
  isAvailable: z.boolean()
})


export const InventoryToggleSchema = z.object({
  body: z.object({
    itemId: z.string().min(1, "Item ID is required"),
    isAvailable: z.boolean()
  })
});

export const CafeteriaIdParamSchema = z.object({
  params: z.object({
    cafeteriaId: z.string().min(1)
  })
});

export const OrderIdParamSchema = z.object({
  params: z.object({
    id: z.string().min(1)
  })
});

export const AdvanceOrderBodySchema = z.object({
  status: z.enum(['PREPPING', 'READY', 'COMPLETED', 'CANCELLED'])
});