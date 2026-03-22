import { describe, it, expect} from "vitest";
import request from "supertest";
import { app } from "app.ts";
import { TestHelpers } from "../helpers/test-helpers.ts";




describe("------- Merchant Endpoint Tests ---------", () => {
  describe('POST: ', () => {
    it("should verify pickup order and return 200", async () => {
      const cafe = await TestHelpers.createCafeteria();
      const order = await TestHelpers.createOrder(cafe.id);
      const status = 'READY';
      await TestHelpers.updateOrder(order.id, status, cafe.id);
      
      const response = await request(app)
        .post("/api/merchant/order/verify")
        .send({ qrCodeSecret: order.qrCodeSecret, cafeteriaId: cafe.id });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('data')
    });
  });

  describe("PATCH/PUT", () => {
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

    it("should update cafetaria open status and return 200", async () => {
       // Setup using helpers
      const cafe = await TestHelpers.createCafeteria();
      const isOpen = false; 
      const res = await request(app)
        .patch(`/api/merchant/toggle-gate`)
        .send({ isOpen: isOpen, cafeteriaId: cafe.id });

      expect(res.status).toBe(200);
    })

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
});