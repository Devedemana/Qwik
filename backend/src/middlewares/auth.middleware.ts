import { verifyToken , type JWT_Payload} from "../utils/jwt.ts";
import type { Request, Response, NextFunction } from 'express'


export const authenticateToken = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(" ")[1];

        if (!token) {
            return res.status(401).json({ message: 'Access Denied: No token provided' });
        }
        const { payload } = await verifyToken(token) ?? {}; // returns {payload: {}}
        if (!payload ||!payload.id) {
            return res.status(403).json({ message: 'Invalid or expired token' })
        }
        const { id, username, email } = payload;
        
        if (!id || !username) {
            return res.status(403).json({ message: 'Invalid or expired token' });
        }
        req.user = { 
            id: id, 
            username: username, 
            email: email 
        };
    
        //next middleware or function
        next();
    } catch (err) {
        console.error("Auth Error:", err); // Log for debugging on your server
        return res.status(500).json({
            error: 'Authentication Error',
            message: 'Internal server error during authentication'
        });
    }
}