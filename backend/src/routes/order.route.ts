import { Router } from "express";
import { authenticateToken, authorize } from "middlewares/auth.middleware.ts";
import { validateBody } from "middlewares/validate.middleware.ts";
import { createOrderSchema } from "schema/order.schema.ts";
import {OrderController} from '../controllers/order.controller.ts'

const orderRouter = Router();


orderRouter.post('/order', authenticateToken, authorize, validateBody(createOrderSchema), OrderController.createOrder); 



export default orderRouter; 
