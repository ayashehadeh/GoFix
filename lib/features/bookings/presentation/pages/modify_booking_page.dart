import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/booking.dart';
import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_event.dart';
import '../bloc/bookings_state.dart';
import 'modify_booking_success_page.dart';

// ─── Service item model (local to this flow) ──────────────────────────────────

class _ServiceItem {
  final String name;
  final String price;
  const _ServiceItem({required this.name, required this.price});
}

const _kServices = [
  _ServiceItem(name: 'Pipe Installation', price: '30-40 JD'),
  _ServiceItem(name: 'Leak Repairs', price: '25-35 JD'),
  _ServiceItem(name: 'Water Heater Service', price: '40-60 JD'),
  _ServiceItem(name: 'Drain Cleaning', price: '25-30 JD'),
  _ServiceItem(name: 'Bathroom Fixtures', price: '35-50 JD'),
  _ServiceItem(name: 'Other', price: 'TBD'),
];

// ─── Date options (matches Step 2 in design) ──────────────────────────────────

const _kDates = [
  {'day': 'Sun', 'date': '8', 'month': 'Feb'},
  {'day': 'Mon', 'date': '9', 'month': 'Feb'},
  {'day': 'Tue', 'date': '10', 'month': 'Feb'},
  {'day': 'Wed', 'date': '11', 'month': 'Feb'},
  {'day': 'Thu', 'date': '12', 'month': 'Feb'},
  {'day': 'Fri', 'date': '13', 'month': 'Feb'},
  {'day': 'Sat', 'date': '14', 'month': 'Feb'},
];

// ─── Root page (holds PageView + progress bar) ────────────────────────────────

class ModifyBookingPage extends StatefulWidget {
  final Booking booking;

  const ModifyBookingPage({super.key, required this.booking});

  @override
  State<ModifyBookingPage> createState() => _ModifyBookingPageState();
}

class _ModifyBookingPageState extends State<ModifyBookingPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0 = service, 1 = datetime/address, 2 = review

  // ── Shared state across all steps ─────────────────────────────────────────
  int? _selectedServiceIndex;
  String _description = '';
  int _selectedDateIndex = 1;
  int _selectedHour = 7;
  int _selectedMinute = 0;
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill from existing booking
    _description = widget.booking.description;
    _addressController.text = widget.booking.address;
    // Try to pre-select the matching service
    final existingIdx = _kServices.indexWhere(
        (s) => s.name == widget.booking.serviceName);
    if (existingIdx != -1) _selectedServiceIndex = existingIdx;
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
    final d = _kDates[_selectedDateIndex];
    return '${d['day']}, ${d['date']} ${d['month']} 2025';
  }

  String get _selectedTimeStr {
    final hour = _selectedHour % 12 == 0 ? 12 : _selectedHour % 12;
    final amPm = _selectedHour < 12 ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')} $amPm';
  }

  DateTime get _scheduledDateTime {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };
    final d = _kDates[_selectedDateIndex];
    return DateTime(
      2025,
      months[d['month']] ?? 1,
      int.parse(d['date']!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingsBloc, BookingsState>(
      listener: (context, state) {
        if (state is BookingModifiedSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ModifyBookingSuccessPage(),
            ),
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
      builder: (context, state) {
        final isLoading = state is BookingActionLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const BackButton(color: AppColors.primaryDark),
            title: const Text(
              'Modify Booking',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: false,
          ),
          body: Column(
            children: [
              // Progress bar (3 segments)
              _ProgressBar(currentStep: _currentStep),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentStep = i),
                  children: [
                    // Step 1 — Select service + description
                    _Step1SelectService(
                      booking: widget.booking,
                      services: _kServices,
                      selectedIndex: _selectedServiceIndex,
                      description: _description,
                      onServiceSelected: (i) =>
                          setState(() => _selectedServiceIndex = i),
                      onDescriptionChanged: (v) =>
                          setState(() => _description = v),
                      onContinue: () {
                        if (_selectedServiceIndex == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a service'),
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
                      dates: _kDates,
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
                        if (_addressController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your address'),
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
                      selectedService: _selectedServiceIndex != null
                          ? _kServices[_selectedServiceIndex!]
                          : null,
                      description: _description,
                      dateStr: _selectedDateStr,
                      timeStr: _selectedTimeStr,
                      address: _addressController.text.trim(),
                      isLoading: isLoading,
                      onSubmit: () {
                        final svc = _kServices[_selectedServiceIndex!];
                        context.read<BookingsBloc>().add(
                              ModifyBookingEvent(
                                bookingId: widget.booking.id,
                                serviceName: svc.name,
                                servicePrice: svc.price,
                                scheduledDate: _scheduledDateTime,
                                scheduledTime: _selectedTimeStr,
                                address: _addressController.text.trim(),
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
  final List<_ServiceItem> services;
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
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Professional mini card
                _ProfMiniCard(booking: widget.booking),
                const SizedBox(height: 16),

                // Service list card
                _CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.settings,
                              color: AppColors.primaryOrange, size: 18),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Select Service',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                  )),
                              Text('Choose the service you need',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      ...widget.services.asMap().entries.map((entry) {
                        final i = entry.key;
                        final svc = entry.value;
                        final isSelected = widget.selectedIndex == i;
                        final isLast = i == widget.services.length - 1;
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () => widget.onServiceSelected(i),
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
                                        svc.name,
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
                                      svc.price,
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
                                  height: 1, color: Color(0xFFF0F0F0)),
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
                          hintText: 'Describe the issue...',
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
                      // Attachment indicator (display-only from existing booking)
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
  final List<Map<String, String>> dates;
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  const Text('Select Time',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primaryDark)),
                  TextButton(
                    onPressed: () {
                      widget.onTimeChanged(tempH, tempM);
                      Navigator.pop(context);
                    },
                    child: const Text('Done',
                        style:
                            TextStyle(color: AppColors.primaryOrange)),
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
                // Date & Time card
                _CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.settings,
                              color: AppColors.primaryOrange, size: 20),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Choose Date & Time',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark)),
                              Text('Select your preferred appointment slot',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Select Date label
                      const Row(
                        children: [
                          Icon(Icons.calendar_month_outlined,
                              color: AppColors.primaryOrange, size: 20),
                          SizedBox(width: 8),
                          Text('Select Date',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Horizontal date chips
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
                            return GestureDetector(
                              onTap: () => widget.onDateSelected(i),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                width: 70,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryDark
                                      : const Color(0xFFF4F4F4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(widget.dates[i]['day']!,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: isSelected
                                                ? Colors.white70
                                                : Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text(widget.dates[i]['date']!,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : AppColors.primaryDark)),
                                    const SizedBox(height: 4),
                                    Text(widget.dates[i]['month']!,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: isSelected
                                                ? Colors.white70
                                                : Colors.grey)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Select Time label
                      const Row(
                        children: [
                          Icon(Icons.access_time_outlined,
                              color: AppColors.primaryOrange, size: 20),
                          SizedBox(width: 8),
                          Text('Select Time',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Time display
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
                              padding: EdgeInsets.symmetric(horizontal: 12),
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

                // Address card
                _CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              color: AppColors.primaryOrange, size: 20),
                          SizedBox(width: 8),
                          Text('Choose Address',
                              style: TextStyle(
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
                          hintText: 'Enter your address...',
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
  final _ServiceItem? selectedService;
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
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Booking details review card
                _CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Booking Details',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark)),
                      const SizedBox(height: 14),
                      _ReviewRow(
                          icon: Icons.settings,
                          text: selectedService?.name ??
                              booking.serviceName),
                      _ReviewRow(
                          icon: Icons.calendar_month_outlined,
                          text: dateStr),
                      _ReviewRow(
                          icon: Icons.access_time_outlined,
                          text: timeStr),
                      _ReviewRow(
                          icon: Icons.location_on_outlined, text: address),
                      _ReviewRow(
                          icon: Icons.attach_money,
                          text:
                              selectedService?.price ?? booking.servicePrice),
                      _ReviewRow(
                          icon: Icons.person,
                          text: booking.professionalName,
                          isLast: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Service description review card
                _CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              color: AppColors.primaryOrange, size: 18),
                          SizedBox(width: 8),
                          Text('Service Description',
                              style: TextStyle(
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

        // Update Booking Request button
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
                  : const Text(
                      'Update Booking Request',
                      style: TextStyle(
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
          child: const Text(
            'Continue',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
