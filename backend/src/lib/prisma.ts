import "dotenv/config";
import { PrismaClient } from "../../prisma/migrations";

const prisma = new PrismaClient();

export { prisma };