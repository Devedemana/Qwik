import type { Request, Response } from 'express';
import { OrderService } from 'services/order.services.ts';



export const OrderController = {
  // order creation : 
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

  async getHistory(req: Request, res: Response) {
    try {
      const page = parseInt(req.query.page) || 1 ; 
      const limit = parseInt(req.query.limit) || 10; 
      const {id, ...rest}  = req.user ; 
      const newOrder = await OrderService.getHistory({page:page, limit: limit}, id);       
      return res.status(200).json({
        success: true,
        page: page, 
        limit: limit , 
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