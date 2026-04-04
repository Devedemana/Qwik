import { Router } from "express";
import { MerchantController } from "../controllers/merchant.controller.ts";
import {
  MerchantStatusSchema,
  InventoryUpdateSchema,
  CafeteriaIdParamSchema,
  OrderIdParamSchema,
  AdvanceOrderBodySchema,
  CreateMenuItemSchema,
  UpdateMenuItemSchema,
  MenuItemIdParamSchema,
} from "../schema/merchant.schema.ts";
import { validateBody, validateParams } from "../middlewares/validate.middleware.ts";
import { authenticate, requireRole } from "../middlewares/auth.middleware.ts";

const merchantRouter = Router();

merchantRouter.use(authenticate, requireRole('STAFF', 'ADMIN'));

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


// Admin-only menu management
merchantRouter.post(
  "/menu",
  requireRole('ADMIN'),
  validateBody(CreateMenuItemSchema),
  MerchantController.addMenuItem,
);

merchantRouter.patch(
  "/menu/:id",
  requireRole('ADMIN'),
  validateParams(MenuItemIdParamSchema),
  validateBody(UpdateMenuItemSchema),
  MerchantController.updateMenuItem,
);

merchantRouter.delete(
  "/menu/:id",
  requireRole('ADMIN'),
  validateParams(MenuItemIdParamSchema),
  MerchantController.deleteMenuItem,
);

export default merchantRouter;
