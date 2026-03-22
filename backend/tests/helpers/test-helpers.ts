import { prisma } from "../../src/lib/prisma.ts";
import { v4 as uuidv4 } from 'uuid';
import { CapacityStatus, OrderStatus, Role } from "../../prisma/generated/prisma/enums.ts";
import { hashPassword } from "utils/password.utils.ts";

export const TestHelpers = {
  async clearDatabase() {
    // Delete order items first, then orders, then the entities they depend on
    await prisma.orderItem.deleteMany();
    await prisma.order.deleteMany();
    await prisma.menuItem.deleteMany();
    await prisma.cafeteria.deleteMany();
    await prisma.user.deleteMany();
  },

 
  async createUser(overrides = {}) {
    const rawPwd = "rawpadwe24";
    const hPwd = await hashPassword(rawPwd);  
    const result =  await prisma.user.create({
      data: {
        email: `user-${uuidv4()}@ashesi.edu.gh`,
        name: "Daniel Kwasi",
        password: hPwd,
        role: Role.CUSTOMER,
        ...overrides,
      },
      select: {
        id: true,
        email: true,
        allergies: true,
        role: true,
       orders:true
      }
    });
    return {...result, rawPwd: rawPwd}
  },

  async createCafeteria(name = "Akornor", status = CapacityStatus.GREEN) {
    const user = await this.createUser(); 
    return await prisma.cafeteria.create({
      data: {
        name: `${name}-${uuidv4().substring(0, 4)}`, // Ensure uniqueness
        capacityStatus: status,
        isOpen: true,
        userId: user.id
      },
    });
  },


  async createMenuItem(cafeteriaId: string, overrides = {}) {
    return await prisma.menuItem.create({
      data: {
        name: "Jollof Rice & Chicken",
        price: 30.0,
        category: "Lunch",
        isAvailable: true,
        cafeteriaId,
        ...overrides,
      },
    });
  },


  async createOrder(cafeteriaId: string,  status = OrderStatus.PENDING_PAYMENT) {
    const user = await this.createUser();
    const menuItem1 = await this.createMenuItem(cafeteriaId, {name:"Joita Mono"}); 
    const menuItem2 = await this.createMenuItem(cafeteriaId, {name:'Jammy Rice'}); 
    
    return await prisma.order.create({
      data: {
        userId: user.id,
        cafeteriaId,
        totalAmount: 30.0,
        status,
        isPaid: false,
        pickupWindow: new Date(Date.now() + 3600000), // 1 hour from now
        qrCodeSecret: uuidv4(),
        items: {
          create: [
            {
              menuItemId: menuItem1.id, // Mock ID or link to a real MenuItem
              quantity: 2,
            },
            {
              menuItemId: menuItem2.id, // Mock ID or link to a real MenuItem
              quantity: 3,
            },
          ],
        },
      },
      select: {
        items: true,
        qrCodeSecret: true,
        id: true
      },
    });
  },

  async updateOrder(orderId: string, status: string, cafetariaId: string) {
    await prisma.order.update({
      where: { id: orderId, cafeteriaId: cafetariaId },
      data: {
        status: status as unknown as OrderStatus
      }
    })
  }
};