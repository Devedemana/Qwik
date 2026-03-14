import { Router } from "express";
import { MerchantController } from "../controllers/merchant.controller.ts";
import {
  MerchantStatusSchema,
  InventoryUpdateSchema,
  CafeteriaIdParamSchema,
  OrderIdParamSchema,
  AdvanceOrderBodySchema,
} from "../schema/merchant.schema.ts";
import { validateBody, validateParams } from "middlewares/validate.middleware.ts";

const merchantRouter = Router();

// Endpoint: PATCH /api/merchant/status
merchantRouter.patch(
  "/status",
  validateBody(MerchantStatusSchema),
  MerchantController.updateStatus,
);

merchantRouter.put(
  "/inventory",
  validateBody(InventoryUpdateSchema),
  MerchantController.toggleInventory,
);

merchantRouter.get(
  "/orders/:cafeteriaId",
  validateParams(CafeteriaIdParamSchema),
  MerchantController.getQueue,
);

merchantRouter.patch(
  "/orders/:id",
  validateParams(OrderIdParamSchema),
  validateBody(AdvanceOrderBodySchema),
  MerchantController.advanceOrder,
);



export default merchantRouter;
