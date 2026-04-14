import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware.ts';
import { OrderService } from '../services/order.service.ts';

export const OrderController = {
  async create(req: AuthRequest, res: Response) {
    try {
      const { cafeteriaId, pickupWindow, items } = req.body;
      const order = await OrderService.createOrder({
        userId: req.user!.id,
        cafeteriaId,
        pickupWindow,
        items,
      });
      return res.status(201).json({ success: true, data: order });
    } catch (error: any) {
      return res.status(400).json({ success: false, error: error.message });
    }
  },

  async list(req: AuthRequest, res: Response) {
    try {
      const orders = await OrderService.getUserOrders(req.user!.id);
      return res.status(200).json({ success: true, data: orders });
    } catch (error: any) {
      return res.status(500).json({ success: false, error: error.message });
    }
  },

  async getById(req: AuthRequest, res: Response) {
    try {
      const order = await OrderService.getOrderById(req.params.id as string, req.user!.id);
      return res.status(200).json({ success: true, data: order });
    } catch (error: any) {
      const status = error.message === 'Order not found' ? 404 : 500;
      return res.status(status).json({ success: false, error: error.message });
    }
  },

  async cancel(req: AuthRequest, res: Response) {
    try {
      const order = await OrderService.cancelOrder(req.params.id as string, req.user!.id);
      return res.status(200).json({ success: true, data: order });
    } catch (error: any) {
      return res.status(400).json({ success: false, error: error.message });
    }
  },

  async markPaid(req: AuthRequest, res: Response) {
    try {
      const order = await OrderService.markPaid(req.params.id as string);
      return res.status(200).json({ success: true, data: order });
    } catch (error: any) {
      return res.status(400).json({ success: false, error: error.message });
    }
  },
};
