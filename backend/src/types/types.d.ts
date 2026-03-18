import { TokenPayload } from "utils/jwt.utils.ts"

declare global{
    namespace Express {
        interface Request {
            user?: TokenPayload,
             
        }
    }
}