import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/storage/user_type_storage.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/availability_entity.dart';
import '../bloc/availability_bloc.dart';
import '../bloc/availability_event.dart';
import '../bloc/availability_state.dart';

class MyAvailabilityScreen extends StatelessWidget {
  const MyAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AvailabilityBloc>().add(LoadAvailability());
    return const _MyAvailabilityView();
  }
}

class _MyAvailabilityView extends StatelessWidget {
  const _MyAvailabilityView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
        listener: (context, state) async {
          if (state is AvailabilitySaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Availability saved successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            await UserTypeStorage.setAsProfessional('');
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted)
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/dashboard', (_) => false);
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
    final isSaving = state is AvailabilitySaving;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      size: 50,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Availability Toggle ───────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Available for bookings',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.isAvailable
                                ? 'Clients can book you'
                                : 'Clients cannot book you',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      state is AvailabilityTogglingAvailability
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryOrange,
                              ),
                            )
                          : Switch(
                              value: state.isAvailable,
                              onChanged: (value) {
                                context.read<AvailabilityBloc>().add(
                                      ToggleAvailabilityEvent(
                                          isAvailable: value),
                                    );
                              },
                              activeColor: AppColors.primaryOrange,
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Working Days + Per-Day Hours ──────────────────────────
                Row(
                  children: const [
                    Icon(Icons.event, color: AppColors.primaryOrange, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Working Schedule',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tap a day to enable it, then set your hours.',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // One row per day
                ...AvailabilityEntity.orderedDays.map((day) {
                  final isWorking = state.isWorkingDay(day);
                  final schedule = state.scheduleFor(day);
                  final shortLabel = AvailabilityEntity.shortDayLabels[
                      AvailabilityEntity.orderedDays.indexOf(day)];

                  return _DayRow(
                    day: day,
                    shortLabel: shortLabel,
                    isWorking: isWorking,
                    schedule: schedule,
                    onToggle: () => context
                        .read<AvailabilityBloc>()
                        .add(ToggleWorkingDay(day: day)),
                    onTimeChanged: (open, close) =>
                        context.read<AvailabilityBloc>().add(UpdateDaySchedule(
                              day: day,
                              openTime: open,
                              closeTime: close,
                            )),
                  );
                }),
              ],
            ),
          ),
        ),

        // ── Save Button ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () => context
                      .read<AvailabilityBloc>()
                      .add(SaveWorkingHoursEvent()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                disabledBackgroundColor:
                    AppColors.primaryOrange.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Save Schedule',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Day Row ───────────────────────────────────────────────────────────────────

class _DayRow extends StatelessWidget {
  final String day;
  final String shortLabel;
  final bool isWorking;
  final DaySchedule? schedule;
  final VoidCallback onToggle;
  final void Function(String openTime, String closeTime) onTimeChanged;

  const _DayRow({
    required this.day,
    required this.shortLabel,
    required this.isWorking,
    required this.schedule,
    required this.onToggle,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWorking ? AppColors.primaryOrange : AppColors.divider,
          width: isWorking ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Day toggle row
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Day chip
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isWorking
                          ? AppColors.primaryOrange
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      shortLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            isWorking ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Day name + time summary
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isWorking
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                        if (isWorking && schedule != null)
                          Text(
                            '${schedule!.openTime} – ${schedule!.closeTime}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        if (!isWorking)
                          const Text(
                            'Day off',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    isWorking
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isWorking
                        ? AppColors.primaryOrange
                        : AppColors.textSecondary,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // Time pickers — only shown when day is enabled
          if (isWorking && schedule != null) ...[
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 16, color: AppColors.primaryOrange),
                  const SizedBox(width: 8),
                  _TimeButton(
                    label: 'From',
                    time: schedule!.openTime,
                    onTap: () async {
                      final picked =
                          await _pickTime(context, schedule!.openTime);
                      if (picked != null) {
                        onTimeChanged(picked, schedule!.closeTime);
                      }
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('–',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 16)),
                  ),
                  _TimeButton(
                    label: 'To',
                    time: schedule!.closeTime,
                    onTap: () async {
                      final picked =
                          await _pickTime(context, schedule!.closeTime);
                      if (picked != null) {
                        onTimeChanged(schedule!.openTime, picked);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Opens Flutter's time picker and returns "HH:mm" string or null.
  Future<String?> _pickTime(BuildContext context, String currentTime) async {
    final parts = currentTime.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (picked == null) return null;
    final h = picked.hour.toString().padLeft(2, '0');
    final m = picked.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── Time Button ───────────────────────────────────────────────────────────────

class _TimeButton extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;

  const _TimeButton({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryOrange.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryOrange.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
