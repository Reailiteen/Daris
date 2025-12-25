import 'dart:async';
import 'package:get/get.dart';
import '../../../data/services/focus_flow_service.dart';
import '../../../data/models/focus_session.dart';
import '../../authorization/controller/authorization_controller.dart';

class HomeController extends GetxController {
  final FocusFlowService _service = Get.find<FocusFlowService>();

  final Rxn<FocusSession> currentSession = Rxn<FocusSession>();
  final RxBool isSessionActive = false.obs;
  final RxString remainingTimeString = "00:00".obs;
  final RxDouble progress = 0.0.obs;
  
  final Rx<SessionDuration> selectedDuration = SessionDuration.thirty.obs;
  
  /// Check if Screen Time authorization was granted (not skipped)
  bool get canStartSession => !AuthorizationController.isAuthorizationSkipped;
  
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    // Recover session if any
    _recoverSession();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _recoverSession() {
    // We'll implement recovery logic via service later
  }

  void startSession() async {
    // Check if Screen Time is authorized
    if (!canStartSession) {
      Get.snackbar(
        'Authorization Required',
        'Please grant Screen Time permission to start a focus session.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    
    final durationSeconds = selectedDuration.value.duration.inSeconds;
    await _service.startFocusSession(durationSeconds);
    
    currentSession.value = FocusSession(
      duration: selectedDuration.value.duration,
      startTime: DateTime.now(),
      isActive: true,
    );
    
    isSessionActive.value = true;
    _startTimer();
  }

  void endSession() async {
    await _service.endFocusSession();
    _stopTimer();
    
    isSessionActive.value = false;
    currentSession.value = null;
    remainingTimeString.value = "00:00";
    progress.value = 0.0;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimerDisplay();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _updateTimerDisplay() {
    if (currentSession.value == null || !currentSession.value!.isActive) {
      _stopTimer();
      return;
    }

    final remaining = currentSession.value!.remainingTime;
    if (remaining.inSeconds <= 0) {
      _sessionCompleted();
      return;
    }

    remainingTimeString.value = currentSession.value!.formattedRemainingTime;
    progress.value = currentSession.value!.progress;
  }

  void _sessionCompleted() {
    _stopTimer();
    isSessionActive.value = false;
    currentSession.value = null;
    // Notify or show success view
  }
}
