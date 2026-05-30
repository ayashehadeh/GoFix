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

  switch (name) {
    case 'Sweifieh':          return 'الصويفية';
    case 'Khalda':            return 'خلدا';
    case 'Al Rabiah':         return 'الرابية';
    case 'Um Uthaina':        return 'أم أذينة';
    case 'AlJubaiha':         return 'الجبيهة';
    case 'Abdoun':            return 'عبدون';
    case 'Shmeisani':         return 'الشميساني';
    case 'Downtown Amman':    return 'وسط البلد';
    default:                  return name;
  }
}

/// Returns the localized city name.
/// Prefers [nameAr] from the backend when the locale is Arabic.
/// Falls back to a client-side switch-case, then the original [name].
String localizeCityName(String name, AppLocalizations l10n, {String? nameAr}) {
  final isArabic = l10n.amLabel == 'ص';
  if (!isArabic) return name;
  if (nameAr != null && nameAr.isNotEmpty) return nameAr;

  switch (name) {
    case 'Amman':   return 'عمان';
    case 'Irbid':   return 'إربد';
    case 'Zarqa':   return 'الزرقاء';
    case 'Aqaba':   return 'العقبة';
    default:        return name;
  }
}
