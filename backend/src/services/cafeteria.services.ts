import { emitUpdate } from "lib/socket.ts";
import { CapacityStatus, Role } from "../../prisma/generated/prisma/enums.ts";
import { createCafeteriaSchema } from "schema/cafetaria.schema.ts";
import { prisma } from "../lib/prisma.ts";
import { z } from 'zod'; 
import { can } from '../rbac/permissions.rbac.ts'


export const  CafeteriaService = {
    async getAllCafeterias() {
        return await prisma.cafeteria.findMany({
            select: {
                name: true,
                capacityStatus: true,
                isOpen: true,
            }
        });
    },

    async getMemu(id: string ) {
        return await prisma.cafeteria.findUnique({
            where: { id: id },
            select: {
                menuItems: true 
            }
        })
    },

    async createCafeteria(data: z.infer<typeof createCafeteriaSchema>) {
        return await prisma.cafeteria.create({
            data: {
               ...data
           }
        })
    }
}