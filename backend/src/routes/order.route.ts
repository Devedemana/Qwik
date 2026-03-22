import { Router } from "express";
import { authenticateToken, authorize } from "middlewares/auth.middleware.ts";
import { validateBody, validateQuery } from "middlewares/validate.middleware.ts";
import { createOrderSchema , OrderHistorySchema} from "schema/order.schema.ts";
import {OrderController} from '../controllers/order.controller.ts'

const orderRouter = Router();

orderRouter.get('/my-order-history',authenticateToken, validateQuery(OrderHistorySchema), OrderController.getHistory)
orderRouter.post('/order', authenticateToken, validateBody(createOrderSchema), OrderController.createOrder); 


export default orderRouter; 
