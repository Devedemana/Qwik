import { Request, Response } from 'express';
import { SpecialService } from '../services/special.service.ts';
import { AuthRequest } from '../middlewares/auth.middleware.ts';

export const SpecialController = {
  async listActive(_req: Request, res: Response) {
    try {
      const data = await SpecialService.listActive();
      return res.status(200).json({ success: true, data });
    } catch (error: any) {
      return res.status(500).json({ success: false, error: error.message });
    }
  },

  async listAll(_req: AuthRequest, res: Response) {
    try {
      const data = await SpecialService.listAll();
      return res.status(200).json({ success: true, data });
    } catch (error: any) {
      return res.status(500).json({ success: false, error: error.message });
    }
  },

  async create(req: AuthRequest, res: Response) {
    try {
      const special = await SpecialService.create(req.body);
      return res.status(201).json({ success: true, data: special });
    } catch (error: any) {
      return res.status(400).json({ success: false, error: error.message });
    }
  },

  async update(req: AuthRequest, res: Response) {
    try {
      const special = await SpecialService.update(req.params.id, req.body);
      return res.status(200).json({ success: true, data: special });
    } catch (error: any) {
      return res.status(400).json({ success: false, error: error.message });
    }
  },

  async delete(req: AuthRequest, res: Response) {
    try {
      await SpecialService.delete(req.params.id);
      return res.status(200).json({ success: true });
    } catch (error: any) {
      return res.status(400).json({ success: false, error: error.message });
    }
  },
};
