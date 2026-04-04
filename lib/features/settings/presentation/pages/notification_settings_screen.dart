import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/core/theme/app_text_styles.dart';
import 'package:gp/features/settings/domain/entities/notification_settings_entity.dart';
import 'package:gp/features/settings/presentation/bloc/notification_settings_bloc.dart';
import 'package:gp/features/settings/presentation/widgets/notification_tile.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<NotificationSettingsBloc>()
        .add(const GetNotificationSettingsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications Settings',
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<NotificationSettingsBloc, NotificationSettingsState>(
        builder: (context, state) {
          if (state is NotificationSettingsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            );
          }
          if (state is NotificationSettingsError) {
            return Center(
              child: Text(state.message, style: AppTextStyles.bodySmall),
            );
          }

          NotificationSettingsEntity? settings;
          if (state is NotificationSettingsLoaded) {
            settings = state.settings;
          } else if (state is NotificationSettingsUpdateSuccess) {
            settings = state.settings;
          } else if (state is NotificationSettingsUpdating) {
            settings = state.settings;
          }

          if (settings == null) return const SizedBox();

          final items = _buildItems(settings);

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return NotificationTile(
                title: item.title,
                subtitle: item.subtitle,
                value: item.value,
                onChanged: (val) {
                  context.read<NotificationSettingsBloc>().add(
                        ToggleNotificationEvent(key: item.key, value: val),
                      );
                },
              );
            },
          );
        },
      ),
    );
  }

  List<_NotificationItemData> _buildItems(NotificationSettingsEntity s) => [
        _NotificationItemData(
          key: 'bookingConfirmations',
          title: 'Booking Confirmations',
          subtitle:
              'Get notified when a professional accepts your service request.',
          value: s.bookingConfirmations,
        ),
        _NotificationItemData(
          key: 'modificationsCancellations',
          title: 'Modifications & Cancellations',
          subtitle:
              'Alerts if a booking is changed or cancelled by the professional.',
          value: s.modificationsCancellations,
        ),
        _NotificationItemData(
          key: 'chatMessages',
          title: 'Chat Messages',
          subtitle:
              'Notifications for new direct messages from your service provider.',
          value: s.chatMessages,
        ),
        _NotificationItemData(
          key: 'supportComplaints',
          title: 'Support & Complaints',
          subtitle:
              'Notifications regarding the status of a reported issue or complaint.',
          value: s.supportComplaints,
        ),
        _NotificationItemData(
          key: 'appFeedback',
          title: 'App Feedback',
          subtitle:
              'Occasional alerts to rate your experience or provide feedback on the app.',
          value: s.appFeedback,
        ),
      ];
}

class _NotificationItemData {
  final String key;
  final String title;
  final String subtitle;
  final bool value;

  _NotificationItemData({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.value,
  });
}
