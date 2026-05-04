import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// A tappable row used for selectable inputs on Step 1
/// (Service category, Experience years, City, Area).
/// Renders: label · divider · value · trailing icon (or spinner).
class StepFormField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final bool hasError;
  final bool enabled;
  final bool isLoading;
  final VoidCallback? onTap;

  const StepFormField({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.value,
    this.hasError = false,
    this.enabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasError ? AppColors.error : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: hasError ? AppColors.error : AppColors.primaryDark,
                ),
              ),
            ),
            Container(
              width: 1,
              height: 20,
              color: AppColors.divider,
              margin: const EdgeInsets.only(right: 12),
            ),
            Expanded(
              child: Text(
                value ?? '',
                style: TextStyle(
                  fontSize: 13,
                  color: enabled
                      ? AppColors.primaryDark
                      : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryDark,
                ),
              )
            else
              Icon(
                icon,
                size: 20,
                color: enabled
                    ? AppColors.primaryDark
                    : AppColors.divider,
              ),
          ],
        ),
      ),
    );
  }
}

/// Generic bottom-sheet picker used by Step 1 fields.
void showStepPicker<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) labelOf,
  required T? selected,
  required ValueChanged<T> onSelected,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
        const Divider(),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: items.map((item) {
              final isSel = item == selected;
              return ListTile(
                title: Text(
                  labelOf(item),
                  style: TextStyle(
                    color: isSel
                        ? AppColors.primaryOrange
                        : AppColors.primaryDark,
                    fontWeight:
                        isSel ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                trailing: isSel
                    ? const Icon(
                        Icons.check,
                        color: AppColors.primaryOrange,
                        size: 18,
                      )
                    : null,
                onTap: () {
                  onSelected(item);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}
