// lib/features/bookings/presentation/pages/book_service_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/bookings/domain/repositories/bookings_repository.dart';
import 'package:gp/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:gp/features/bookings/presentation/pages/book_details_screen.dart';
import 'package:gp/features/professionals/domain/entities/working_hours.dart' as wh;
import 'package:gp/features/settings/domain/entities/address_entity.dart';
import 'package:gp/features/settings/presentation/bloc/address_bloc.dart';
import 'package:gp/injection_container.dart' as di;
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/l10n/app_localizations.dart';

class BookServiceScreen extends StatefulWidget {
  final String serviceName;
  final String? serviceNameAr;
  final String servicePrice;
  final String description;
  final List<File> images;
  final String workerName;
  final String workerRole;
  final String professionalId;
  final wh.WorkingHours workingHours;

  const BookServiceScreen({
    super.key,
    required this.serviceName,
    this.serviceNameAr,
    required this.servicePrice,
    required this.description,
    required this.images,
    required this.workerName,
    required this.workerRole,
    required this.professionalId,
    required this.workingHours,
  });

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  // Sunday=index 0, Monday=1, …, Saturday=6  (matches date.weekday % 7)
  static const _dayNames = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday',
  ];

  int selectedDateIndex = 0;
  int? _selectedSlotHour;
  Set<int> _bookedHours = {};
  bool _loadingSlots = false;

  AddressEntity? _selectedAddress;
  bool _showAddressError = false;
  bool _showSlotError = false;

  static const Color _darkBlue = Color(0xFF1A2B4A);
  static const Color _orange = Color(0xFFFF8C00);
  static const Color _errorRed = Color(0xFFD32F2F);
  static const Color _lightGrey = Color(0xFFF5F5F5);

  // 14 days so there are always enough available working days visible
  late final List<DateTime> dates = List.generate(14, (i) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(Duration(days: i));
  });

  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(const GetAddressesEvent());
    selectedDateIndex = _firstAvailableDateIndex();
    _loadBookedSlots(dates[selectedDateIndex]);
  }

  // ── Day availability helpers ────────────────────────────────────────────────

  int _firstAvailableDateIndex() {
    for (int i = 0; i < dates.length; i++) {
      if (_isDayWorking(dates[i])) return i;
    }
    return 0;
  }

  bool _isDayWorking(DateTime date) {
    if (widget.workingHours.schedules.isEmpty) return true;
    final dayName = _dayNames[date.weekday % 7];
    return widget.workingHours.schedules.any(
      (s) => _dayMatchesSchedule(dayName, s.day),
    );
  }

  bool _dayMatchesSchedule(String dayName, String scheduleDayField) {
    final parts = scheduleDayField.split(' - ').map((p) => p.trim()).toList();
    if (parts.length == 1) return parts[0] == dayName;
    // Range like "Sunday - Thursday"
    final startIdx = _dayNames.indexOf(parts[0]);
    final endIdx = _dayNames.indexOf(parts[1]);
    final currentIdx = _dayNames.indexOf(dayName);
    if (startIdx < 0 || endIdx < 0 || currentIdx < 0) return false;
    if (startIdx <= endIdx) return currentIdx >= startIdx && currentIdx <= endIdx;
    // Wrap-around range (e.g. "Saturday - Monday")
    return currentIdx >= startIdx || currentIdx <= endIdx;
  }

  wh.DaySchedule? _getScheduleForDate(DateTime date) {
    if (widget.workingHours.schedules.isEmpty) return null;
    final dayName = _dayNames[date.weekday % 7];
    try {
      return widget.workingHours.schedules
          .firstWhere((s) => _dayMatchesSchedule(dayName, s.day));
    } catch (_) {
      return null;
    }
  }

  // ── Time parsing ────────────────────────────────────────────────────────────

  int _parseTimeToHour(String time) {
    time = time.trim().toUpperCase();
    if (time.contains('AM') || time.contains('PM')) {
      final isPM = time.contains('PM');
      final digits = time.replaceAll('AM', '').replaceAll('PM', '').trim();
      var hour = int.tryParse(digits.split(':')[0].trim()) ?? 0;
      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      return hour;
    }
    // 24-h format "08:00"
    return int.tryParse(time.split(':')[0].trim()) ?? 0;
  }

  int? _parseHourFromTimeString(String time) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(time);
    if (match == null) return null;
    int hour = int.parse(match.group(1)!);
    final upper = time.toUpperCase();
    if (upper.contains('PM') && hour != 12) hour += 12;
    if (upper.contains('AM') && hour == 12) hour = 0;
    return hour;
  }

  // ── Slot generation ─────────────────────────────────────────────────────────

  List<int> _getSlotsForDate(DateTime date) {
    final schedule = _getScheduleForDate(date);
    final int open, close;
    if (schedule == null) {
      open = 8;
      close = 18;
    } else {
      open = _parseTimeToHour(schedule.openTime);
      close = _parseTimeToHour(schedule.closeTime);
    }
    if (open >= close) return [];
    return List.generate(close - open, (i) => open + i);
  }

  bool _isSlotInPast(DateTime date, int hour) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    return isToday && hour <= now.hour;
  }

  // English AM/PM kept for backend storage consistency
  String _slotToBackendString(int hour) {
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final ampm = hour < 12 ? 'AM' : 'PM';
    return '${h12.toString().padLeft(2, '0')}:00 $ampm';
  }

  String _slotToDisplayString(int hour, AppLocalizations t) {
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final ampm = hour < 12 ? t.amLabel : t.pmLabel;
    return '${h12.toString().padLeft(2, '0')}:00 $ampm';
  }

  // ── Booked slots API ────────────────────────────────────────────────────────

  Future<void> _loadBookedSlots(DateTime date) async {
    setState(() {
      _loadingSlots = true;
      _bookedHours = {};
    });
    final repo = di.sl<BookingsRepository>();
    final result = await repo.getBookedSlots(widget.professionalId, date);
    result.fold(
      (_) {}, // on error, show all slots as available
      (slots) {
        setState(() {
          _bookedHours =
              slots.map(_parseHourFromTimeString).whereType<int>().toSet();
        });
      },
    );
    if (mounted) setState(() => _loadingSlots = false);
  }

  // ── Event handlers ──────────────────────────────────────────────────────────

  void _onDateTap(int index) {
    if (!_isDayWorking(dates[index])) return;
    setState(() {
      selectedDateIndex = index;
      _selectedSlotHour = null;
      _showSlotError = false;
    });
    _loadBookedSlots(dates[index]);
  }

  void _showAddressPicker(List<AddressEntity> addresses) {
    final t = AppLocalizations.of(context)!;
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t.selectAddress,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _darkBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (addresses.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                t.noSavedAddresses,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...addresses.map(
              (addr) => ListTile(
                leading: Icon(
                  addr.type == AddressType.apartment
                      ? Icons.apartment
                      : Icons.home_outlined,
                  color: _orange,
                ),
                title: Text(addr.displayTitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: _darkBlue)),
                subtitle: Text(addr.displaySubtitle,
                    style: const TextStyle(fontSize: 12)),
                trailing: _selectedAddress?.id == addr.id
                    ? const Icon(Icons.check_circle, color: _orange)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedAddress = addr;
                    _showAddressError = false;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  bool _validate() {
    setState(() {
      _showAddressError = _selectedAddress == null;
      _showSlotError = _selectedSlotHour == null;
    });
    if (_showAddressError || _showSlotError) return false;

    final selectedDate = dates[selectedDateIndex];
    final today = DateTime.now();
    if (selectedDate.isBefore(DateTime(today.year, today.month, today.day))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.cannotBookPastDate),
          backgroundColor: AppColors.primaryOrange,
        ),
      );
      return false;
    }
    return true;
  }

  List<String> _dayLabels = [];
  List<String> _monthLabels = [];

  void _onContinue() {
    if (!_validate()) return;
    final selectedDate = dates[selectedDateIndex];
    final dateStr =
        '${_dayLabels[selectedDate.weekday - 1]}, ${selectedDate.day} ${_monthLabels[selectedDate.month - 1]} ${selectedDate.year}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => di.sl<BookingsBloc>(),
          child: BookDetailsScreen(
            serviceName: widget.serviceName,
            serviceNameAr: widget.serviceNameAr,
            servicePrice: widget.servicePrice,
            description: widget.description,
            images: widget.images,
            date: dateStr,
            time: _slotToBackendString(_selectedSlotHour!),
            address:
                '${_selectedAddress!.displayTitle}, ${_selectedAddress!.displaySubtitle}',
            latitude: _selectedAddress!.latitude,
            longitude: _selectedAddress!.longitude,
            workerName: widget.workerName,
            professionalId: widget.professionalId,
            scheduledDate: selectedDate,
          ),
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    _dayLabels = [
      t.dayMonShort, t.dayTueShort, t.dayWedShort, t.dayThuShort,
      t.dayFriShort, t.daySatShort, t.daySunShort,
    ];
    _monthLabels = [
      t.monthJan, t.monthFeb, t.monthMar, t.monthApr, t.monthMay, t.monthJun,
      t.monthJul, t.monthAugShort, t.monthSep, t.monthOct, t.monthNov, t.monthDec,
    ];

    return Scaffold(
      backgroundColor: _lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: _darkBlue),
        title: Text(
          t.bookAService,
          style: const TextStyle(
            color: _darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Step 2 progress bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(child: _progressBar(_darkBlue)),
                const SizedBox(width: 8),
                Expanded(child: _progressBar(_orange)),
                const SizedBox(width: 8),
                Expanded(child: _progressBar(_darkBlue)),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Date & Time Card ───────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card header
                        Row(
                          children: [
                            const Icon(Icons.settings, color: _orange, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.chooseDateTime,
                                      style: const TextStyle(
                                          color: _darkBlue,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Text(t.selectPreferredSlot,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Date label
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, color: _orange, size: 22),
                            const SizedBox(width: 8),
                            Text(t.selectDate,
                                style: const TextStyle(
                                    color: _darkBlue,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Date picker row
                        _buildDatePicker(),

                        const SizedBox(height: 20),

                        // Time label + loading indicator
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: _orange, size: 22),
                            const SizedBox(width: 8),
                            Text(t.selectTime,
                                style: const TextStyle(
                                    color: _darkBlue,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                            if (_loadingSlots) ...[
                              const SizedBox(width: 10),
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: _orange),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Slot grid
                        _buildSlotGrid(t),

                        if (_showSlotError)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              t.pleaseSelectATimeSlot,
                              style: const TextStyle(color: _errorRed, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Address Card ───────────────────────────────────
                  BlocBuilder<AddressBloc, AddressState>(
                    builder: (context, addrState) {
                      final addresses = addrState is AddressLoaded
                          ? addrState.addresses
                          : addrState is AddressActionSuccess
                              ? addrState.addresses
                              : <AddressEntity>[];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => _showAddressPicker(addresses),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: _showAddressError
                                    ? Border.all(color: _errorRed, width: 1.5)
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.map_outlined,
                                          color: _orange, size: 22),
                                      const SizedBox(width: 10),
                                      Text(t.chooseAddress,
                                          style: const TextStyle(
                                              color: _darkBlue,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _showAddressError
                                          ? const Color(0xFFFFF3F3)
                                          : const Color(0xFFF8F8F8),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: _selectedAddress == null
                                        ? Row(
                                            children: [
                                              Icon(Icons.location_on_outlined,
                                                  color: Colors.grey.shade400,
                                                  size: 18),
                                              const SizedBox(width: 8),
                                              Text(
                                                addrState is AddressLoading
                                                    ? t.loadingAddresses
                                                    : t.tapToSelectAddress,
                                                style: TextStyle(
                                                    color: Colors.grey.shade400,
                                                    fontSize: 13),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              Icon(
                                                _selectedAddress!.type ==
                                                        AddressType.apartment
                                                    ? Icons.apartment
                                                    : Icons.home_outlined,
                                                color: _orange,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _selectedAddress!
                                                          .displayTitle,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: _darkBlue,
                                                          fontSize: 13),
                                                    ),
                                                    Text(
                                                      _selectedAddress!
                                                          .displaySubtitle,
                                                      style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Icon(Icons.edit_outlined,
                                                  color: _orange, size: 16),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_showAddressError)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 4),
                              child: Text(
                                t.pleaseSelectYourAddress,
                                style: const TextStyle(
                                    color: _errorRed, fontSize: 12),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Continue button
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  t.continue1,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sub-widgets ─────────────────────────────────────────────────────────────

  Widget _progressBar(Color color) => Container(
        height: 6,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(3)),
      );

  Widget _buildDatePicker() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        const visibleCards = 4.5;
        final cardWidth =
            (constraints.maxWidth - gap * (visibleCards - 1)) / visibleCards;
        final cardHeight = cardWidth * 1.45;
        final fontSizeSmall = (cardWidth * 0.18).clamp(11.0, 14.0);
        final fontSizeLarge = (cardWidth * 0.28).clamp(16.0, 22.0);
        final innerGap = (cardHeight * 0.04).clamp(2.0, 6.0);

        return SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            separatorBuilder: (_, __) => SizedBox(width: gap),
            itemBuilder: (context, index) {
              final isSelected = index == selectedDateIndex;
              final isWorking = _isDayWorking(dates[index]);

              Color bgColor;
              Color dayColor, numColor, monColor;
              if (isSelected) {
                bgColor = _darkBlue;
                dayColor = numColor = monColor = Colors.white70;
                numColor = Colors.white;
              } else if (isWorking) {
                bgColor = const Color(0xFFF4F4F4);
                dayColor = monColor = Colors.grey;
                numColor = _darkBlue;
              } else {
                bgColor = const Color(0xFFEAEAEA);
                dayColor = numColor = monColor =
                    Colors.grey.withValues(alpha: 0.45);
              }

              return GestureDetector(
                onTap: () => _onDateTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _dayLabels[dates[index].weekday - 1],
                        style:
                            TextStyle(color: dayColor, fontSize: fontSizeSmall),
                      ),
                      SizedBox(height: innerGap),
                      Text(
                        dates[index].day.toString(),
                        style: TextStyle(
                          color: numColor,
                          fontSize: fontSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: innerGap),
                      Text(
                        _monthLabels[dates[index].month - 1],
                        style:
                            TextStyle(color: monColor, fontSize: fontSizeSmall),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSlotGrid(AppLocalizations t) {
    if (!_isDayWorking(dates[selectedDateIndex])) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          t.professionalNotAvailableOnThisDay,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }

    final slots = _getSlotsForDate(dates[selectedDateIndex]);
    if (slots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          t.noSlotsAvailable,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((hour) {
        final isBooked = _bookedHours.contains(hour);
        final isPast = _isSlotInPast(dates[selectedDateIndex], hour);
        final isUnavailable = isBooked || isPast;
        final isSelected = _selectedSlotHour == hour;

        return GestureDetector(
          onTap: isUnavailable
              ? null
              : () => setState(() {
                    _selectedSlotHour = hour;
                    _showSlotError = false;
                  }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? _darkBlue
                  : isUnavailable
                      ? const Color(0xFFEEEEEE)
                      : const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? _darkBlue
                    : const Color(0xFFDDDDDD),
                width: 1,
              ),
            ),
            child: Text(
              _slotToDisplayString(hour, t),
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : isUnavailable
                        ? Colors.grey.withValues(alpha: 0.45)
                        : _darkBlue,
                decoration: isUnavailable
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: Colors.grey.withValues(alpha: 0.45),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
