enum MealPeriod { breakfast, lunchDinner, closed }

class MealPeriodHelper {
  /// Returns the current meal period based on UTC hour (Ghana is GMT+0).
  static MealPeriod current() {
    final hour = DateTime.now().toUtc().hour;
    if (hour >= 8 && hour < 10) return MealPeriod.breakfast;
    if (hour >= 10 && hour < 20) return MealPeriod.lunchDinner;
    return MealPeriod.closed;
  }

  static String label(MealPeriod p) {
    switch (p) {
      case MealPeriod.breakfast: return 'Breakfast';
      case MealPeriod.lunchDinner: return 'Lunch & Dinner';
      case MealPeriod.closed: return 'Closed';
    }
  }

  /// Returns a pickupWindow 30 minutes from now, capped within the current period end.
  /// Returns null if currently closed.
  static DateTime? pickupWindow() {
    final now = DateTime.now().toUtc();
    final period = current();
    if (period == MealPeriod.closed) return null;

    final endHour = period == MealPeriod.breakfast ? 10 : 20;
    final periodEnd = DateTime.utc(now.year, now.month, now.day, endHour);

    final desired = now.add(const Duration(minutes: 30));
    // Clamp to 5 minutes before period end so pickup is always valid
    final latest = periodEnd.subtract(const Duration(minutes: 5));
    return desired.isBefore(latest) ? desired : latest;
  }
}
