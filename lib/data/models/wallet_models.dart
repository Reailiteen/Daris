enum RewardSource { task, quickStudy }

class RewardResult {
  const RewardResult({
    required this.previousBalance,
    required this.earnedMinutes,
    required this.source,
  });

  final int previousBalance;
  final int earnedMinutes;
  final RewardSource source;

  int get newBalance => previousBalance + earnedMinutes;
  String get sourceLabel =>
      source == RewardSource.task ? 'Task completed' : 'Quick Study';
}

class SpendResult {
  const SpendResult({
    required this.previousBalance,
    required this.spentMinutes,
  });

  final int previousBalance;
  final int spentMinutes;

  int get remainingBalance => previousBalance - spentMinutes;
}

/// A local representation of the two append-only wallet ledgers.
class WeeklyWallet {
  const WeeklyWallet({required this.earnedMinutes, required this.spentMinutes});

  final int earnedMinutes;
  final int spentMinutes;
  int get availableMinutes => (earnedMinutes - spentMinutes).clamp(0, 1 << 31);
}
