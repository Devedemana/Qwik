import request from "supertest";
import { app } from "app.ts";
import { TestHelpers } from "../helpers/test-helpers.ts";
import { describe, it, expect } from 'vitest';
import { generateToken } from "utils/jwt.utils.ts";


describe("------- Cafeteria Endpoint Tests ---------", () => {
    describe('GET: ', () => {
        it("should gate all cafetarias and return 200", async () => {
            const cafe1 = await TestHelpers.createCafeteria();
            const cafe2 = await TestHelpers.createCafeteria(); 
            const cafe3 = await TestHelpers.createCafeteria(); 
      
            const response = await request(app)
                .get("/api/cafeterias");
            
            expect(response.status).toBe(200);
            expect(response.body).toHaveProperty('data')
        });

        it("should get menuItems for a  specific cafetaria & return 200", async () => {
            const cafe1 = await TestHelpers.createCafeteria();
            const cafe2 = await TestHelpers.createCafeteria();
            const cafe3 = await TestHelpers.createCafeteria();
            const response = await request(app)
                .get(`/api/cafeterias/${cafe1.id}/menu `);
        
            expect(response.status).toBe(200);
            expect(response.body).toHaveProperty('data')
        });
    });

    describe("POST: ", () => {
        it("Should create cafeteria and return 201", async () => {
            const user =await  TestHelpers.createUser({ role: "ADMIN" });
            const token = await generateToken({ id: user.id, email: user.email, role: user.role });
            console.log("USER ROLE: ", user.role)
            const response = await request(app)
                .post('/api/cafeterias/cafeteria')
                .set('authorization', `Bear ${token}`)
                .send({ name: 'Dann-Milo', userId: user.id, isOpen:true })
            
            console.log('RESULT: ', response.body)
            
            expect(response.status).toBe(201);
        })
    })
})