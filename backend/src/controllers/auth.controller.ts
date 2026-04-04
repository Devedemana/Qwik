import { Request, Response } from 'express';
import { AuthService } from '../services/auth.service.ts';

export const AuthController = {
  async register(req: Request, res: Response) {
    try {
      const { name, email, password } = req.body;
      const result = await AuthService.register({ name, email, password });
      return res.status(201).json({ success: true, data: result });
    } catch (error: any) {
      const status = error.message === 'Email already registered' ? 409 : 500;
      return res.status(status).json({ success: false, error: error.message });
    }
  },

  async login(req: Request, res: Response) {
    try {
      const { email, password } = req.body;
      const result = await AuthService.login(email, password);
      return res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      const status = error.message === 'Invalid email or password' ? 401 : 500;
      return res.status(status).json({ success: false, error: error.message });
    }
  },
};
