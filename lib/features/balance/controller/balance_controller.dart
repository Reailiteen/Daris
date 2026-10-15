import 'package:get/get.dart';

import '../../../data/models/wallet_models.dart';
import '../../../data/services/focus_flow_service.dart';
import '../../../data/services/supabase_service.dart';

class BalanceController extends GetxController {
  BalanceController({
    SupabaseService? supabaseService,
    FocusFlowService? focusFlowService,
  }) : _supabaseService = supabaseService ?? Get.find<SupabaseService>(),
       _focusFlowService = focusFlowService ?? Get.find<FocusFlowService>();

  final SupabaseService _supabaseService;
  final FocusFlowService _focusFlowService;

  final RxInt availableMinutes = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Qatar-local calendar convention: each wallet expires when Sunday starts.
  static DateTime sundayWeekStart([DateTime? date]) {
    final local = (date ?? DateTime.now()).toLocal();
    final day = DateTime(local.year, local.month, local.day);
    return day.subtract(Duration(days: day.weekday % DateTime.daysPerWeek));
  }

  String get formattedBalance => '$availableMinutes min available';

  @override
  void onInit() {
    super.onInit();
    loadBalance();
  }

  Future<void> loadBalance() async {
    final user = _supabaseService.currentUser;
    if (user == null) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      availableMinutes.value = await _supabaseService.getWeeklyWalletBalance(
        userId: user.id,
        weekStart: sundayWeekStart(),
      );
    } catch (_) {
      errorMessage.value = 'Could not load your wallet.';
    } finally {
      isLoading.value = false;
    }
  }

  /// This changes wallet state only. It never invokes Screen Time.
  Future<RewardResult> award({
    required RewardSource source,
    required int minutes,
  }) async {
    final user = _supabaseService.currentUser;
    if (user == null) throw StateError('Sign in to earn screen time.');
    final previous = availableMinutes.value;
    await _supabaseService.addEarning(
      userId: user.id,
      source: source == RewardSource.quickStudy ? 'ai_question' : 'task',
      minutes: minutes,
      weekStart: sundayWeekStart(),
    );
    availableMinutes.value = previous + minutes;
    return RewardResult(
      previousBalance: previous,
      earnedMinutes: minutes,
      source: source,
    );
  }

  /// Records the spend first, then opens the selected native apps for exactly
  /// [minutes]. Call this only after the confirmation UI has been accepted.
  Future<SpendResult> spendOnSelectedApps(int minutes) async {
    if (minutes <= 0) throw ArgumentError.value(minutes, 'minutes');
    final user = _supabaseService.currentUser;
    if (user == null) throw StateError('Sign in to spend screen time.');
    final previous = availableMinutes.value;
    if (previous < minutes)
      throw StateError('You need $minutes min, but have $previous min.');

    final selectedApps = await _focusFlowService.getSelectedAppsCount();
    if (selectedApps == 0) throw const NoSelectedAppsException();

    await _supabaseService.recordSpend(
      userId: user.id,
      minutes: minutes,
      weekStart: sundayWeekStart(),
    );
    availableMinutes.value = previous - minutes;
    try {
      await _focusFlowService.startScreenTimeUsage(minutes);
    } catch (_) {
      throw StateError(
        'Your wallet was updated, but selected apps could not be opened.',
      );
    }
    return SpendResult(previousBalance: previous, spentMinutes: minutes);
  }
}

class NoSelectedAppsException implements Exception {
  const NoSelectedAppsException();
}
