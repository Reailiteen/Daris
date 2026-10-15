import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/wallet_models.dart';
import '../../home/view/home_view.dart';
import '../../home/widgets/spend_confirmation_sheet.dart';

class RewardResultView extends StatefulWidget {
  const RewardResultView({super.key, required this.result, this.demo = false});
  final RewardResult result;
  final bool demo;
  @override
  State<RewardResultView> createState() => _RewardResultViewState();
}

class _RewardResultViewState extends State<RewardResultView>
    with SingleTickerProviderStateMixin {
  late final AnimationController animation;
  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final value =
                    widget.result.previousBalance +
                    (widget.result.earnedMinutes * animation.value).round();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.reward,
                      size: 70,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.result.sourceLabel,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '+${widget.result.earnedMinutes} min earned',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 22),
                    WalletCard(minutes: value),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => showSpendConfirmation(
                          context: context,
                          demo: widget.demo,
                        ),
                        child: const Text('Use my screen time'),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Get.offAllNamed(widget.demo ? '/demo' : '/home'),
                      child: const Text('Back to wallet'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
