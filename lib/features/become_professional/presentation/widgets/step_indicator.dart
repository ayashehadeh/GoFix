import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep; // 0-indexed
  final int totalSteps;
  final Function(int) onStepTapped;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.onStepTapped,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        final isDone = index < currentStep;

        return Expanded(
          child: GestureDetector(
            onTap: () => onStepTapped(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
              height: 10,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFFF8C1A) // orange — current
                    : isDone
                        ? const Color(0xFF062B4D) // dark navy — done
                        : const Color(0xFF062B4D).withOpacity(0.35), // faded — upcoming
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        );
      }),
    );
  }
}
