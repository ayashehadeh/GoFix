import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/category_entity.dart';

class CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  String _localizedName(AppLocalizations l10n) {
    switch (category.name) {
      case 'Plumbing':         return l10n.categoryPlumbing;
      case 'Electrical Work':  return l10n.categoryElectricalWork;
      case 'AC Repair':        return l10n.categoryAcRepair;
      case 'Carpentry':        return l10n.categoryCarpentry;
      case 'Painting':         return l10n.categoryPainting;
      case 'Cleaning':         return l10n.categoryCleaning;
      case 'Moving Services':  return l10n.categoryMovingServices;
      case 'Appliance Repair': return l10n.categoryApplianceRepair;
      default:                 return category.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                category.iconAsset,
                width: 36,
                height: 36,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryOrange,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 72,
            child: Text(
              _localizedName(l10n),
              style: AppTextStyles.categoryLabel,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
