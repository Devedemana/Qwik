import { Request, Response } from 'express';
import { MerchantService } from '../services/merchant.services.ts';

export const MerchantController = {
  // 1. PATCH /api/merchant/status
  async updateStatus(req: Request, res: Response) {
    try {
      const { cafeteriaId, status } = req.body;
      const result = await MerchantService.updateCafeteriaStatus(cafeteriaId, status);
      
      return res.status(200).json({ success: true, data: result });
    } catch (error) {
      return res.status(500).json({ success: false, error: 'Status update failed' });
    }
  },

  // 2. PUT /api/merchant/inventory
  async toggleInventory(req: Request, res: Response) {
    try {
      const { itemId, isAvailable } = req.body;
      const result = await MerchantService.updateItemAvailability(itemId, isAvailable);
      
      return res.status(200).json({ success: true, data: result });
    } catch (error) {
      return res.status(500).json({ success: false, error: 'Inventory update failed' });
    }
  },

  // 3. GET /api/merchant/orders/:cafeteriaId
  async getQueue(req: Request, res: Response) {
    try {
      const { cafeteriaId } = req.params;
      const result = await MerchantService.fetchActiveOrders(cafeteriaId);
      
      return res.status(200).json({ success: true, data: result });
    } catch (error) {
      return res.status(500).json({ success: false, error: 'Failed to fetch queue' });
    }
  },

  // 4. PATCH /api/merchant/orders/:id
  async advanceOrder(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { status } = req.body; // New status (e.g., READY)
      const result = await MerchantService.updateOrderStatus(id, status);
      
      return res.status(200).json({ success: true, data: result });
    } catch (error) {
      return res.status(500).json({ success: false, error: 'Order update failed' });
    }
  }
};