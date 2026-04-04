import { Router } from 'express';
import { SpecialController } from '../controllers/special.controller.ts';
import { authenticate, requireRole } from '../middlewares/auth.middleware.ts';

const specialRouter = Router();

// Public — any logged-in user can view active specials
specialRouter.get('/', authenticate, SpecialController.listActive);

// ADMIN only
specialRouter.get('/all', authenticate, requireRole('ADMIN'), SpecialController.listAll);
specialRouter.post('/', authenticate, requireRole('ADMIN'), SpecialController.create);
specialRouter.patch('/:id', authenticate, requireRole('ADMIN'), SpecialController.update);
specialRouter.delete('/:id', authenticate, requireRole('ADMIN'), SpecialController.delete);

export default specialRouter;
