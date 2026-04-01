import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/notification_item.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          const _NotificationsHeader(),
          Expanded(
            child: BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, state) {
                if (state is NotificationsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  );
                }

                if (state is NotificationsError) {
                  return _ErrorBody(
                    message: state.message,
                    onRetry: () => context.read<NotificationsBloc>().add(
                      LoadNotifications(),
                    ),
                  );
                }

                if (state is NotificationsLoaded) {
                  return _NotificationsBody(state: state);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 8,
        right: 16,
        bottom: 20,
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),

          // Title
          const Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),

          // Mark all button
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              final hasUnread =
                  state is NotificationsLoaded && state.unreadCount > 0;
              return GestureDetector(
                onTap: hasUnread
                    ? () => context.read<NotificationsBloc>().add(
                        MarkAllAsReadEvent(),
                      )
                    : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check,
                      color: hasUnread ? Colors.white : Colors.white38,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Mark all',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: hasUnread ? Colors.white : Colors.white38,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Filter tabs + grouped list ───────────────────────────────────────────────

class _NotificationsBody extends StatelessWidget {
  final NotificationsLoaded state;

  const _NotificationsBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final visible = state.visibleNotifications;

    return Column(
      children: [
        // Filter tabs
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: _FilterTabRow(showAll: state.showAll),
        ),

        // List
        Expanded(
          child: visible.isEmpty
              ? _EmptyBody(showAll: state.showAll)
              : _GroupedList(notifications: visible),
        ),
      ],
    );
  }
}

// ─── All / Unread tab toggle ──────────────────────────────────────────────────

class _FilterTabRow extends StatelessWidget {
  final bool showAll;

  const _FilterTabRow({required this.showAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterTab(
          label: 'All',
          isSelected: showAll,
          onTap: () => context.read<NotificationsBloc>().add(
            SwitchNotificationsFilter(true),
          ),
        ),
        const SizedBox(width: 8),
        _FilterTab(
          label: 'Unread',
          isSelected: !showAll,
          onTap: () => context.read<NotificationsBloc>().add(
            SwitchNotificationsFilter(false),
          ),
        ),
      ],
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Grouped list (Yesterday / Earlier) ──────────────────────────────────────

class _GroupedList extends StatelessWidget {
  final List<NotificationItem> notifications;

  const _GroupedList({required this.notifications});

  /// Groups notifications by date label: "Today", "Yesterday", "Earlier"
  Map<String, List<NotificationItem>> _group(List<NotificationItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<NotificationItem>> groups = {};

    for (final item in items) {
      final itemDate = DateTime(
        item.createdAt.year,
        item.createdAt.month,
        item.createdAt.day,
      );

      final String label;
      if (itemDate == today) {
        label = 'Today';
      } else if (itemDate == yesterday) {
        label = 'Yesterday';
      } else {
        label = 'Earlier';
      }

      groups.putIfAbsent(label, () => []).add(item);
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _group(notifications);

    // Maintain display order: Today → Yesterday → Earlier
    final orderedKeys = [
      'Today',
      'Yesterday',
      'Earlier',
    ].where((k) => groups.containsKey(k)).toList();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: orderedKeys.fold<int>(
        0,
        (sum, key) => sum + 1 + (groups[key]?.length ?? 0),
      ),
      itemBuilder: (context, index) {
        // Flatten groups into a single index space
        int cursor = 0;
        for (final key in orderedKeys) {
          final items = groups[key]!;
          if (index == cursor) {
            // Section header
            return _SectionHeader(label: key);
          }
          cursor++;
          if (index < cursor + items.length) {
            final item = items[index - cursor];
            return NotificationTile(
              notification: item,
              onTap: () {
                if (!item.isRead) {
                  context.read<NotificationsBloc>().add(
                    MarkAsReadEvent(item.id),
                  );
                }
              },
            );
          }
          cursor += items.length;
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyBody extends StatelessWidget {
  final bool showAll;

  const _EmptyBody({required this.showAll});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 56,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            showAll ? 'No notifications yet' : 'No unread notifications',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error state ──────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
