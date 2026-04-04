import { prisma } from '../lib/index.ts';

export const UserService = {
  async getProfile(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        dietaryLifestyle: true,
        allergies: true,
        createdAt: true,
      },
    });
    if (!user) throw new Error('User not found');
    return user;
  },

  async updatePreferences(userId: string, data: { dietaryLifestyle?: string[]; allergies?: string[] }) {
    return prisma.user.update({
      where: { id: userId },
      data,
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        dietaryLifestyle: true,
        allergies: true,
      },
    });
  },

  async updateProfile(userId: string, data: { name?: string }) {
    return prisma.user.update({
      where: { id: userId },
      data,
      select: { id: true, name: true, email: true, role: true },
    });
  },
};
