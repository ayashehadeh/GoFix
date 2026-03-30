import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gp/features/booking/presentation/pages/bookdetails.dart';

class BookServiceScreen extends StatefulWidget {
  final String serviceName;
  final String servicePrice;
  final String description;
  final List<File> images;
  final String workerName;
  final String workerRole;

  const BookServiceScreen({
    super.key,
    required this.serviceName,
    required this.servicePrice,
    required this.description,
    required this.images,
    required this.workerName,
    required this.workerRole,
  });

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  int selectedDateIndex = 1;
  int selectedHour = 7;
  int selectedMinute = 0;
  final TextEditingController _addressController = TextEditingController();
  bool _showAddressError = false;

  static const Color darkBlue = Color(0xFF1A2B4A);
  static const Color orange = Color(0xFFFF8C00);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color lightGrey = Color(0xFFF5F5F5);

  final List<Map<String, String>> dates = const [
    {'day': 'Sun', 'date': '8', 'month': 'Feb'},
    {'day': 'Mon', 'date': '9', 'month': 'Feb'},
    {'day': 'Tue', 'date': '10', 'month': 'Feb'},
    {'day': 'Wed', 'date': '11', 'month': 'Feb'},
    {'day': 'Thu', 'date': '12', 'month': 'Feb'},
    {'day': 'Fri', 'date': '13', 'month': 'Feb'},
    {'day': 'Sat', 'date': '14', 'month': 'Feb'},
  ];

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _showTimePicker() {
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
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const Text(
                      'Select Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: darkBlue,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedHour = tempHour;
                          selectedMinute = tempMinute;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(color: orange),
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
      _showAddressError = _addressController.text.trim().isEmpty;
    });
    return !_showAddressError;
  }

  void _onContinue() {
    if (_validate()) {
      final selectedDate = dates[selectedDateIndex];
      final dateStr =
          '${selectedDate['day']}, ${selectedDate['date']} ${selectedDate['month']} 2025';
      final hour = selectedHour % 12 == 0 ? 12 : selectedHour % 12;
      final amPm = selectedHour < 12 ? 'AM' : 'PM';
      final timeStr =
          '${hour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')} $amPm';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingDetailsScreen(
            serviceName: widget.serviceName,
            servicePrice: widget.servicePrice,
            description: widget.description,
            images: widget.images,
            date: dateStr,
            time: timeStr,
            address: _addressController.text.trim(),
            workerName: widget.workerName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: darkBlue),
        title: const Text(
          'Book a Service',
          style: TextStyle(
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
                        const Row(
                          children: [
                            Icon(Icons.settings, color: orange, size: 22),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Choose Date & Time',
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Select your preferred appointment slot',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Icon(Icons.calendar_month, color: orange, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Select Date',
                              style: TextStyle(
                                color: darkBlue,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: dates.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final isSelected = index == selectedDateIndex;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => selectedDateIndex = index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 72,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? darkBlue
                                        : const Color(0xFFF4F4F4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        dates[index]['day']!,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white70
                                              : Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dates[index]['date']!,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : darkBlue,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dates[index]['month']!,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white70
                                              : Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Icon(Icons.access_time, color: orange, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Select Time',
                              style: TextStyle(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
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
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.map_outlined,
                                  color: orange,
                                  size: 22,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Choose Address',
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _addressController,
                              maxLines: 3,
                              onChanged: (_) {
                                if (_showAddressError) {
                                  setState(() => _showAddressError = false);
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Enter your address...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: _showAddressError
                                    ? const Color(0xFFFFF3F3)
                                    : const Color(0xFFF8F8F8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_showAddressError)
                        const Padding(
                          padding: EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            'Please enter your address to continue.',
                            style: TextStyle(color: errorRed, fontSize: 12),
                          ),
                        ),
                    ],
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
                child: const Text(
                  'Continue',
                  style: TextStyle(
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
