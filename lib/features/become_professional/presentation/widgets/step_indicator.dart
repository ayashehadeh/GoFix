import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep; // 0-indexed
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        final isDone = index < currentStep;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryOrange
                  : isDone
                      ? AppColors.primaryDark
                      : AppColors.primaryDark.withOpacity(0.25),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
