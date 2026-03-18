import { describe, it, expect} from "vitest";
import request from "supertest";
import { app } from "app.ts";
import { TestHelpers } from "../helpers/test-helpers.ts";
import { generateToken } from "utils/jwt.utils.ts";


describe("------- Order Endpoint Tests ---------", () => {
    describe("POST: ", () => {
        it("Should create order and return 201", async () => {
            const user = await TestHelpers.createUser(); 
            const token = await generateToken({ id: user.id, email: user.email, role: user.role });
            const {id} = await TestHelpers.createCafeteria(); 
            const menuItem1 = await TestHelpers.createMenuItem(id);
            const menuItem2 = await TestHelpers.createMenuItem(id, { name: "Wakye", price: 40.0 });
            // my order 
            const orderBody = {
                cafeteriaId: id,
                pickupWindow: `${Date.now() + 1}`,
                items: [
                    { menuItemId: menuItem1.id, quantity: 1 },
                    { menuItemId: menuItem2.id, quantity: 2 }
                ],
            totalAmount: 30 + 80 
            };

            const response = await request(app)
                .post("/api/orders/order")
                .set('authorization', `Bearer ${token}`)
                .send(orderBody)
                .expect(201)
            
            expect(response.body).toHaveProperty('success',true)
        })
    })
})
