import { prisma } from "../lib/index.ts";
import { emitUpdate } from "lib/socket.ts";
import { OrderStatus } from "../../prisma/generated/prisma/enums.ts";

export const MerchantService = {
  async updateCafeteriaStatus(cafeteriaId: string, status: string) {
    const updatedCafeteria = await prisma.cafetaria.update({
      where: { id: cafeteriaId },
      data: { capacityStatus: status },
    });
    emitUpdate(`cafeteria:${cafeteriaId}`, "status_changed", {
      cafeteriaId,
      status,
    });

    return updatedCafeteria;
  },

  async updateItemAvailability(id: string, isAvailable: boolean) {
    const item = await prisma.menuItem.update({
      where: { id },
      data: { isAvailable },
    });

    // Notify all customer: in room
    emitUpdate(`cafeteria:${item.cafeteriaId}`, "inventory_updated", {
      itemId: id,
      isAvailable,
    });

    return item;
  },

  // Order queue
  async fetchActiveOrders(cafeteriaId: string) {
    return await prisma.order.findMany({
      where: {
        cafeteriaId,
        status: { in: ["PAID", "PREPPING", "READY"] },
      },
      orderBy: { createdAt: "asc" },
    });
  },

  // Order State Transitions
  async updateOrderStatus(
    orderId: string,
    nextStatus:OrderStatus,
  ) {
    const currentOrder = await prisma.order.findUnique({ where: { id: orderId } });
    this.validateTransition(currentOrder?.status, nextStatus);
    const updated = await prisma.order.update({
      where: { id: orderId },
      data: { status: nextStatus }
    });

    emitUpdate(`order:${orderId}`, 'order_status_update', { status: nextStatus });
    return updated;
  },
  

  // 1. Pure Logic for Staff Discount
  calculateStaffPrice(price: number): number {
    const DISCOUNT_RATE = 0.20; // 20%
    return price * (1 - DISCOUNT_RATE);
  },

  // 2. State Machine Validation
  validateTransition(current: string, next: string): void {
    if (current === 'COMPLETED' && next === 'PREPPING') {
      throw new Error('Cannot move a completed order back to prepping');
    }
    // Add other rules here as needed
  }
};
