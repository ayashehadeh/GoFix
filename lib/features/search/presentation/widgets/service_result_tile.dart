import 'package:flutter/material.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/features/search/domain/entities/search_result.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/l10n/service_name_l10n.dart';

class ServiceResultTile extends StatelessWidget {
  final ServiceResult service;
  final String query;
  final VoidCallback onTap;

  const ServiceResultTile({
    super.key,
    required this.service,
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
            // Icon box — wrench/tools icon in orange tint
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.build_outlined,
                color: AppColors.primaryOrange,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),

            // Service name + category label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HighlightedText(
                      text: localizeServiceName(service.serviceName, AppLocalizations.of(context)!, nameAr: service.serviceNameAr),
                      query: query),
                  const SizedBox(height: 2),
                  Text(
                    service.category.displayName +
                        (service.proCount > 0
                            ? ' · ${service.proCount} pro${service.proCount != 1 ? "s" : ""}'
                            : ''),
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF888888)),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right,
                color: Color(0xFFCCCCCC), size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Orange-highlighted matching text ─────────────────────────────────────────

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightedText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text,
          style: const TextStyle(fontSize: 14, color: Color(0xFF222222)));
    }

    final lower = text.toLowerCase();
    final qLower = query.toLowerCase();
    final idx = lower.indexOf(qLower);

    if (idx == -1) {
      return Text(text,
          style: const TextStyle(fontSize: 14, color: Color(0xFF222222)));
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
          if (idx + query.length < text.length)
            TextSpan(text: text.substring(idx + query.length)),
        ],
      ),
    );
  }
}
