import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/core/theme/app_text_styles.dart';
import 'package:gp/features/settings/domain/entities/notification_settings_entity.dart';
import 'package:gp/features/settings/presentation/bloc/notification_settings_bloc.dart';
import 'package:gp/features/settings/presentation/widgets/notification_tile.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';

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
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryDark),
        title: Text(
          t.notificationSettings,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<NotificationSettingsBloc, NotificationSettingsState>(
        builder: (context, state) {
          if (state is NotificationSettingsLoading) {
            return _buildSkeleton();
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

          final items = _buildItems(settings, t);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isLast = index == items.length - 1;
                    return Column(
                      children: [
                        NotificationTile(
                          title: item.title,
                          subtitle: item.subtitle,
                          value: item.value,
                          onChanged: (val) {
                            context.read<NotificationSettingsBloc>().add(
                                  ToggleNotificationEvent(
                                      key: item.key, value: val),
                                );
                          },
                        ),
                        if (!isLast)
                          const Divider(
                              height: 1, indent: 16, endIndent: 16),
                      ],
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              children: List.generate(5, (i) => _SkeletonTile(isLast: i == 4)),
            ),
          ),
        ),
      ],
    );
  }

  List<_NotificationItemData> _buildItems(
          NotificationSettingsEntity s, AppLocalizations t) =>
      [
        _NotificationItemData(
          key: 'bookingConfirmations',
          title: t.bookingConfirmations,
          subtitle: t.bookingConfirmationsDesc,
          value: s.bookingConfirmations,
        ),
        _NotificationItemData(
          key: 'modificationsCancellations',
          title: t.modificationsCancellations,
          subtitle: t.modificationsCancellationsDesc,
          value: s.modificationsCancellations,
        ),
        _NotificationItemData(
          key: 'chatMessages',
          title: t.chatMessages,
          subtitle: t.chatMessagesDesc,
          value: s.chatMessages,
        ),
        _NotificationItemData(
          key: 'supportComplaints',
          title: t.supportComplaints,
          subtitle: t.supportComplaintsDesc,
          value: s.supportComplaints,
        ),
        _NotificationItemData(
          key: 'appFeedback',
          title: t.appFeedback,
          subtitle: t.appFeedbackDesc,
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

// ─── Skeleton tile ────────────────────────────────────────────────────────────

class _SkeletonTile extends StatelessWidget {
  final bool isLast;
  const _SkeletonTile({required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 13,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      width: double.infinity,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 180,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 44,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(height: 1, color: Colors.white),
      ],
    );
  }
}
