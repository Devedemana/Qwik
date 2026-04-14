import { Router } from 'express';
import { OrderController } from '../controllers/order.controller.ts';
import { authenticate } from '../middlewares/auth.middleware.ts';
import { validateBody, validateParams } from '../middlewares/validate.middleware.ts';
import { CreateOrderBodySchema, OrderIdParamSchema } from '../schema/order.schema.ts';

const orderRouter = Router();

orderRouter.use(authenticate);

orderRouter.post('/', validateBody(CreateOrderBodySchema), OrderController.create);
orderRouter.get('/', OrderController.list);
orderRouter.get('/:id', validateParams(OrderIdParamSchema), OrderController.getById);
orderRouter.patch('/:id/cancel', validateParams(OrderIdParamSchema), OrderController.cancel);
orderRouter.patch('/:id/pay', validateParams(OrderIdParamSchema), OrderController.markPaid);

export default orderRouter;
