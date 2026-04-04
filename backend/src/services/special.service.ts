import { prisma } from '../lib/index.ts';

export const SpecialService = {
  /** List all currently active specials (endDate >= now) */
  async listActive() {
    const now = new Date();
    return prisma.special.findMany({
      where: { isActive: true, endDate: { gte: now } },
      orderBy: { startDate: 'asc' },
    });
  },

  async listAll() {
    return prisma.special.findMany({ orderBy: { startDate: 'desc' } });
  },

  async create(data: {
    tag: string; title: string; subtitle: string;
    imageUrl: string; startDate: string; endDate: string; isActive?: boolean;
  }) {
    return prisma.special.create({
      data: {
        tag: data.tag,
        title: data.title,
        subtitle: data.subtitle,
        imageUrl: data.imageUrl,
        startDate: new Date(data.startDate),
        endDate: new Date(data.endDate),
        isActive: data.isActive ?? true,
      },
    });
  },

  async update(id: string, data: Partial<{
    tag: string; title: string; subtitle: string;
    imageUrl: string; startDate: string; endDate: string; isActive: boolean;
  }>) {
    return prisma.special.update({
      where: { id },
      data: {
        ...data,
        ...(data.startDate ? { startDate: new Date(data.startDate) } : {}),
        ...(data.endDate ? { endDate: new Date(data.endDate) } : {}),
      },
    });
  },

  async delete(id: string) {
    return prisma.special.delete({ where: { id } });
  },
};
