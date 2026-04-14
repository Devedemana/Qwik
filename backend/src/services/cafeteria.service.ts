import { prisma } from '../lib/index.ts';
import { getMealPeriod, getMealPeriodLabel } from '../lib/mealPeriod.ts';

export const CafeteriaService = {
  async listCafeterias() {
    const rows = await prisma.cafeteria.findMany({
      include: { _count: { select: { menuItems: true } } },
    });
    const period = getMealPeriod();
    const label = getMealPeriodLabel(period);
    return rows.map(r => ({ ...r, mealPeriod: period, mealPeriodLabel: label }));
  },

  async getCafeteriaById(id: string) {
    const cafeteria = await prisma.cafeteria.findUnique({
      where: { id },
      include: { menuItems: { where: { isAvailable: true } } },
    });
    if (!cafeteria) throw new Error('Cafeteria not found');
    const period = getMealPeriod();
    return { ...cafeteria, mealPeriod: period, mealPeriodLabel: getMealPeriodLabel(period) };
  },

  async getMenu(cafeteriaId: string, category?: string) {
    return prisma.menuItem.findMany({
      where: {
        cafeteriaId,
        ...(category ? { category } : {}),
      },
      orderBy: { category: 'asc' },
    });
  },

  async searchMenuItems(query: string) {
    return prisma.menuItem.findMany({
      where: {
        isAvailable: true,
        OR: [
          { name: { contains: query, mode: 'insensitive' } },
          { description: { contains: query, mode: 'insensitive' } },
          { category: { contains: query, mode: 'insensitive' } },
        ],
      },
      include: { cafeteria: { select: { id: true, name: true } } },
    });
  },
};
