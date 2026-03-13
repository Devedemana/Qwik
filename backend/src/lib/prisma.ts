import { PrismaClient } from '../../prisma/generated/prisma/client.ts'
import { env } from '../../env.ts';

//client 
const prisma = new PrismaClient({
    datasources: {
        db: {
        url: env.DATABASE_URL
    }
}});

export  { prisma };