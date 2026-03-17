import type { Request, Response, NextFunction } from 'express'
import { can, Permission } from 'rbac/permissions.rbac.ts';
import { verifyToken} from 'utils/jwt.utils.ts';

 


export const authenticateToken = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(" ")[1];

        if (!token) {
            return res.status(401).json({ message: 'Access Denied: No token provided' });
        }
        const payload  = await verifyToken(token) ; 
        if (!payload) {
            return res.status(403).json({ message: 'Invalid or expired token' })
        };
        
        req.user = payload; 
    
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

export function  authorize(permission: Permission){
    return (req: Request, res: Response, next: NextFunction) => {
        const user = req.user;
        // permission 
        if (!user || !can(user, permission)) {
            return res.status(403).json({
                error: 'Unauthorized',
                message: `You do not have permission to perform action : ${permission}`
            });
        }

        // next : if nothing goes wrong 
        next();
    }
}