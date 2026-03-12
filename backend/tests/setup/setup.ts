import { prisma } from '../../src/lib/prisma.ts';
import { afterAll, beforeEach } from 'vitest';

// Runs before every test in every file
beforeEach(async () => {
    // Clear collections in order of dependency to avoid reference errors
    const deleteOrders = prisma.order.deleteMany();
    const deleteMenuItems = prisma.menuItem.deleteMany();
    const deleteCafeterias = prisma.cafeteria.deleteMany();
    const deleteUsers = prisma.user.deleteMany();
    try {
        await prisma.$transaction([
            deleteOrders,
            deleteMenuItems,
            deleteCafeterias,
            deleteUsers,
        ]);
    } catch (err: unknown) {
        console.error('Error', err.message)
    }
}); 
    
    
// Final safety check for each file
afterAll(async () => {
  await prisma.$disconnect();
})
