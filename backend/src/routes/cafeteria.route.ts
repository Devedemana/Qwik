import { Router } from "express";
import { validateBody, validateParams } from "middlewares/validate.middleware.ts";
import { authenticateToken, authorize } from "middlewares/auth.middleware.ts";
import { CafeteriaController } from "controllers/cafeteria.controller.ts";
import { cafeteriaIdSchema, createCafeteriaSchema } from "schema/cafetaria.schema.ts";


const cafeteriaRouter = Router();

cafeteriaRouter.get('/', CafeteriaController.getCafeterais);
cafeteriaRouter.get('/:id/menu', validateParams(cafeteriaIdSchema), CafeteriaController.getMenu);
cafeteriaRouter.post(
    '/cafeteria', authenticateToken, authorize("cafeteria:create"),
    validateBody(createCafeteriaSchema),

    CafeteriaController.createCafeteria
)


export default cafeteriaRouter; 