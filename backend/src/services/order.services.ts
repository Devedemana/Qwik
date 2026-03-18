import { emitUpdate } from "lib/socket.ts";
import {OrderStatus,CapacityStatus,} from "../../prisma/generated/prisma/enums.ts";
import { prisma } from "../lib/prisma.ts";
import { createOrderSchema } from "schema/order.schema.ts";
import z from "zod";
import { v4 as uuid4 } from 'uuid'; 

export const OrderService = {
    async createOrder(data: z.infer<typeof createOrderSchema>) {
        // total price based on order
        const newOrder = await prisma.order.create({
            data: {
                qrCodeSecret: uuid4(),
                isPaid: true,
                ...data
            },
            select: {
                totalAmount: true,
                pickupWindow: true,
                items: true
            }
        });
    // emit changes to all cafetaria users
    emitUpdate(`order:${newOrder.id}`, "order_placed", {
      cafeteriaId:data.cafeteriaId,
      status: newOrder.status,
    });

    return newOrder;
  },

  
};


