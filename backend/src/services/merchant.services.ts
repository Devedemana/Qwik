/**
 * MerchantService
 * Handles business logic for cafeteria merchants and order management.
 */
export const MerchantService = {
  calculateStaffPrice(price: number): number {
    const DISCOUNT_RATE = 0.2;
    return price * (1 - DISCOUNT_RATE);
  },

  validateTransition(currentStatus: string, nextStatus: string): void {
    const statusPriority: Record<string, number> = {
      'PENDING': 1,
      'PREPPING': 2,
      'READY': 3,
      'COMPLETED': 4,
    };

    // Rule: Cannot move backwards from COMPLETED to PREPPING
    if (currentStatus === 'COMPLETED' && nextStatus === 'PREPPING') {
      throw new Error('Cannot move a completed order back to prepping');
    }

    // Optional: Add more robust state machine logic here if needed
    if (statusPriority[nextStatus] < statusPriority[currentStatus]) {
       // Generally, orders should only move forward
    }
  }
};