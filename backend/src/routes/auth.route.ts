import { Router } from 'express';
import rateLimit from 'express-rate-limit';
import { AuthController } from '../controllers/auth.controller.ts';
import { validateBody } from '../middlewares/validate.middleware.ts';
import { LoginSchema, RegisterSchema } from '../schema/auth.schema.ts';

const authRouter = Router();

// Max 10 login attempts per IP per 15 minutes
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message: { success: false, error: 'Too many login attempts. Please try again in 15 minutes.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Max 5 registrations per IP per hour
const registerLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 5,
  message: { success: false, error: 'Too many accounts created from this IP. Please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

authRouter.post('/register', registerLimiter, validateBody(RegisterSchema), AuthController.register);
authRouter.post('/login', loginLimiter, validateBody(LoginSchema), AuthController.login);

export default authRouter;
