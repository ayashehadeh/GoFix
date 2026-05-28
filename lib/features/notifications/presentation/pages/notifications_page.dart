import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/skeletons/notification_list_skeleton.dart';
import '../../../../core/storage/user_type_storage.dart';
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
  bool _isProfessional = false;
  String _selectedRole = 'customer';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final isPro = await UserTypeStorage.isProfessional();
    if (!mounted) return;
    setState(() => _isProfessional = isPro);
    context.read<NotificationsBloc>().add(LoadNotifications(role: 'customer'));
  }

  void _switchRole(String role) {
    if (_selectedRole == role) return;
    setState(() => _selectedRole = role);
    context.read<NotificationsBloc>().add(LoadNotifications(role: role));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          _NotificationsHeader(
            isProfessional: _isProfessional,
            selectedRole: _selectedRole,
            onRoleSwitch: _switchRole,
          ),
          Expanded(
            child: BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, state) {
                if (state is NotificationsLoading) {
                  return const NotificationListSkeleton();
                }

                if (state is NotificationsError) {
                  return _ErrorBody(
                    message: state.message,
                    onRetry: () => context.read<NotificationsBloc>().add(
                      LoadNotifications(role: _selectedRole),
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
  final bool isProfessional;
  final String selectedRole;
  final void Function(String) onRoleSwitch;

  const _NotificationsHeader({
    required this.isProfessional,
    required this.selectedRole,
    required this.onRoleSwitch,
  });

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
        bottom: isProfessional ? 16 : 20,
      ),
      child: Column(
        children: [
          Row(
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
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.notificationsTitle,
                  style: const TextStyle(
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
                  final l10n = AppLocalizations.of(context)!;
                  return GestureDetector(
                    onTap: hasUnread
                        ? () => context.read<NotificationsBloc>().add(
                              MarkAllAsReadEvent(role: selectedRole),
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
                          l10n.markAllRead,
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

          // ── Customer / Professional role tabs (only for professionals) ──
          if (isProfessional) ...[
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _RoleTab(
                    label: 'Customer',
                    isSelected: selectedRole == 'customer',
                    onTap: () => onRoleSwitch('customer'),
                  ),
                  _RoleTab(
                    label: 'Professional',
                    isSelected: selectedRole == 'professional',
                    onTap: () => onRoleSwitch('professional'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

// ─── Role tab (Customer / Professional) ──────────────────────────────────────

class _RoleTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primaryDark : Colors.white70,
            ),
          ),
        ),
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
        // All / Unread filter tabs
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
          onTap: () => context
              .read<NotificationsBloc>()
              .add(SwitchNotificationsFilter(true)),
        ),
        const SizedBox(width: 8),
        _FilterTab(
          label: 'Unread',
          isSelected: !showAll,
          onTap: () => context
              .read<NotificationsBloc>()
              .add(SwitchNotificationsFilter(false)),
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

// ─── Grouped list (Today / Yesterday / Earlier) ───────────────────────────────

class _GroupedList extends StatelessWidget {
  final List<NotificationItem> notifications;

  const _GroupedList({required this.notifications});

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
    final orderedKeys = ['Today', 'Yesterday', 'Earlier']
        .where((k) => groups.containsKey(k))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: orderedKeys.fold<int>(
        0,
        (sum, key) => sum + 1 + (groups[key]?.length ?? 0),
      ),
      itemBuilder: (context, index) {
        int cursor = 0;
        for (final key in orderedKeys) {
          final items = groups[key]!;
          if (index == cursor) {
            return _SectionHeader(label: key);
          }
          cursor++;
          if (index < cursor + items.length) {
            final item = items[index - cursor];
            return NotificationTile(
              notification: item,
              onTap: () {
                if (!item.isRead) {
                  context
                      .read<NotificationsBloc>()
                      .add(MarkAsReadEvent(item.id));
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
            showAll ? AppLocalizations.of(context)!.noNotifications : 'No unread notifications',
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
            child: Text(AppLocalizations.of(context)!.retry, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}