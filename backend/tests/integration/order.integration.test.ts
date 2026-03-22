import { describe, it, expect} from "vitest";
import request from "supertest";
import { app } from "app.ts";
import { TestHelpers } from "../helpers/test-helpers.ts";
import { generateToken } from "utils/jwt.utils.ts";


describe("------- Order Endpoint Tests ---------", () => {
    //POST 
    describe("POST: ", () => {
        it("Should create order and return 201", async () => {
            const user = await TestHelpers.createUser(); 
            const token = await generateToken({ id: user.id, email: user.email, role: user.role });
            const {id} = await TestHelpers.createCafeteria(); 
            const menuItem1 = await TestHelpers.createMenuItem(id);
            const menuItem2 = await TestHelpers.createMenuItem(id, { name: "Wakye", price: 40.0 });
            const now = new Date() ; 
            const future = new Date( now.setDate(now.getDate() + 1) );
            // my order 
            const orderBody = {
                userId: user.id, 
                cafeteriaId: id,
                pickupWindow: future.toISOString(),
                items: [
                    { menuItemId: menuItem1.id, quantity: 1 },
                    { menuItemId: menuItem2.id, quantity: 2 }
                ],
            totalAmount: 2*(menuItem2.price) + menuItem1.price 
            };

            const response = await request(app)
                .post("/api/orders/order")
                .set('authorization', `Bearer ${token}`)
                .send(orderBody)

            expect(response.status).toBe(201); 
            expect(response.body).toHaveProperty('success',true)
        })
    });

    // GET 
     describe("GET: ", () => {
        it("Should fetch user order history and return 200", async () => {
            const user = await TestHelpers.createUser(); 
            const token = await generateToken({ id: user.id, email: user.email, role: user.role });
            const cafe = await TestHelpers.createCafeteria(`CAFE-${Math.random()}`);

            for(let i=0; i< 10; i++){
                 await TestHelpers.createOrder(cafe.id); 
            };

            const limit = 5;
            const page  = 1;        

            const response = await request(app)
                .get(`/api/orders/my-order-history`)
                .set('authorization', `Bearer ${token}`)
                .query({limit: limit, page: page})
            
            expect(response.status).toBe(200); 
            expect(response.body).toHaveProperty('success',true);
        })
    })
})

