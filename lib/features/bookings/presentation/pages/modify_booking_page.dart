import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/l10n/service_name_l10n.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart' as di;
import '../../../professionals/domain/entities/service_offered.dart';
import '../../../professionals/domain/usecases/profeessional_usecases/get_professional_by_id.dart';
import '../../domain/entities/booking.dart';
import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_event.dart';
import '../bloc/bookings_state.dart';
import 'modify_booking_success_page.dart';

List<DateTime> _generateBookingDates() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return List.generate(7, (i) => today.add(Duration(days: i)));
}

// ─── Root page ────────────────────────────────────────────────────────────────

class ModifyBookingPage extends StatefulWidget {
  final Booking booking;

  const ModifyBookingPage({super.key, required this.booking});

  @override
  State<ModifyBookingPage> createState() => _ModifyBookingPageState();
}

class _ModifyBookingPageState extends State<ModifyBookingPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  int? _selectedServiceIndex;
  String _description = '';
  int _selectedDateIndex = 1;
  int _selectedHour = 7;
  int _selectedMinute = 0;
  final TextEditingController _addressController = TextEditingController();
  final List<DateTime> _dates = _generateBookingDates();

  List<ServiceOffered>? _professionalServices; // null = still loading
  bool _preSelected = false;

  @override
  void initState() {
    super.initState();
    _description = widget.booking.description;
    _addressController.text = widget.booking.address;
    _loadServices();
  }

  Future<void> _loadServices() async {
    final result = await di.sl<GetProfessionalById>()(widget.booking.professionalId);
    result.fold(
      (_) { if (mounted) setState(() => _professionalServices = []); },
      (professional) {
        if (!mounted) return;
        setState(() {
          _professionalServices = professional.services;
          if (!_preSelected) {
            _preSelected = true;
            final idx = professional.services
                .indexWhere((s) => s.name == widget.booking.serviceName);
            if (idx != -1) _selectedServiceIndex = idx;
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = step);
  }

  String get _selectedDateStr {
    final d = _dates[_selectedDateIndex];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String get _selectedTimeStr {
    final hour = _selectedHour % 12 == 0 ? 12 : _selectedHour % 12;
    final amPm = _selectedHour < 12 ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')} $amPm';
  }

  DateTime get _scheduledDateTime {
    final d = _dates[_selectedDateIndex];
    return DateTime(d.year, d.month, d.day, _selectedHour, _selectedMinute);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingsBloc, BookingsState>(
          listener: (context, state) {
            if (state is BookingModifiedSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const ModifyBookingSuccessPage()),
              );
            }
            if (state is BookingsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, bookingState) {
            final isLoading = bookingState is BookingActionLoading;
            final services = _professionalServices;

            return Scaffold(
              backgroundColor: const Color(0xFFF5F6FA),
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: const BackButton(color: AppColors.primaryDark),
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
              body: Column(
                children: [
                  _ProgressBar(currentStep: _currentStep),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (i) =>
                          setState(() => _currentStep = i),
                      children: [
                        // Step 1 — Select service + description
                        _Step1SelectService(
                          booking: widget.booking,
                          services: services,
                          selectedIndex: _selectedServiceIndex,
                          description: _description,
                          onServiceSelected: (i) =>
                              setState(() => _selectedServiceIndex = i),
                          onDescriptionChanged: (v) =>
                              setState(() => _description = v),
                          onContinue: () {
                            if (_selectedServiceIndex == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(
                                          context)!
                                      .pleaseSelectService),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }
                            _goToStep(1);
                          },
                        ),

                        // Step 2 — Date, time, address
                        _Step2DateTime(
                          dates: _dates,
                          selectedDateIndex: _selectedDateIndex,
                          selectedHour: _selectedHour,
                          selectedMinute: _selectedMinute,
                          addressController: _addressController,
                          onDateSelected: (i) =>
                              setState(() => _selectedDateIndex = i),
                          onTimeChanged: (h, m) => setState(() {
                            _selectedHour = h;
                            _selectedMinute = m;
                          }),
                          onContinue: () {
                            final selectedDate = _dates[_selectedDateIndex];
                            final today = DateTime.now();
                            final todayOnly = DateTime(today.year, today.month, today.day);
                            if (selectedDate.isBefore(todayOnly)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!.cannotBookPastDate),
                                  backgroundColor: AppColors.primaryOrange,
                                ),
                              );
                              return;
                            }
                            if (_addressController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(
                                          context)!
                                      .pleaseEnterAddress),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }
                            _goToStep(2);
                          },
                        ),

                        // Step 3 — Review + submit
                        _Step3Review(
                          booking: widget.booking,
                          selectedService:
                              (services != null && _selectedServiceIndex != null)
                                  ? services[_selectedServiceIndex!]
                                  : null,
                          description: _description,
                          dateStr: _selectedDateStr,
                          timeStr: _selectedTimeStr,
                          address: _addressController.text.trim(),
                          isLoading: isLoading,
                          onSubmit: () {
                            final svc = services![_selectedServiceIndex!];
                            context.read<BookingsBloc>().add(
                                  ModifyBookingEvent(
                                    bookingId: widget.booking.id,
                                    serviceName: svc.name,
                                    servicePrice: svc.priceDisplay,
                                    scheduledDate: _scheduledDateTime,
                                    scheduledTime: _selectedTimeStr,
                                    address:
                                        _addressController.text.trim(),
                                    description: _description,
                                  ),
                                );
                          },
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
}

// ─── Progress bar ─────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final int currentStep;

  const _ProgressBar({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i == currentStep;
          final isDone = i < currentStep;
          return Expanded(
            child: Container(
              height: 6,
              margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryOrange
                    : (isDone
                        ? AppColors.primaryDark
                        : AppColors.primaryDark),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Step 1 — Select service + description ────────────────────────────────────

class _Step1SelectService extends StatefulWidget {
  final Booking booking;
  final List<ServiceOffered>? services; // null = loading
  final int? selectedIndex;
  final String description;
  final ValueChanged<int> onServiceSelected;
  final ValueChanged<String> onDescriptionChanged;
  final VoidCallback onContinue;

  const _Step1SelectService({
    required this.booking,
    required this.services,
    required this.selectedIndex,
    required this.description,
    required this.onServiceSelected,
    required this.onDescriptionChanged,
    required this.onContinue,
  });

  @override
  State<_Step1SelectService> createState() => _Step1SelectServiceState();
}

class _Step1SelectServiceState extends State<_Step1SelectService> {
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.description);
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final services = widget.services;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ProfMiniCard(booking: widget.booking),
                const SizedBox(height: 16),

                // Service list card
                _CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.settings,
                              color: AppColors.primaryOrange, size: 18),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.selectService,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                  )),
                              Text(t.chooseService,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),

                      // Services list or loading/empty state
                      if (services == null)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primaryOrange),
                          ),
                        )
                      else if (services.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            t.noServicesListedYet,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary),
                          ),
                        )
                      else
                        ...services.asMap().entries.map((entry) {
                          final i = entry.key;
                          final svc = entry.value;
                          final isSelected = widget.selectedIndex == i;
                          final isLast = i == services.length - 1;
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    widget.onServiceSelected(i),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 14),
                                  color: isSelected
                                      ? const Color(0xFFFFF3E0)
                                      : Colors.transparent,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          localizeServiceName(svc.name,
                                              t, nameAr: svc.nameAr),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isSelected
                                                ? AppColors.primaryOrange
                                                : AppColors.primaryDark,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        svc.priceDisplay,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? AppColors.primaryOrange
                                              : AppColors.primaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!isLast)
                                const Divider(
                                    height: 1,
                                    color: Color(0xFFF0F0F0)),
                            ],
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Description card
                _CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              color: AppColors.primaryOrange, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Describe the service you need',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descCtrl,
                        maxLines: 5,
                        onChanged: widget.onDescriptionChanged,
                        decoration: InputDecoration(
                          hintText: t.describeIssuePlaceholder,
                          hintStyle: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (widget.booking.imageUrls.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.image_outlined,
                                color: AppColors.primaryDark, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.booking.imageUrls.length} picture${widget.booking.imageUrls.length > 1 ? 's' : ''} attached',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryDark),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        _ContinueButton(onTap: widget.onContinue),
      ],
    );
  }
}

// ─── Step 2 — Date, time, address ─────────────────────────────────────────────

class _Step2DateTime extends StatefulWidget {
  final List<DateTime> dates;
  final int selectedDateIndex;
  final int selectedHour;
  final int selectedMinute;
  final TextEditingController addressController;
  final ValueChanged<int> onDateSelected;
  final void Function(int hour, int minute) onTimeChanged;
  final VoidCallback onContinue;

  const _Step2DateTime({
    required this.dates,
    required this.selectedDateIndex,
    required this.selectedHour,
    required this.selectedMinute,
    required this.addressController,
    required this.onDateSelected,
    required this.onTimeChanged,
    required this.onContinue,
  });

  @override
  State<_Step2DateTime> createState() => _Step2DateTimeState();
}

class _Step2DateTimeState extends State<_Step2DateTime> {
  void _showTimePicker() {
    int tempH = widget.selectedHour;
    int tempM = widget.selectedMinute;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SizedBox(
        height: 300,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.cancel,
                        style:
                            const TextStyle(color: Colors.grey)),
                  ),
                  Text(AppLocalizations.of(context)!.selectTime,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primaryDark)),
                  TextButton(
                    onPressed: () {
                      widget.onTimeChanged(tempH, tempM);
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.done,
                        style: const TextStyle(
                            color: AppColors.primaryOrange)),
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
                          initialItem: widget.selectedHour),
                      onSelectedItemChanged: (v) => tempH = v,
                      children: List.generate(
                          24,
                          (i) => Center(
                              child: Text(i.toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                      fontSize: 22,
                                      color: AppColors.primaryDark)))),
                    ),
                  ),
                  const Text(':',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark)),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 48,
                      scrollController: FixedExtentScrollController(
                          initialItem: widget.selectedMinute),
                      onSelectedItemChanged: (v) => tempM = v,
                      children: List.generate(
                          60,
                          (i) => Center(
                              child: Text(i.toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                      fontSize: 22,
                                      color: AppColors.primaryDark)))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.settings,
                              color: AppColors.primaryOrange, size: 20),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  AppLocalizations.of(context)!
                                      .chooseDateTime,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark)),
                              Text(
                                  AppLocalizations.of(context)!
                                      .selectPreferredSlot,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined,
                              color: AppColors.primaryOrange, size: 20),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.selectDate,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 88,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.dates.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final isSelected =
                                i == widget.selectedDateIndex;
                            const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            const monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                            final date = widget.dates[i];
                            final today = DateTime.now();
                            final todayOnly = DateTime(today.year, today.month, today.day);
                            final isPast = date.isBefore(todayOnly);
                            return GestureDetector(
                              onTap: () => widget.onDateSelected(i),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                width: 70,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryDark
                                      : isPast
                                          ? const Color(0xFFE0E0E0)
                                          : const Color(0xFFF4F4F4),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(dayLabels[date.weekday - 1],
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: isSelected
                                                ? Colors.white70
                                                : isPast
                                                    ? Colors.grey.shade400
                                                    : Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text(date.day.toString(),
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : isPast
                                                    ? Colors.grey.shade400
                                                    : AppColors.primaryDark)),
                                    const SizedBox(height: 4),
                                    Text(monthLabels[date.month - 1],
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: isSelected
                                                ? Colors.white70
                                                : isPast
                                                    ? Colors.grey.shade400
                                                    : Colors.grey)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.access_time_outlined,
                              color: AppColors.primaryOrange, size: 20),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.selectTime,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _showTimePicker,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _TimeBox(
                                value: widget.selectedHour
                                    .toString()
                                    .padLeft(2, '0')),
                            const Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 12),
                              child: Text(':',
                                  style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark)),
                            ),
                            _TimeBox(
                                value: widget.selectedMinute
                                    .toString()
                                    .padLeft(2, '0')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: AppColors.primaryOrange, size: 20),
                          const SizedBox(width: 8),
                          Text(
                              AppLocalizations.of(context)!.chooseAddress,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: widget.addressController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context)!.enterAddress,
                          hintStyle: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        _ContinueButton(onTap: widget.onContinue),
      ],
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String value;
  const _TimeBox({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}

// ─── Step 3 — Review & submit ─────────────────────────────────────────────────

class _Step3Review extends StatelessWidget {
  final Booking booking;
  final ServiceOffered? selectedService;
  final String description;
  final String dateStr;
  final String timeStr;
  final String address;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _Step3Review({
    required this.booking,
    required this.selectedService,
    required this.description,
    required this.dateStr,
    required this.timeStr,
    required this.address,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final svc = selectedService;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.bookingDetails,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark)),
                      const SizedBox(height: 14),
                      _ReviewRow(
                          icon: Icons.settings,
                          text: localizeServiceName(
                              svc?.name ?? booking.serviceName,
                              t,
                              nameAr: svc?.nameAr ?? booking.serviceNameAr)),
                      _ReviewRow(
                          icon: Icons.calendar_month_outlined,
                          text: dateStr),
                      _ReviewRow(
                          icon: Icons.access_time_outlined, text: timeStr),
                      _ReviewRow(
                          icon: Icons.location_on_outlined, text: address),
                      _ReviewRow(
                          icon: Icons.attach_money,
                          text: svc?.priceDisplay ?? booking.servicePrice),
                      _ReviewRow(
                          icon: Icons.person,
                          text: booking.professionalName,
                          isLast: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.edit_outlined,
                              color: AppColors.primaryOrange, size: 18),
                          const SizedBox(width: 8),
                          Text(t.serviceDescription,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4A4A4A),
                            height: 1.6),
                      ),
                      if (booking.imageUrls.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.image_outlined,
                                color: AppColors.primaryDark, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${booking.imageUrls.length} picture${booking.imageUrls.length > 1 ? 's' : ''} attached',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryDark),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      t.updateBookingRequest,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLast;

  const _ReviewRow({
    required this.icon,
    required this.text,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryOrange, size: 18),
              const SizedBox(width: 14),
              Expanded(
                child: Text(text,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.primaryDark)),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFF0F0F0)),
      ],
    );
  }
}

// ─── Shared building blocks ───────────────────────────────────────────────────

class _ProfMiniCard extends StatelessWidget {
  final Booking booking;

  const _ProfMiniCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE0E8F0),
            backgroundImage: booking.professionalImageUrl != null
                ? NetworkImage(booking.professionalImageUrl!)
                : null,
            child: booking.professionalImageUrl == null
                ? const Icon(Icons.person,
                    color: AppColors.primaryDark, size: 24)
                : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(booking.professionalName,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark)),
              const SizedBox(height: 2),
              Text(booking.professionalRole,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;

  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ContinueButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text(
            AppLocalizations.of(context)!.continue1,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
