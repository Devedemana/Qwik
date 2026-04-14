import { prisma } from '../lib/index.ts';

export const AnalyticsService = {
  async getCafeteriaAnalytics(cafeteriaId: string) {
    const [orders, menuItems] = await Promise.all([
      prisma.order.findMany({
        where: { cafeteriaId },
        include: { items: true },
        orderBy: { createdAt: 'desc' },
      }),
      prisma.menuItem.findMany({ where: { cafeteriaId } }),
    ]);

    // Total orders and revenue
    const totalOrders = orders.length;
    const totalRevenue = orders.reduce((s, o) => s + o.totalAmount, 0);
    const completedOrders = orders.filter((o) => o.status === 'COMPLETED').length;
    const cancelledOrders = orders.filter((o) => o.status === 'CANCELLED').length;

    // Orders by status
    const byStatus: Record<string, number> = {};
    for (const o of orders) {
      byStatus[o.status] = (byStatus[o.status] ?? 0) + 1;
    }

    // Orders by hour (peak time analysis)
    const byHour: Record<number, number> = {};
    for (const o of orders) {
      const hour = new Date(o.createdAt).getUTCHours();
      byHour[hour] = (byHour[hour] ?? 0) + 1;
    }
    const peakHour = Object.entries(byHour).sort((a, b) => b[1] - a[1])[0];

    // Orders by day (last 7 days)
    const now = new Date();
    const last7Days: { date: string; count: number; revenue: number }[] = [];
    for (let i = 6; i >= 0; i--) {
      const day = new Date(now);
      day.setUTCDate(day.getUTCDate() - i);
      const dateStr = day.toISOString().split('T')[0];
      const dayOrders = orders.filter(
        (o) => o.createdAt.toISOString().split('T')[0] === dateStr
      );
      last7Days.push({
        date: dateStr,
        count: dayOrders.length,
        revenue: dayOrders.reduce((s, o) => s + o.totalAmount, 0),
      });
    }

    // Top menu items by quantity ordered
    const itemCounts: Record<string, { name: string; count: number; revenue: number }> = {};
    for (const order of orders) {
      for (const item of order.items) {
        if (!itemCounts[item.menuItemId]) {
          itemCounts[item.menuItemId] = { name: item.name, count: 0, revenue: 0 };
        }
        itemCounts[item.menuItemId]!.count += item.quantity;
        itemCounts[item.menuItemId]!.revenue += item.price * item.quantity;
      }
    }
    const topItems = Object.values(itemCounts)
      .sort((a, b) => b.count - a.count)
      .slice(0, 5);

    // Average order value
    const avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;

    return {
      totalOrders,
      totalRevenue,
      completedOrders,
      cancelledOrders,
      avgOrderValue,
      byStatus,
      byHour,
      peakHour: peakHour ? { hour: Number(peakHour[0]), count: peakHour[1] } : null,
      last7Days,
      topItems,
      totalMenuItems: menuItems.length,
      unavailableItems: menuItems.filter((m) => !m.isAvailable).length,
    };
  },
};
