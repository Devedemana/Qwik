import { Request, Response } from 'express';
import { MerchantService } from '../services/merchant.services.ts';
import { AnalyticsService } from '../services/analytics.service.ts';

export const MerchantController = {
  // 1. PATCH /api/merchant/status
  async updateStatus(req: Request, res: Response) {
    try {
      const { cafeteriaId, status } = req.body;
      console.log('cafetaria: ', cafeteriaId)
      const result = await MerchantService.updateCafeteriaStatus(cafeteriaId, status);
      
      return res.status(200).json({ success: true, data: result });
    } catch (error) {
      return res.status(500).json({
        success: false,
        error: 'Status update failed',
        detail: error
      });
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
      const cafeteriaId = req.params.cafeteriaId as string;
      const result = await MerchantService.fetchActiveOrders(cafeteriaId);
      
      return res.status(200).json({ success: true, data: result });
    } catch (error) {
      return res.status(500).json({ success: false, error: 'Failed to fetch queue' });
    }
  },

  // 4. PATCH /api/merchant/orders/:id
  async advanceOrder(req: Request, res: Response) {
    try {
      const id = req.params.id as string;
      const { status } = req.body;
      const result = await MerchantService.updateOrderStatus(id, status);

      return res.status(200).json({ success: true, data: result });
    } catch (error) {
      return res.status(500).json({ success: false, error: 'Order update failed' });
    }
  },

  // 5. POST /api/merchant/menu  (ADMIN only)
  async addMenuItem(req: Request, res: Response) {
    try {
      const result = await MerchantService.addMenuItem(req.body);
      return res.status(201).json({ success: true, data: result });
    } catch (error) {
      return res.status(500).json({ success: false, error: 'Failed to add menu item' });
    }
  },

  // 6. PATCH /api/merchant/menu/:id  (ADMIN only)
  async updateMenuItem(req: Request, res: Response) {
    try {
      const result = await MerchantService.updateMenuItem(req.params.id, req.body);
      return res.status(200).json({ success: true, data: result });
    } catch (error) {
      return res.status(500).json({ success: false, error: 'Failed to update menu item' });
    }
  },

  // 7. DELETE /api/merchant/menu/:id  (ADMIN only)
  async deleteMenuItem(req: Request, res: Response) {
    try {
      await MerchantService.deleteMenuItem(req.params.id);
      return res.status(200).json({ success: true });
    } catch (error) {
      return res.status(500).json({ success: false, error: 'Failed to delete menu item' });
    }
  },

  // 8. GET /api/merchant/analytics/:cafeteriaId  (ADMIN only)
  async getAnalytics(req: Request, res: Response) {
    try {
      const data = await AnalyticsService.getCafeteriaAnalytics(req.params.cafeteriaId as string);
      return res.status(200).json({ success: true, data });
    } catch (error) {
      return res.status(500).json({ success: false, error: 'Failed to fetch analytics' });
    }
  },
};