import { prisma } from "../../src/lib/prisma.ts";
import { v4 as uuidv4 } from 'uuid';
import { CapacityStatus, OrderStatus, Role } from "../../prisma/generated/prisma/enums.ts";

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
    return await prisma.user.create({
      data: {
        email: `user-${uuidv4()}@ashesi.edu.gh`,
        name: "Daniel Kwasi",
        password: "secure_password",
        role: Role.CUSTOMER,
        ...overrides,
      },
    });
  },

  async createCafeteria(name = "Akornor", status = CapacityStatus.GREEN) {
    return await prisma.cafeteria.create({
      data: {
        name: `${name}-${uuidv4().substring(0, 4)}`, // Ensure uniqueness
        capacityStatus: status,
        isOpen: true,
      },
    });
  },


  async createMenuItem(cafeteriaId: string, overrides = {}) {
    return await prisma.menuItem.create({
      data: {
        name: "Jollof Rice",
        price: 15.0,
        category: "Lunch",
        isAvailable: true,
        cafeteriaId,
        ...overrides,
      },
    });
  },


  async createOrder(cafeteriaId: string, status = OrderStatus.PENDING_PAYMENT) {
    const user = await this.createUser();
    
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
              menuItemId: uuidv4(), // Mock ID or link to a real MenuItem
              name: "Jollof Rice",
              price: 15.0,
              quantity: 2,
            },
          ],
        },
      },
      include: {
        items: true,
      },
    });
  },
};