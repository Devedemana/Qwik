import { execSync } from 'node:child_process';
import { prisma } from '../../src/lib/prisma.ts';


export async function setup() {
  console.log('--- Preparing Test Environment ---');
  
  try {
    // sync db
    console.log('Syncing database schema...');
    execSync('npx prisma db push --accept-data-loss', { stdio: 'inherit' });
    execSync('npx prisma generate')

    await prisma.$connect();
    console.log('--- Test Environment Ready ---');
  } catch (error) {
    console.error('Global setup failed:', error);
    process.exit(1);
  }
}


export async function teardown() {
  try {
    execSync('npx prisma db reset --force', { stdio: 'inherit' }); 
    // stop docker compose 
    console.log('--- Cleaning Up Test Environment ---');
    // 2. Disconnect the client
    await prisma.$disconnect();
    console.log('--- Teardown Complete ---');
    process.exit(0); 
  } catch (error) {
      console.error('Global teardown encountered an error:', error);
      process.exit(1); 
  }
}