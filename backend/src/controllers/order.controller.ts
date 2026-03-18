import type { Request, Response } from 'express';
import { OrderService } from 'services/order.services.ts';




export const OrderController = {
  
  async createOrder(req: Request, res: Response) {
    try {
      const { ...body } = req.body; 
      const newOrder = await OrderService.createOrder(body); 
      
      return res.status(201).json({
        success: true,
        data: newOrder
      });
    } catch (err) {
      return res.status(500).json({
        error: 'error',
        message: err.message
      });
    };
  
  },

}