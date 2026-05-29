import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gp/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';

class ModifyBookingSuccessPage extends StatefulWidget {
  const ModifyBookingSuccessPage({super.key});

  @override
  State<ModifyBookingSuccessPage> createState() =>
      _ModifyBookingSuccessPageState();
}

class _ModifyBookingSuccessPageState extends State<ModifyBookingSuccessPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSuccessSheet());
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      // Not dismissible — user must tap Done
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _SuccessSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Background: the Modification 3 review screen (booking details),
    // which is already underneath on the navigator stack. This page
    // is intentionally minimal — the sheet is the main content.
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Builder(
          builder: (ctx) => Text(
            AppLocalizations.of(ctx)!.modifyBooking,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        centerTitle: false,
      ),
    );
  }
}

// ─── Success bottom sheet ─────────────────────────────────────────────────────

class _SuccessSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Blurred + dimmed backdrop ──────────────────────────────────────
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(color: Colors.black.withOpacity(0.25)),
        ),

        // ── Sheet ──────────────────────────────────────────────────────────
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 48),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle (decorative — sheet is not dismissible)
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 28),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Text(
                  AppLocalizations.of(context)!.bookingUpdatedTitle,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  AppLocalizations.of(context)!.bookingUpdatedMessage,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 32),

                // Illustration
                Center(
                  child: SvgPicture.asset(
                    'assets/notapproved_clock.svg',
                    width: 180,
                  ),
                ),
                const SizedBox(height: 32),

                Center(
                  child: Text(
                    AppLocalizations.of(context)!.appreciateTrust,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Done button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // close sheet
                      // Pop all the way back to My Bookings
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.done,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

