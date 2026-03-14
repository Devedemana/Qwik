import { PrismaClient } from '../../prisma/generated/prisma/client.ts'
//client 
const prisma = new PrismaClient();

export  { prisma };