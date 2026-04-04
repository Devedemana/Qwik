import { Router } from 'express';
import { CafeteriaController } from '../controllers/cafeteria.controller.ts';

const cafeteriaRouter = Router();

cafeteriaRouter.get('/', CafeteriaController.list);
cafeteriaRouter.get('/search', CafeteriaController.search);
cafeteriaRouter.get('/:id', CafeteriaController.getById);
cafeteriaRouter.get('/:id/menu', CafeteriaController.getMenu);

export default cafeteriaRouter;
