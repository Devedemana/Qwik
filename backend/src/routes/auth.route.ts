import { AuthController } from "controllers/auth.controller.ts";
import { Router } from "express";
import { validateBody } from "middlewares/validate.middleware.ts";
import { loginSchema, registerSchema } from "schema/auth.schema.ts";


const authRouter = Router();

authRouter.post('/register', validateBody(registerSchema), AuthController.register);
authRouter.post('/login', validateBody(loginSchema), AuthController.login)


export default authRouter; 