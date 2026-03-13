import { describe, it, expect, vi } from 'vitest';
import { MerchantService } from '../../src/services/merchant.services.ts';

// Mocking prisma so it doesn't try to connect during unit tests
vi.mock('@/lib/prisma', () => ({
  prisma: {
    cafeteria: { update: vi.fn() },
    order: { update: vi.fn(), findMany: vi.fn() },
    menuItem: { update: vi.fn() }
  }
}));

describe('MerchantService - Unit Tests', () => {
  it('should apply a 20% discount for staff members', () => {
    const price = 100;
    const result = MerchantService.calculateStaffPrice(price);
    expect(result).toBe(80);
  });

  it('should prevent moving COMPLETED orders back to PREPPING', () => {
    const currentStatus = 'COMPLETED';
    const nextStatus = 'PREPPING';
    
    // Note: No 'async' needed if validateTransition is synchronous
    expect(() => MerchantService.validateTransition(currentStatus, nextStatus))
      .toThrow(/Cannot move a completed order back/); 
  });
});