import 'package:flutter/material.dart';

class SetAvailabilityScreen extends StatefulWidget {
  const SetAvailabilityScreen({super.key});

  @override
  State<SetAvailabilityScreen> createState() => _SetAvailabilityScreenState();
}

class _SetAvailabilityScreenState extends State<SetAvailabilityScreen> {
  // Selected days
  final Set<String> selectedDays = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri'};

  // Working hours
  int fromHour = 7;
  int fromMinute = 0;
  int toHour = 13;
  int toMinute = 0;

  final List<String> daysOfWeek = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header with illustration
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1A3A5C),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Illustration
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 60,
                        color: const Color(0xFF1A3A5C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Set Your Availability',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A3A5C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You can pause bookings anytime from your dashboard.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Working Days
                    Row(
                      children: [
                        Icon(Icons.calendar_month,
                            color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Working Days',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A3A5C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: daysOfWeek.map((day) {
                        final isSelected = selectedDays.contains(day);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedDays.remove(day);
                              } else {
                                selectedDays.add(day);
                              }
                            });
                          },
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE87722)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFE87722)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // Working Hours
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Working Hours',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A3A5C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // From
                    _buildTimeRow('from', fromHour, fromMinute, (h, m) {
                      setState(() {
                        fromHour = h;
                        fromMinute = m;
                      });
                    }),
                    const SizedBox(height: 16),

                    // To
                    _buildTimeRow('to', toHour, toMinute, (h, m) {
                      setState(() {
                        toHour = h;
                        toMinute = m;
                      });
                    }),
                  ],
                ),
              ),
            ),

            // Save button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to dashboard and remove all previous routes
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/dashboard',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE87722),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(
      String label, int hour, int minute, Function(int, int) onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildTimeInput(hour.toString().padLeft(2, '0'), () async {
          final newHour = await _showNumberPicker(context, hour, 0, 23);
          if (newHour != null) onChanged(newHour, minute);
        }),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            ':',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        _buildTimeInput(minute.toString().padLeft(2, '0'), () async {
          final newMinute = await _showNumberPicker(context, minute, 0, 59);
          if (newMinute != null) onChanged(hour, newMinute);
        }),
      ],
    );
  }

  Widget _buildTimeInput(String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A3A5C),
            ),
          ),
        ),
      ),
    );
  }

  Future<int?> _showNumberPicker(
      BuildContext context, int initial, int min, int max) async {
    int selected = initial;
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select'),
        content: SizedBox(
          height: 200,
          width: 100,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 50,
            controller: FixedExtentScrollController(initialItem: initial - min),
            onSelectedItemChanged: (index) => selected = min + index,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (index < 0 || index > max - min) return null;
                return Center(
                  child: Text(
                    (min + index).toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 24),
                  ),
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, selected),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
