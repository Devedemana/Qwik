import type { Request, Response } from 'express';
import {CafeteriaService} from '../services/cafeteria.services.ts'
import { can } from '../rbac/permissions.rbac.ts'


export const CafeteriaController = {
    async getCafeterais(req: Request, res: Response) {
        try {
            const activeCafeterias = await CafeteriaService.getAllCafeterias();
            return res.status(200).json({
                success: true,
                data: activeCafeterias
            })
        } catch (err) {
            return res.status(500).json({
                error: 'error',
                message: err.message
            })
        }
    },

    async getMenu(req: Request, res: Response) {
        try {
            const { id } = req.params;
            const menuItems = await CafeteriaService.getMemu(id);
            return res.status(200).json({
                success: true,
                data: menuItems
            })
        } catch (err) {
            return res.status(500).json({
                error: 'error',
                message: err.message
            });
        }
    },
    async createCafeteria(req: Request, res: Response) {
        try {
            const { ...name } = req.body
            const newCafetaria = await CafeteriaService.createCafeteria(name);
            return res.status(201).json({
                success: true,
                data: newCafetaria
            })
        } catch (err) {
            return res.status(500).json({
                error: 'error',
                message: err.message
            });
        }
    },
};