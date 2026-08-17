abstract class StatsEvent {
  const StatsEvent();
}

class LoadMonthlyStatsEvent extends StatsEvent {
  final int year;
  final int month;

  const LoadMonthlyStatsEvent({
    required this.year,
    required this.month,
  });
}
