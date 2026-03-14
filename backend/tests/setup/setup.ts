import { prisma } from "../../src/lib/prisma.ts";
import { afterEach } from "vitest";

afterEach(async () => {
  try {
    await prisma.order.deleteMany();
    await prisma.menuItem.deleteMany();
    await prisma.cafeteria.deleteMany();
    await prisma.user.deleteMany(); 
    await prisma.orderItem.deleteMany(); 

  } catch (err: any) {
    console.warn("Cleanup warning (safe to ignore if first run):", err.message);
  }
});
