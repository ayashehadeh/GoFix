import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
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
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isEven) {
          int step = index ~/ 2;
          bool isActive = step == currentStep;

          return GestureDetector(
            onTap: () => onStepTapped(step),
            child: _buildCircle(step, isActive),
          );
        } else {
          return _buildLine(index);
        }
      }),
    );
  }

  Widget _buildCircle(int step, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF062B4D) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF062B4D), width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        "${step + 1}",
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF062B4D),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLine(int index) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        height: 2,
        color: Colors.grey.shade400,
      ),
    );
  }
}
