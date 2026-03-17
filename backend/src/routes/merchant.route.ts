import { Router } from "express";
import { MerchantController } from "../controllers/merchant.controller.ts";
import {MerchantStatusSchema,InventoryUpdateSchema,CafeteriaIdParamSchema,OrderIdParamSchema,AdvanceOrderBodySchema,
VerifyPickupSchema,
} from "../schema/merchant.schema.ts";
import { validateBody, validateParams} from "middlewares/validate.middleware.ts";
import { CafeteriaAvailabilitySchema } from "schema/cafetaria.schema.ts";

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

merchantRouter.post(
  "/order/verify",
  validateBody(VerifyPickupSchema),
  MerchantController.verifyOrderPickup,
);

merchantRouter.patch("/toggle-gate", validateBody(CafeteriaAvailabilitySchema), MerchantController.toggleCafeteriaAvailability);


export default merchantRouter;
