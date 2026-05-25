// lib/features/bookings/presentation/pages/book_service_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:gp/features/bookings/presentation/pages/book_details_screen.dart';
import 'package:gp/features/settings/domain/entities/address_entity.dart';
import 'package:gp/features/settings/presentation/bloc/address_bloc.dart';
import 'package:gp/injection_container.dart' as di;
import 'package:gp/l10n/app_localizations.dart';

class BookServiceScreen extends StatefulWidget {
  final String serviceName;
  final String servicePrice;
  final String description;
  final List<File> images;
  final String workerName;
  final String workerRole;
  final String professionalId;


  const BookServiceScreen({
    super.key,
    required this.serviceName,
    required this.servicePrice,
    required this.description,
    required this.images,
    required this.workerName,
    required this.workerRole,
    required this.professionalId,
  });

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  int selectedDateIndex = 1;
  int selectedHour = 7;
  int selectedMinute = 0;

  AddressEntity? _selectedAddress;
  bool _showAddressError = false;

  static const Color darkBlue = Color(0xFF1A2B4A);
  static const Color orange = Color(0xFFFF8C00);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color lightGrey = Color(0xFFF5F5F5);

  late final List<DateTime> dates = List.generate(
    7,
    (index) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day).add(Duration(days: index));
    },
  );


  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(const GetAddressesEvent());
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
            width: 40, height: 4,
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
                  color: darkBlue,
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
            ...addresses.map((addr) => ListTile(
                  leading: Icon(
                    addr.type == AddressType.apartment
                        ? Icons.apartment
                        : Icons.home_outlined,
                    color: orange,
                  ),
                  title: Text(addr.displayTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: darkBlue)),
                  subtitle: Text(addr.displaySubtitle,
                      style: const TextStyle(fontSize: 12)),
                  trailing: _selectedAddress?.id == addr.id
                      ? const Icon(Icons.check_circle, color: orange)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedAddress = addr;
                      _showAddressError = false;
                    });
                    Navigator.pop(context);
                  },
                )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showTimePicker() {
    final t = AppLocalizations.of(context)!;
    int tempHour = selectedHour;
    int tempMinute = selectedMinute;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        t.cancel,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    Text(
                      t.selectTime,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: darkBlue,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final now = DateTime.now();
                        final selectedDate = dates[selectedDateIndex];
                        final isToday = selectedDate.year == now.year &&
                            selectedDate.month == now.month &&
                            selectedDate.day == now.day;
                        if (isToday &&
                            (tempHour < now.hour ||
                                (tempHour == now.hour && tempMinute <= now.minute))) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.cannotBookPastTime),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        setState(() {
                          selectedHour = tempHour;
                          selectedMinute = tempMinute;
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        t.done,
                        style: const TextStyle(color: orange),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 48,
                        scrollController: FixedExtentScrollController(
                          initialItem: tempHour,
                        ),
                        onSelectedItemChanged: (val) => tempHour = val,
                        children: List.generate(
                          24,
                          (i) => Center(
                            child: Text(
                              i.toString().padLeft(2, '0'),
                              style: const TextStyle(
                                fontSize: 22,
                                color: darkBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      ':',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 48,
                        scrollController: FixedExtentScrollController(
                          initialItem: tempMinute,
                        ),
                        onSelectedItemChanged: (val) => tempMinute = val,
                        children: List.generate(
                          60,
                          (i) => Center(
                            child: Text(
                              i.toString().padLeft(2, '0'),
                              style: const TextStyle(
                                fontSize: 22,
                                color: darkBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _validate() {
    setState(() {
      _showAddressError = _selectedAddress == null;
    });
    return !_showAddressError;
  }

  List<String> _dayLabels = [];
  List<String> _monthLabels = [];

  void _onContinue() {
    if (_validate()) {
      final selectedDate = dates[selectedDateIndex];
      final dateStr =
          '${_dayLabels[selectedDate.weekday - 1]}, ${selectedDate.day} ${_monthLabels[selectedDate.month - 1]} ${selectedDate.year}';
      final hour = selectedHour % 12 == 0 ? 12 : selectedHour % 12;
      final t2 = AppLocalizations.of(context)!;
    final amPm = selectedHour < 12 ? t2.amLabel : t2.pmLabel;
      final timeStr =
          '${hour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')} $amPm';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => di.sl<BookingsBloc>(),
            child: BookDetailsScreen(
              serviceName: widget.serviceName,
              servicePrice: widget.servicePrice,
              description: widget.description,
              images: widget.images,
              date: dateStr,
              time: timeStr,
              address: '${_selectedAddress!.displayTitle}, ${_selectedAddress!.displaySubtitle}',
              workerName: widget.workerName,
              professionalId: widget.professionalId, // ADD
              scheduledDate: selectedDate,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    _dayLabels = [
      t.dayMonShort, t.dayTueShort, t.dayWedShort, t.dayThuShort,
      t.dayFriShort, t.daySatShort, t.daySunShort,
    ];
    _monthLabels = [
      t.monthJan, t.monthFeb, t.monthMar, t.monthApr, t.monthMay,
      t.monthJun, t.monthJul, t.monthAugShort, t.monthSep,
      t.monthOct, t.monthNov, t.monthDec,
    ];
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: darkBlue),
        title: Text(
          t.bookAService,
          style: const TextStyle(
            color: darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Step 2 active
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: darkBlue,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: orange,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: darkBlue,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Date & Time Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
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
                            const Icon(Icons.settings, color: orange, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.chooseDateTime,
                                    style: const TextStyle(
                                      color: darkBlue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    t.selectPreferredSlot,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, color: orange, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              t.selectDate,
                              style: const TextStyle(
                                color: darkBlue,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            const gap = 8.0;
                            const visibleCards = 4.5;
                            final cardWidth = (constraints.maxWidth - gap * (visibleCards - 1)) / visibleCards;
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
                                  return GestureDetector(
                                    onTap: () {
                                      final today = DateTime.now();
                                      final todayOnly = DateTime(today.year, today.month, today.day);
                                      if (dates[index].isBefore(todayOnly)) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(AppLocalizations.of(context)!.cannotBookPastDate),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                        return;
                                      }
                                      setState(() => selectedDateIndex = index);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: cardWidth,
                                      height: cardHeight,
                                      decoration: BoxDecoration(
                                        color: isSelected ? darkBlue : const Color(0xFFF4F4F4),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _dayLabels[dates[index].weekday - 1],
                                            style: TextStyle(
                                              color: isSelected ? Colors.white70 : Colors.grey,
                                              fontSize: fontSizeSmall,
                                            ),
                                          ),
                                          SizedBox(height: innerGap),
                                          Text(
                                            dates[index].day.toString(),
                                            style: TextStyle(
                                              color: isSelected ? Colors.white : darkBlue,
                                              fontSize: fontSizeLarge,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: innerGap),
                                          Text(
                                            _monthLabels[dates[index].month - 1],
                                            style: TextStyle(
                                              color: isSelected ? Colors.white70 : Colors.grey,
                                              fontSize: fontSizeSmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: orange, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              t.selectTime,
                              style: const TextStyle(
                                color: darkBlue,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _showTimePicker,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 110,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F4F4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  selectedHour.toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: darkBlue,
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  ':',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: darkBlue,
                                  ),
                                ),
                              ),
                              Container(
                                width: 110,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F4F4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  selectedMinute.toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: darkBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Address Card
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
                                    ? Border.all(color: errorRed, width: 1.5)
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
                                      const Icon(Icons.map_outlined, color: orange, size: 22),
                                      const SizedBox(width: 10),
                                      Text(
                                        t.chooseAddress,
                                        style: const TextStyle(
                                          color: darkBlue,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
                                                  color: Colors.grey.shade400, size: 18),
                                              const SizedBox(width: 8),
                                              Text(
                                                addrState is AddressLoading
                                                    ? t.loadingAddresses
                                                    : t.tapToSelectAddress,
                                                style: TextStyle(
                                                  color: Colors.grey.shade400,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              Icon(
                                                _selectedAddress!.type == AddressType.apartment
                                                    ? Icons.apartment
                                                    : Icons.home_outlined,
                                                color: orange,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _selectedAddress!.displayTitle,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        color: darkBlue,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    Text(
                                                      _selectedAddress!.displaySubtitle,
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Icon(Icons.edit_outlined,
                                                  color: orange, size: 16),
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
                                style: const TextStyle(color: errorRed, fontSize: 12),
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

          // Continue Button
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  t.continue1,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
