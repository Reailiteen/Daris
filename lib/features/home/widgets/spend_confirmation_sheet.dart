import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/wallet_models.dart';
import '../../app_selection/controller/app_selection_controller.dart';
import '../../balance/controller/balance_controller.dart';
import '../../demo/controller/demo_mode_controller.dart';

Future<void> showSpendConfirmation({
  required BuildContext context,
  required bool demo,
}) async {
  final balance = demo
      ? Get.find<DemoModeController>().availableMinutes.value
      : Get.find<BalanceController>().availableMinutes.value;
  const cost = 5;
  final remaining = balance - cost;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        children: [
          Text(
            demo
                ? 'Simulate Entertainment unlock?'
                : 'Unlock your selected apps?',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            'Current balance: $balance min\nCost: $cost min\nRemaining: ${remaining < 0 ? 0 : remaining} min',
          ),
          if (demo)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'This is a prototype simulation. No native app controls are invoked.',
              ),
            ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: balance < cost
                  ? null
                  : () async {
                      try {
                        SpendResult? result;
                        if (demo) {
                          result = Get.find<DemoModeController>()
                              .spendEntertainment();
                        } else {
                          result = await Get.find<BalanceController>()
                              .spendOnSelectedApps(cost);
                        }
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                          Get.snackbar(
                            'Time unlocked',
                            demo
                                ? 'Simulation complete: ${result!.remainingBalance} min remains.'
                                : 'Your selected apps are available for $cost min.',
                          );
                        }
                      } on NoSelectedAppsException {
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                          Get.snackbar(
                            'Choose your selected apps',
                            'Choose apps in the native picker before spending.',
                            mainButton: TextButton(
                              onPressed: () =>
                                  Get.find<AppSelectionController>()
                                      .openPicker(),
                              child: const Text('Choose apps'),
                            ),
                          );
                        }
                      } catch (e) {
                        Get.snackbar('Could not unlock', e.toString());
                      }
                    },
              child: Text(
                balance < cost
                    ? 'Not enough minutes'
                    : (demo ? 'Confirm simulation' : 'Confirm & unlock'),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}
