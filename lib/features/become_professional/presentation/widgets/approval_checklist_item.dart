import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class ApprovalChecklistItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;

  const ApprovalChecklistItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.primaryOrange.withOpacity(0.12)
                : AppColors.error.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check_rounded : Icons.close_rounded,
            color: isCompleted ? AppColors.primaryOrange : AppColors.error,
            size: 18,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
