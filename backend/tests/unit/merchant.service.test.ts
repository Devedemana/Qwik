import { describe, it, expect, vi } from 'vitest';
import { MerchantService } from 'services/merchant.services.ts';
vi.mock('@/lib/prisma');

describe('MerchantService - Unit Tests', () => {
  it('should calculate the total discount correctly for staff members', () => {
    // Logic test: No DB required
    const price = 100;
    const discounted = MerchantService.calculateStaffPrice(price);
    expect(discounted).toBe(80); // Assuming 20% discount
  });

  it('should throw an error if an invalid status transition is attempted', async () => {
    // Logic test: Checking state machine rules
    const currentStatus = 'COMPLETED';
    const nextStatus = 'PREPPING';
    
    expect(() => MerchantService.validateTransition(currentStatus, nextStatus))
      .toThrow('Cannot move a completed order back to prepping');
  });
});