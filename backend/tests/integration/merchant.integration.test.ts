import { describe, it, expect} from "vitest";
import request from "supertest";
import { app } from "app.ts";
import { TestHelpers } from "../helpers/test-helpers.ts";

describe("------- Merchant Endpoint Tests ---------", () => {
  describe("PATCH /api/merchant/status", () => {
    it("should update cafeteria queue status and return 200", async () => {
      // Setup using helper
      const cafe = await TestHelpers.createCafeteria();

      const response = await request(app)
        .patch("/api/merchant/status")
        .send({
          cafeteriaId: cafe.id,
          status: "YELLOW",
        });
      
      expect(response.status).toBe(200);
      expect(response.body.data.capacityStatus).toBe("YELLOW");
    });
  });

  describe("PUT /api/merchant/inventory", () => {
    it("should toggle menu item availability", async () => {
      // Setup using helpers
      const cafe = await TestHelpers.createCafeteria();
      const item = await TestHelpers.createMenuItem(cafe.id);

      const res = await request(app)
        .put("/api/merchant/inventory")
        .send({
          itemId: item.id,
          isAvailable: false,
        });

      expect(res.status).toBe(200);
      expect(res.body.data.isAvailable).toBe(false);
    });
  });

  describe("PATCH /api/merchant/orders/:id", () => {
    it("should move order to READY", async () => {
      // Setup using helpers
      const cafe = await TestHelpers.createCafeteria();
      const order = await TestHelpers.createOrder(cafe.id);

      const res = await request(app)
        .patch(`/api/merchant/orders/${order.id}`)
        .send({ status: "READY" });

      expect(res.status).toBe(200);
      expect(res.body.data.status).toBe("READY");
    });
  });
});