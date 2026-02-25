import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading1 = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const TextStyle heading2 = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  static const TextStyle locationLabel = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w400,
    color: Colors.white70,
  );
  static const TextStyle locationValue = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static const TextStyle categoryLabel = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  static const TextStyle bottomNavLabel = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500,
  );
  static const TextStyle searchHint = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
