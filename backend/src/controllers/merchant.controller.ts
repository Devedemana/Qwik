import { Request, Response } from 'express';
import { MerchantService } from '../services/merchant.services.ts';
import { verify } from 'node:crypto';
import { success } from 'zod';
import { error } from 'node:console';
import { RecordWithTtl } from 'node:dns';

export const MerchantController = {
  // PATCH /api/merchant/status
  async updateStatus(req: Request, res: Response) {
    try {
      const { cafeteriaId, status } = req.body;
      const result = await MerchantService.updateCafeteriaStatus(cafeteriaId, status);
      
      return res.status(200).json({ success: true, data: result });
    } catch (error) {
      return res.status(500).json({
        success: false,
        error: 'Status update failed',
        detail: error.message
      });
    }
  },

  // PUT /api/merchant/inventory
  async toggleInventory(req: Request, res: Response) {
    try {
      const { itemId, isAvailable } = req.body;
      const result = await MerchantService.updateItemAvailability(itemId, isAvailable);
      
      return res.status(200).json({ success: true, data: result });
    } catch (error) {
      return res.status(500).json({ success: false, error: 'Inventory update failed' });
    }
  },

  // GET /api/merchant/orders/:cafeteriaId
  async getQueue(req: Request, res: Response) {
    try {
      const { cafeteriaId } = req.params;
      const result = await MerchantService.fetchActiveOrders(cafeteriaId);
      
      return res.status(200).json({ success: true, data: result });
    } catch (error) {
      return res.status(500).json({ success: false, error: 'Failed to fetch queue' });
    }
  },

  // PATCH /api/merchant/orders/:id
  async advanceOrder(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { status } = req.body; // New status (e.g., READY)
      const result = await MerchantService.updateOrderStatus(id, status);
      
      return res.status(200).json({ success: true, data: result });
    } catch (error) {
      return res.status(500).json({ success: false, error: 'Order update failed' });
    }
  },

  // POST / ap/merchant/order/verify
  async verifyOrderPickup(req: Request, res: Response) {
    try {
      const { qrCodeSecret, cafeteriaId } = req.body; 
      const result = await MerchantService.verifyOrderPickup(qrCodeSecret, cafeteriaId);
      return res.status(200).json({ 
        success: true,
        data: result,
        message:'Order completed successfully '
      })
      
    } catch (err) {
      return res.status(500).json({ success: false, error:err.message});

    }
  },

  async toggleCafeteriaAvailability(req: Request, res: Response) {
    try {
      const { isOpen, cafeteriaId } = req.body; 
      const result = await MerchantService.toggleCafeteriaAvailability(cafeteriaId, isOpen); 
      return res.status(200).json({ success: true, data: result });

    } catch (err) {
      return res.status(500).json({ success: false, error: err.message});

    }
  }
};