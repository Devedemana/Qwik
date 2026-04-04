import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware.ts';
import { UserService } from '../services/user.service.ts';

export const UserController = {
  async getProfile(req: AuthRequest, res: Response) {
    try {
      const profile = await UserService.getProfile(req.user!.id);
      return res.status(200).json({ success: true, data: profile });
    } catch (error: any) {
      return res.status(500).json({ success: false, error: error.message });
    }
  },

  async updateProfile(req: AuthRequest, res: Response) {
    try {
      const { name } = req.body;
      const user = await UserService.updateProfile(req.user!.id, { name });
      return res.status(200).json({ success: true, data: user });
    } catch (error: any) {
      return res.status(500).json({ success: false, error: error.message });
    }
  },

  async updatePreferences(req: AuthRequest, res: Response) {
    try {
      const { dietaryLifestyle, allergies } = req.body;
      const user = await UserService.updatePreferences(req.user!.id, { dietaryLifestyle, allergies });
      return res.status(200).json({ success: true, data: user });
    } catch (error: any) {
      return res.status(500).json({ success: false, error: error.message });
    }
  },
};
