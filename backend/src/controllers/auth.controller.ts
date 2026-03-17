import type { Request, Response } from 'express';
import { AuthService } from 'services/auth.services.ts';
import { generateToken } from 'utils/jwt.utils.ts';

export const AuthController = {
    async register(req: Request, res: Response){
        try {
            const {...userDetails } = req.body; 
            const newUser = await AuthService.registerUser(userDetails);
            const token = await generateToken({ role: newUser.role, id: newUser.id, email: newUser.email });
            return res.status(201).json({
                success: true,
                message: 'user created succussfully',
                data: newUser,
                token: token
            });
        } catch (err) {
            return res.status(400).json({
                error: 'error',
                message:err.message
            })
        }
    },
        
     async login(req: Request, res: Response){
        try {
            const { ...loginData } = req.body; 
            const isValidUser = await AuthService.isValidUser(loginData);
            if (!isValidUser) {
                return res.status(400).json({
                    error: 'error',
                    message: 'Invalid Credentials'
                });
            };
            const token = await generateToken({ role: loginData.role, id: loginData.id, email: loginData.email });
            return res.status(200).json({
                success: true,
                message: 'user login succussfully',
                token: token 
            })
        } catch (err) {
            return res.status(err.status).json({
                error: 'error',
                message:err.message
            })
        }
    },
        
};