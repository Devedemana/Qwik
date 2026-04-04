import { Router } from 'express';
import { UserController } from '../controllers/user.controller.ts';
import { authenticate } from '../middlewares/auth.middleware.ts';
import { validateBody } from '../middlewares/validate.middleware.ts';
import { UpdatePreferencesSchema } from '../schema/user.schema.ts';

const userRouter = Router();

userRouter.use(authenticate);

userRouter.get('/profile', UserController.getProfile);
userRouter.patch('/profile', UserController.updateProfile);
userRouter.patch('/preferences', validateBody(UpdatePreferencesSchema), UserController.updatePreferences);

export default userRouter;
