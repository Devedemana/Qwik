import { describe, it, expect } from "vitest";
import request from "supertest";
import { app } from "app.ts";

describe("------- Merchant Endpoint Tests ---------", () => {
  // gets/fetches
  describe("GET - Retrievals endpoint ", () => {
    it("GET /api/merchant/orders/:id -> should fetch active kitchen orders", async () => {
      const res = await request(app).get("/api/merchant/orders/cafe_abc");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  // updates
  describe("PATCH/PUT - Update toggling endpoint", () => {
    it("should update cafetaria queue status and return 200", async () => {
      // create test cafetaria 
      const response = await request(app).patch("/api/merchant/status").send({
        cafeteriaId: "some-valid-id",
        status: "YELLOW",
      });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.capacityStatus).toBe("YELLOW");
    });

    it("PUT /api/merchant/inventory -> should toggle menu item availability", async () => {
      const payload = {
        itemId: "item_123",
        isAvailable: false,
      };

      const res = await request(app)
        .put("/api/merchant/inventory")
        .send(payload);

      expect(res.status).toBe(200);
      expect(res.body.data.isAvailable).toBe(false);
    });

    it("PATCH /api/merchant/orders/:id -> should move order to READY", async () => {
      const orderId = "65f823..."; // Use a seeded ID from your DB

      const res = await request(app)
        .patch(`/api/merchant/orders/${orderId}`)
        .send({ status: "READY" });

      expect(res.status).toBe(200);
      expect(res.body.data.status).toBe("READY");
    });
  });
});
