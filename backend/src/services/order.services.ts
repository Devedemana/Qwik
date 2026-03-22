import { prisma } from "../lib/prisma.ts";
import { createOrderSchema, OrderHistorySchema } from "schema/order.schema.ts";
import {z} from "zod";
import { v4 as uuid4 } from 'uuid'; 
import { emitUpdate } from "lib/socket.ts";
import { OrderStatus } from "../../prisma/generated/prisma/enums.ts";



export const OrderService = {
    async createOrder(value: z.infer<typeof createOrderSchema>) {
    const orderResult = await prisma.order.create({
        data: {
         userId: value.userId,
         cafeteriaId: value.cafeteriaId,
         totalAmount: value.totalAmount,
         status: OrderStatus.COMPLETED,
         isPaid: true,
         pickupWindow:value.pickupWindow,
         qrCodeSecret: uuid4(),
          items: {
            create: value.items.map((itm)=> ({
                menuItemId: itm.menuItemId,
                quantity: itm.quantity
              }))
          },
        },
        // return these fields
        select: {
            id: true,
            totalAmount: true,
            userId: true,
            cafeteriaId: true,
            status:true,
            qrCodeSecret: true
        }
    });

    emitUpdate(`cafeteria:${value.cafeteriaId}`, "order:placed", {...orderResult});
    
    // return 
    return {...orderResult} ; 
  
  },

  async getHistory(value: z.infer<typeof OrderHistorySchema>, userId: string ) {
    const limit = value.limit || 10; 
    const page = value.page || 1; 
    const offSet = (page - 1) * limit ; 
    const oderHistory = await prisma.order.findMany({
      where: {userId: userId },
      select: {
          id: true,
          cafeteriaId: true,
          totalAmount: true,
          status: true,
          createdAt:true
      },
      orderBy: {createdAt: 'desc'},
      skip: offSet
    });    
    // return 
    return {...oderHistory} ; 
  
  }
}; 
