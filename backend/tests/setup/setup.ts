import { prisma } from "../../src/lib/prisma.ts";
import { afterEach, beforeEach} from "vitest";

beforeEach(async () => {
  try {
    console.log("Cleaning db before next test ")
    await prisma.order.deleteMany();
    await prisma.menuItem.deleteMany();
    await prisma.cafeteria.deleteMany();
    await prisma.user.deleteMany(); 
    await prisma.orderItem.deleteMany(); 

  } catch (err: any) {
    console.warn("Cleanup warning (safe to ignore if first run):", err.message);
  }
});
