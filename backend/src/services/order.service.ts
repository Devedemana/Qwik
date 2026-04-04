import { randomUUID } from 'crypto';
import { prisma } from '../lib/index.ts';
import { emitUpdate } from '../lib/socket.ts';
import { isValidPickupWindow, getMealPeriodLabel, getMealPeriod } from '../lib/mealPeriod.ts';

interface CreateOrderInput {
  userId: string;
  cafeteriaId: string;
  pickupWindow: string;
  items: { menuItemId: string; quantity: number }[];
}

export const OrderService = {
  async createOrder(input: CreateOrderInput) {
    // Validate pickup window is within operating hours
    const pickupDate = new Date(input.pickupWindow);
    if (!isValidPickupWindow(pickupDate)) {
      const period = getMealPeriod();
      throw new Error(
        period === 'CLOSED'
          ? 'Cafeteria is closed. Operating hours: Breakfast 8–10am, Lunch & Dinner 10am–8pm.'
          : `Pickup window must be within the current meal period (${getMealPeriodLabel(period)}).`
      );
    }

    // Fetch menu items to get prices and names
    const menuItems = await prisma.menuItem.findMany({
      where: { id: { in: input.items.map((i) => i.menuItemId) } },
    });

    if (menuItems.length !== input.items.length) {
      throw new Error('One or more menu items not found');
    }

    const unavailable = menuItems.filter((m) => !m.isAvailable);
    if (unavailable.length > 0) {
      throw new Error(`Unavailable items: ${unavailable.map((m) => m.name).join(', ')}`);
    }

    // Build order items with prices
    const orderItems = input.items.map((item) => {
      const menu = menuItems.find((m) => m.id === item.menuItemId)!;
      return {
        menuItemId: item.menuItemId,
        name: menu.name,
        price: menu.price,
        quantity: item.quantity,
      };
    });

    const totalAmount = orderItems.reduce((sum, i) => sum + i.price * i.quantity, 0);

    const order = await prisma.order.create({
      data: {
        userId: input.userId,
        cafeteriaId: input.cafeteriaId,
        totalAmount,
        pickupWindow: new Date(input.pickupWindow),
        qrCodeSecret: randomUUID(),
        items: { create: orderItems },
      },
      include: { items: true },
    });

    emitUpdate(`cafeteria:${input.cafeteriaId}`, 'new_order', { orderId: order.id });

    return order;
  },

  async getUserOrders(userId: string) {
    return prisma.order.findMany({
      where: { userId },
      include: { items: true, cafeteria: true },
      orderBy: { createdAt: 'desc' },
    });
  },

  async getOrderById(orderId: string, userId: string) {
    const order = await prisma.order.findUnique({
      where: { id: orderId },
      include: { items: true, cafeteria: true },
    });

    if (!order || order.userId !== userId) {
      throw new Error('Order not found');
    }

    return order;
  },

  async cancelOrder(orderId: string, userId: string) {
    const order = await prisma.order.findUnique({ where: { id: orderId } });

    if (!order || order.userId !== userId) {
      throw new Error('Order not found');
    }

    if (!['PENDING_PAYMENT', 'RECEIVED'].includes(order.status)) {
      throw new Error('Order cannot be cancelled at this stage');
    }

    const updated = await prisma.order.update({
      where: { id: orderId },
      data: { status: 'CANCELLED' },
      include: { items: true },
    });

    emitUpdate(`cafeteria:${order.cafeteriaId}`, 'order_status_update', {
      orderId,
      status: 'CANCELLED',
    });

    return updated;
  },

  async markPaid(orderId: string) {
    const order = await prisma.order.findUnique({ where: { id: orderId } });
    if (!order) throw new Error('Order not found');
    if (order.status !== 'PENDING_PAYMENT') throw new Error('Order is not pending payment');

    const updated = await prisma.order.update({
      where: { id: orderId },
      data: { status: 'RECEIVED', isPaid: true },
      include: { items: true },
    });

    emitUpdate(`cafeteria:${order.cafeteriaId}`, 'order_status_update', {
      orderId,
      status: 'RECEIVED',
    });

    return updated;
  },
};
