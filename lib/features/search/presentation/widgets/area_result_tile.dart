import 'package:flutter/material.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/features/search/domain/entities/search_result.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/l10n/area_name_l10n.dart';

class AreaResultTile extends StatelessWidget {
  final AreaResult area;
  final String query;
  final VoidCallback onTap;

  const AreaResultTile({
    super.key,
    required this.area,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Location icon box
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F0FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF2C5FB0),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),

            // Name + city
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HighlightedText(
                      text: localizeAreaName(area.name, AppLocalizations.of(context)!, nameAr: area.nameAr),
                      query: query),
                  const SizedBox(height: 2),
                  Text(
                    '${localizeCity(area.city, AppLocalizations.of(context)!)} · ${area.proCount} pros serve here',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC), size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Highlighted text ─────────────────────────────────────────────────────────

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightedText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(
        text,
        style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
      );
    }

    final lower = text.toLowerCase();
    final qLower = query.toLowerCase();
    final idx = lower.indexOf(qLower);

    if (idx == -1) {
      return Text(
        text,
        style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
      );
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
        children: [
          if (idx > 0) TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + query.length),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryOrange,
            ),
          ),
          if (idx + query.length < text.length) TextSpan(text: text.substring(idx + query.length)),
        ],
      ),
    );
  }
}
