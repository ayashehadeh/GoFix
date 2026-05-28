import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/booking.dart';

class BookingStatusBadge extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusBadge({super.key, required this.status});
  Color get _backgroundColor {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFF5EFEB);
      case BookingStatus.confirmed:
      case BookingStatus.accepted:
        return const Color(0xFFE8F0F8);
      case BookingStatus.onTheWay:
        return const Color(0xFFFFF3E8);
      case BookingStatus.arrived:
        return const Color(0xFFE8F0F8);
      case BookingStatus.inProgress:
        return const Color(0xFFFFF3E8);
      case BookingStatus.completed:
        return const Color(0xFFE8F0F8);
      case BookingStatus.cancelled:
      case BookingStatus.declined:
        return const Color(0xFFF0F0F0);
    }
  }

  Color get _textColor {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFF795548);
      case BookingStatus.confirmed:
      case BookingStatus.accepted:
        return const Color(0xFF1A3A5C);
      case BookingStatus.onTheWay:
        return const Color(0xFFE87722);
      case BookingStatus.arrived:
        return const Color(0xFF1A3A5C);
      case BookingStatus.inProgress:
        return const Color(0xFFE87722);
      case BookingStatus.completed:
        return const Color(0xFF1A3A5C);
      case BookingStatus.cancelled:
      case BookingStatus.declined:
        return const Color(0xFF757575);
    }
  }

  String _localizedStatus(AppLocalizations l10n) {
    switch (status) {
      case BookingStatus.pending:
        return l10n.statusPending;
      case BookingStatus.confirmed:
      case BookingStatus.accepted:
        return l10n.statusAccepted;
      case BookingStatus.onTheWay:
        return l10n.statusOnTheWay;
      case BookingStatus.arrived:
        return l10n.statusArrived;
      case BookingStatus.inProgress:
        return l10n.statusInProgress;
      case BookingStatus.completed:
        return l10n.statusCompleted;
      case BookingStatus.cancelled:
        return l10n.statusCancelled;
      case BookingStatus.declined:
        return l10n.statusDeclined;
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
