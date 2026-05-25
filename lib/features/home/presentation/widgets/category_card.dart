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
      case 'Plumbing':
        return l10n.categoryPlumbing;
      case 'Electrical Work':
        return l10n.categoryElectricalWork;
      case 'AC Repair':
        return l10n.categoryAcRepair;
      case 'Carpentry':
        return l10n.categoryCarpentry;
      case 'Painting':
        return l10n.categoryPainting;
      case 'Cleaning':
        return l10n.categoryCleaning;
      case 'Moving Services':
        return l10n.categoryMovingServices;
      case 'Appliance Repair':
        return l10n.categoryApplianceRepair;
      default:
        return category.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          final circleSize = (cardWidth * 0.85).clamp(44.0, 72.0);
          final iconSize = (circleSize * 0.5).clamp(22.0, 36.0);
          final fontSize = (cardWidth * 0.13).clamp(9.0, 12.0);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: circleSize,
                height: circleSize,
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
                    width: iconSize,
                    height: iconSize,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryOrange,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _localizedName(l10n),
                style: AppTextStyles.categoryLabel.copyWith(fontSize: fontSize),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }
}
