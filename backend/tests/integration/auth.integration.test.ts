import { describe, it, expect} from "vitest";
import request from "supertest";
import { app } from "app.ts";
import { TestHelpers } from "../helpers/test-helpers.ts";

describe("------- Auth Endpoint Tests ---------", () => {
    describe('POST: ', () => {
        it("should create user and return 200", async () => {
            const user = {
                name: "sample-name",
                email: "asome@ashesi.edu.gh",
                password: 'oeodkdoroeow',
                role: 'CUSTOMER',
                cardId: '82272026'
            }
            const response = await request(app)
                .post("/api/auth/register")
                .send(user);
            
            expect(response.status).toBe(201);
            expect(response.body).toHaveProperty('data')
            expect(response.body).toHaveProperty('token')
        });

        it("should login user and return 200", async () => {
            const {email, rawPwd} = await TestHelpers.createUser(); 
            const response = await request(app)
                .post("/api/auth/login")
                .send({email: email, password: rawPwd});
            expect(response.status).toBe(200);
            expect(response.body).toHaveProperty('message', 'user login succussfully')
            expect(response.body).toHaveProperty('token')

        });
    });
});