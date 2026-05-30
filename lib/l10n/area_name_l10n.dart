import 'package:gp/l10n/app_localizations.dart';

/// Returns the localized area name.
/// Prefers [nameAr] from the backend when the locale is Arabic.
/// Falls back to the original [name] if no Arabic name is available.
String localizeAreaName(String name, AppLocalizations l10n, {String? nameAr}) {
  final isArabic = l10n.amLabel == 'ص';
  if (!isArabic) return name;
  if (nameAr != null && nameAr.isNotEmpty) return nameAr;
  return name;
}

/// Returns the localized city name for the four supported Jordanian cities.
String localizeCity(String city, AppLocalizations l10n) {
  final isArabic = l10n.amLabel == 'ص';
  if (!isArabic) return city;
  switch (city.toLowerCase()) {
    case 'amman':  return 'عمّان';
    case 'irbid':  return 'إربد';
    case 'zarqa':  return 'الزرقاء';
    case 'aqaba':  return 'العقبة';
    default:       return city;
  }
}
