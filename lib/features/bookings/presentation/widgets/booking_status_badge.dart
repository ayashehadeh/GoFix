import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/booking.dart';

class BookingStatusBadge extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusBadge({super.key, required this.status});

  Color get _backgroundColor {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFFFF3E0);
      case BookingStatus.confirmed:
        return const Color(0xFFE3F2FD);
      case BookingStatus.inProgress:
        return const Color(0xFFE8F5E9);
      case BookingStatus.completed:
        return const Color(0xFFEEEEEE);
      case BookingStatus.cancelled:
        return const Color(0xFFFFEBEE);
    }
  }

  Color get _textColor {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFE65100);
      case BookingStatus.confirmed:
        return const Color(0xFF0D47A1);
      case BookingStatus.inProgress:
        return const Color(0xFF1B5E20);
      case BookingStatus.completed:
        return const Color(0xFF424242);
      case BookingStatus.cancelled:
        return const Color(0xFFB71C1C);
    }
  }

  String _localizedStatus(AppLocalizations l10n) {
    switch (status) {
      case BookingStatus.pending:    return l10n.statusPending;
      case BookingStatus.confirmed:  return l10n.statusConfirmed;
      case BookingStatus.inProgress: return l10n.statusInProgress;
      case BookingStatus.completed:  return l10n.statusCompleted;
      case BookingStatus.cancelled:  return l10n.statusCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _localizedStatus(AppLocalizations.of(context)!),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }
}
