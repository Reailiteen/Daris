import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:focus_flow_flutter/data/models/wallet_models.dart';
import 'package:focus_flow_flutter/features/ai_questions/view/quick_study_view.dart';
import 'package:focus_flow_flutter/features/balance/controller/balance_controller.dart';
import 'package:focus_flow_flutter/features/demo/controller/demo_mode_controller.dart';

void main() {
  test('wallet week starts on Sunday', () {
    expect(
      BalanceController.sundayWeekStart(DateTime(2026, 9, 13)),
      DateTime(2026, 9, 13),
    );
    expect(
      BalanceController.sundayWeekStart(DateTime(2026, 9, 14)),
      DateTime(2026, 9, 13),
    );
    expect(
      BalanceController.sundayWeekStart(DateTime(2026, 9, 19)),
      DateTime(2026, 9, 13),
    );
  });

  test('weekly wallet is earnings minus spends and never negative', () {
    expect(
      const WeeklyWallet(earnedMinutes: 9, spentMinutes: 4).availableMinutes,
      5,
    );
    expect(
      const WeeklyWallet(earnedMinutes: 2, spentMinutes: 7).availableMinutes,
      0,
    );
  });

  test('offline demo Quick Study runs 5 to 8 to 3', () async {
    final demo = DemoModeController()..onInit();
    expect(demo.availableMinutes.value, 5);
    for (var index = 0; index < demo.questions.length; index++) {
      demo.answer(demo.currentQuestion.correctIndex);
      await demo.next();
    }
    expect(demo.availableMinutes.value, 8);
    expect(demo.spendEntertainment()!.remainingBalance, 3);
    expect(demo.availableMinutes.value, 3);
  });

  testWidgets('a Quick Study answer shows feedback and enables Next', (
    tester,
  ) async {
    Get.reset();
    Get.put(DemoModeController());
    await tester.pumpWidget(
      const GetMaterialApp(home: QuickStudyView(demo: true)),
    );
    await tester.pump();

    await tester.tap(find.text('Na'));
    await tester.pump();

    expect(find.textContaining('Correct!'), findsOneWidget);
    final next = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Next question'),
    );
    expect(next.onPressed, isNotNull);
    Get.reset();
  });
}
