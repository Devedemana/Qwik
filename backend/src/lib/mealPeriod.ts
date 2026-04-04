/**
 * Meal period rules (Ghana time — UTC+0, server runs UTC):
 *   Breakfast:     08:00 – 10:00
 *   Lunch & Dinner: 10:00 – 20:00
 *   Closed:        20:00 – 08:00
 *
 * The server stores all times in UTC. Ghana is GMT+0 (no DST),
 * so UTC hour == Ghana hour.
 */

export type MealPeriod = 'BREAKFAST' | 'LUNCH_DINNER' | 'CLOSED';

export function getMealPeriod(date: Date = new Date()): MealPeriod {
  const hour = date.getUTCHours();
  if (hour >= 8 && hour < 10) return 'BREAKFAST';
  if (hour >= 10 && hour < 20) return 'LUNCH_DINNER';
  return 'CLOSED';
}

export function getMealPeriodLabel(period: MealPeriod): string {
  switch (period) {
    case 'BREAKFAST': return 'Breakfast';
    case 'LUNCH_DINNER': return 'Lunch & Dinner';
    case 'CLOSED': return 'Closed';
  }
}

/** Returns the end of the current operating window (UTC), or null if closed. */
export function currentPeriodEnd(date: Date = new Date()): Date | null {
  const period = getMealPeriod(date);
  if (period === 'CLOSED') return null;
  const end = new Date(date);
  end.setUTCMinutes(0, 0, 0);
  end.setUTCHours(period === 'BREAKFAST' ? 10 : 20);
  return end;
}

/** Validates that a pickupWindow falls within an active meal period. */
export function isValidPickupWindow(pickupWindow: Date): boolean {
  return getMealPeriod(pickupWindow) !== 'CLOSED';
}
