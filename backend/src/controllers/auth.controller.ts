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

  async forgotPassword(req: Request, res: Response) {
    try {
      const { email } = req.body;
      await AuthService.forgotPassword(email);
      // Always return 200 to prevent email enumeration
      return res.status(200).json({ success: true, message: 'If that email exists, a reset code was sent.' });
    } catch (error: any) {
      return res.status(500).json({ success: false, error: error.message });
    }
  },

  async resetPassword(req: Request, res: Response) {
    try {
      const { email, otp, newPassword } = req.body;
      await AuthService.resetPassword(email, otp, newPassword);
      return res.status(200).json({ success: true, message: 'Password updated.' });
    } catch (error: any) {
      const status = error.message === 'Invalid or expired code' ? 400 : 500;
      return res.status(status).json({ success: false, error: error.message });
    }
  },
};
