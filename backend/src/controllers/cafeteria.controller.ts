import { Request, Response } from 'express';
import { CafeteriaService } from '../services/cafeteria.service.ts';

export const CafeteriaController = {
  async list(_req: Request, res: Response) {
    try {
      const cafeterias = await CafeteriaService.listCafeterias();
      return res.status(200).json({ success: true, data: cafeterias });
    } catch (error: any) {
      return res.status(500).json({ success: false, error: error.message });
    }
  },

  async getById(req: Request, res: Response) {
    try {
      const cafeteria = await CafeteriaService.getCafeteriaById(req.params.id as string);
      return res.status(200).json({ success: true, data: cafeteria });
    } catch (error: any) {
      const status = error.message === 'Cafeteria not found' ? 404 : 500;
      return res.status(status).json({ success: false, error: error.message });
    }
  },

  async getMenu(req: Request, res: Response) {
    try {
      const category = req.query.category as string | undefined;
      const menu = await CafeteriaService.getMenu(req.params.id as string, category);
      return res.status(200).json({ success: true, data: menu });
    } catch (error: any) {
      return res.status(500).json({ success: false, error: error.message });
    }
  },

  async search(req: Request, res: Response) {
    try {
      const query = req.query.q as string;
      if (!query) {
        return res.status(400).json({ success: false, error: 'Search query is required' });
      }
      const results = await CafeteriaService.searchMenuItems(query);
      return res.status(200).json({ success: true, data: results });
    } catch (error: any) {
      return res.status(500).json({ success: false, error: error.message });
    }
  },
};
