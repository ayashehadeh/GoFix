import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/availability_entity.dart';
import '../bloc/availability_bloc.dart';
import '../bloc/availability_event.dart';
import '../bloc/availability_state.dart';

class MyAvailabilityScreen extends StatelessWidget {
  const MyAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger load when screen opens
    context.read<AvailabilityBloc>().add(LoadAvailability());

    return const _MyAvailabilityView();
  }
}

class _MyAvailabilityView extends StatelessWidget {
  const _MyAvailabilityView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Availability',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: BlocConsumer<AvailabilityBloc, AvailabilityState>(
        listener: (context, state) {
          if (state is AvailabilitySaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Availability saved successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) Navigator.pop(context);
            });
          } else if (state is AvailabilityError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AvailabilityLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            );
          }

          if (state is AvailabilityLoaded) {
            return _AvailabilityForm(state: state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _AvailabilityForm extends StatelessWidget {
  final AvailabilityLoaded state;

  const _AvailabilityForm({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month,
                size: 60,
                color: AppColors.primaryOrange,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Current Availability Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Availability',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              Switch(
                value: state.isAvailable,
                onChanged: (value) {
                  context.read<AvailabilityBloc>().add(
                        UpdateAvailabilityToggle(isAvailable: value),
                      );
                },
                activeThumbColor: AppColors.primaryOrange,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Working Days
          Row(
            children: [
              const Icon(Icons.event, color: AppColors.primaryOrange, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Working Days',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.selectedDays.keys.map((day) {
              final isSelected = state.selectedDays[day]!;
              return GestureDetector(
                onTap: () {
                  context.read<AvailabilityBloc>().add(
                        UpdateWorkingDay(day: day, isSelected: !isSelected),
                      );
                },
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primaryOrange : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Working Hours
          Row(
            children: [
              const Icon(Icons.access_time,
                  color: AppColors.primaryOrange, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Working Hours',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // From
          Row(
            children: [
              const SizedBox(
                width: 60,
                child: Text(
                  'from',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              _TimePicker(
                hour: state.fromHour,
                minute: state.fromMinute,
                onChanged: (hour, minute) {
                  context.read<AvailabilityBloc>().add(
                        UpdateWorkingHours(
                          fromHour: hour,
                          fromMinute: minute,
                          toHour: state.toHour,
                          toMinute: state.toMinute,
                        ),
                      );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // To
          Row(
            children: [
              const SizedBox(
                width: 60,
                child: Text(
                  'to',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              _TimePicker(
                hour: state.toHour,
                minute: state.toMinute,
                onChanged: (hour, minute) {
                  context.read<AvailabilityBloc>().add(
                        UpdateWorkingHours(
                          fromHour: state.fromHour,
                          fromMinute: state.fromMinute,
                          toHour: hour,
                          toMinute: minute,
                        ),
                      );
                },
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // Get selected days as list
                final selectedDaysList = state.selectedDays.entries
                    .where((entry) => entry.value)
                    .map((entry) => entry.key)
                    .toList();

                final availability = AvailabilityEntity(
                  isAvailable: state.isAvailable,
                  workingDays: selectedDaysList,
                  fromHour: state.fromHour,
                  fromMinute: state.fromMinute,
                  toHour: state.toHour,
                  toMinute: state.toMinute,
                );

                context.read<AvailabilityBloc>().add(
                      SaveAvailabilityEvent(availability: availability),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
        ],
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final int hour;
  final int minute;
  final Function(int, int) onChanged;

  const _TimePicker({
    required this.hour,
    required this.minute,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Hour
        GestureDetector(
          onTap: () async {
            final selected = await showDialog<int>(
              context: context,
              builder: (context) => _TimePickerDialog(
                initialValue: hour,
                maxValue: 23,
                label: 'Hour',
              ),
            );
            if (selected != null) {
              onChanged(selected, minute);
            }
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              hour.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(':',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        // Minute
        GestureDetector(
          onTap: () async {
            final selected = await showDialog<int>(
              context: context,
              builder: (context) => _TimePickerDialog(
                initialValue: minute,
                maxValue: 59,
                label: 'Minute',
              ),
            );
            if (selected != null) {
              onChanged(hour, selected);
            }
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              minute.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimePickerDialog extends StatelessWidget {
  final int initialValue;
  final int maxValue;
  final String label;

  const _TimePickerDialog({
    required this.initialValue,
    required this.maxValue,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select $label'),
      content: SizedBox(
        width: 200,
        height: 300,
        child: ListView.builder(
          itemCount: maxValue + 1,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                index.toString().padLeft(2, '0'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: index == initialValue
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: index == initialValue
                      ? AppColors.primaryOrange
                      : Colors.black,
                ),
              ),
              onTap: () => Navigator.pop(context, index),
            );
          },
        ),
      ),
    );
  }
}
