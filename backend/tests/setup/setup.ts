import { prisma } from '../../src/lib/prisma.ts';
import {afterEach} from 'vitest';

afterEach(async () => {
  try {
    // These run as direct MongoDB commands, bypassing Prisma's internal transactions
    const collections = ['Order', 'MenuItem', 'Cafeteria', 'User'];

    for (const collection of collections) {
      await prisma.$runCommandRaw({
        delete: collection,
        deletes: [{ q: {}, limit: 0 }],
      });
    }
  } catch (err: any) {
    // If the collection doesn't exist yet, Mongo might throw an error. 
    // We catch it here so it doesn't fail your tests.
    console.warn('Cleanup warning (safe to ignore if first run):', err.message);
  }
});