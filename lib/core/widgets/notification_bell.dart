import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/network/token_storage.dart';
import 'package:helpi_admin/core/providers/data_providers.dart';
import 'package:helpi_admin/core/services/admin_api_service.dart';
import 'package:helpi_admin/features/seniors/presentation/seniors_screen.dart';
import 'package:helpi_admin/features/students/presentation/student_detail_screen.dart';

// Notifications shown here come only from persisted backend events and SignalR.
// Empty state is expected until the backend actually emits or stores an event.

const _hiddenAdminNotificationTypes = {
  NotificationType.paymentSuccess,
  NotificationType.paymentFailed,
  NotificationType.paymentRefunded,
  NotificationType.jobRequest,
  NotificationType.jobStartReminder,
  NotificationType.jobInProgress,
  NotificationType.jobCompleted,
  NotificationType.allEligibleStudentsNotified,
  NotificationType.noEligibleStudents,
  NotificationType.matchingMaxAttemptsReached,
  NotificationType.reviewRequest,
  NotificationType.contractAdded,
  NotificationType.contractUpdated,
  NotificationType.contractExpired,
  NotificationType.contractDeleted,
  NotificationType.contractAboutToExpire,
  NotificationType.orderScheduleCancelled,
  NotificationType.orderBackToProcessing,
  NotificationType.customerDeleted, // v1 artefakt: Customer → Senior u v2
  NotificationType.adminDeleted, // admin ne briše sam sebe
  NotificationType.jobRescheduled, // admin sam mijenja termin
};

List<NotificationModel> _visibleAdminNotifications(
  Iterable<NotificationModel> notifications,
) {
  return notifications
      .where(
        (notification) =>
            !_hiddenAdminNotificationTypes.contains(notification.type),
      )
      .toList();
}

/// Bell icon with unread-count badge. Opens [NotificationsDrawer].
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = _visibleAdminNotifications(
      ref.watch(notificationsProvider),
    ).where((n) => !n.isRead).length;
    return IconButton(
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(
          '$unread',
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
        backgroundColor: HelpiTheme.primary,
        child: const Icon(Icons.notifications_outlined),
      ),
      tooltip: AppStrings.notifications,
      onPressed: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: AppStrings.notifications,
          barrierColor: Colors.black38,
          transitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, anim1, anim2) => const _NotificationsDrawer(),
          transitionBuilder: (context, anim1, anim2, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
                  ),
              child: child,
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Notifications Drawer (right-side panel)
// ─────────────────────────────────────────────────────────────
class _NotificationsDrawer extends ConsumerStatefulWidget {
  const _NotificationsDrawer();

  @override
  ConsumerState<_NotificationsDrawer> createState() =>
      _NotificationsDrawerState();
}

class _NotificationsDrawerState extends ConsumerState<_NotificationsDrawer> {
  bool _archiving = false;
  bool _pillVisible = false;

  @override
  Widget build(BuildContext context) {
    final notifications = _visibleAdminNotifications(
      ref.watch(notificationsProvider),
    );
    final unreadCount = notifications.where((n) => !n.isRead).length;
    final readCount = notifications.where((n) => n.isRead).length;

    return Align(
      alignment: Alignment.centerRight,
      child: MouseRegion(
        onEnter: (_) {
          if (!_pillVisible) setState(() => _pillVisible = true);
        },
        onExit: (_) {
          if (_pillVisible && !_archiving) {
            setState(() => _pillVisible = false);
          }
        },
        child: Material(
          elevation: 8,
          child: Container(
            width: 360,
            height: double.infinity,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Stack(
              children: [
                Column(
                  children: [
                    // ── Header ──
                    Container(
                      height: HelpiTheme.appBarHeight,
                      padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                      color: Theme.of(context).colorScheme.surface,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notifications_outlined,
                            color: HelpiTheme.accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppStrings.notifications,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),

                    // ── List ──
                    Expanded(
                      child: notifications.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.notifications_off_outlined,
                                    size: 48,
                                    color: HelpiColors.of(context).border,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppStrings.noNotifications,
                                    style: TextStyle(
                                      color: HelpiColors.of(
                                        context,
                                      ).textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 64,
                              ),
                              itemCount: notifications.length,
                              separatorBuilder: (context, i) => const Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                              ),
                              itemBuilder: (context, index) {
                                final n = notifications[index];
                                return _NotificationTile(
                                  notification: n,
                                  onTap: () {
                                    if (!n.isRead) {
                                      ref
                                          .read(notificationsProvider.notifier)
                                          .markRead(n.id);
                                      final nId = int.tryParse(n.id) ?? 0;
                                      if (nId > 0) {
                                        AdminApiService().markNotificationRead(
                                          nId,
                                        );
                                      }
                                    }
                                  },
                                  onNavigate: () => _navigateToEntity(n),
                                );
                              },
                            ),
                    ),
                  ],
                ),

                // ── Floating pill bar (slides up on hover) ──
                if (notifications.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 20,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      offset: _pillVisible ? Offset.zero : const Offset(0, 2),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _pillVisible ? 1.0 : 0.0,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: HelpiColors.of(context).surface,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(20),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ── ✓✓ Mark all read (icon only) ──
                                _PillIconButton(
                                  icon: Icons.done_all,
                                  enabled: unreadCount > 0,
                                  onPressed: () async {
                                    ref
                                        .read(notificationsProvider.notifier)
                                        .markAllRead();
                                    final userId =
                                        await TokenStorage().getUserId() ?? 0;
                                    if (!mounted) return;
                                    AdminApiService().markAllNotificationsRead(
                                      userId,
                                    );
                                  },
                                ),
                                // ── Divider ──
                                Container(
                                  width: 1,
                                  height: 24,
                                  color: HelpiColors.of(context).border,
                                ),
                                // ── ☁ Arhiviraj (icon + text) ──
                                _PillTextButton(
                                  icon: Icons.cloud_upload_outlined,
                                  label: _archiving
                                      ? AppStrings.notifArchiving
                                      : AppStrings.archiveNotifications,
                                  enabled: readCount > 0 && !_archiving,
                                  onPressed: () => _archiveNotifications(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _archiveNotifications() async {
    setState(() => _archiving = true);
    final userId = await TokenStorage().getUserId() ?? 0;
    if (!mounted) return;
    final result = await AdminApiService().archiveReadNotifications(userId);
    if (!mounted) return;
    setState(() => _archiving = false);

    if (result.success) {
      final count = result.data ?? 0;
      if (count > 0) {
        // Remove archived (read) from local state
        ref.read(notificationsProvider.notifier).removeRead();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.archiveSuccess}: $count'),
            backgroundColor: HelpiTheme.accent,
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppStrings.notifArchiveEmpty)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.notifArchiveFailed),
          backgroundColor: HelpiTheme.error,
        ),
      );
    }
  }

  void _navigateToEntity(NotificationModel n) {
    final type = n.type;

    // Deleted users — info only, no navigation (entity no longer exists)
    if (type == NotificationType.studentDeleted ||
        type == NotificationType.seniorDeleted) {
      return;
    }

    // Senior-related notifications
    if (n.seniorId != null && type == NotificationType.newSeniorAdded) {
      final senior = ref
          .read(seniorsProvider)
          .where((s) => s.id == '${n.seniorId}')
          .firstOrNull;
      if (senior == null) return;
      final orders = ref
          .read(ordersProvider)
          .where((o) => o.senior.id == senior.id)
          .toList();
      Navigator.of(context).pop(); // close drawer
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SeniorDetailScreen(senior: senior, orders: orders),
        ),
      );
      return;
    }

    // Student-related notifications (including availabilityChanged)
    if (n.studentId != null &&
        (type == NotificationType.newStudentAdded ||
            type == NotificationType.availabilityChanged ||
            type == NotificationType.contractExpired ||
            type == NotificationType.contractAboutToExpire ||
            type == NotificationType.contractAdded ||
            type == NotificationType.contractUpdated)) {
      final student = ref
          .read(studentsProvider)
          .where((s) => s.id == '${n.studentId}')
          .firstOrNull;
      if (student == null) return;
      Navigator.of(context).pop(); // close drawer
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentDetailScreen(student: student),
        ),
      );
      return;
    }

    // Order-related notifications — navigate to the senior who owns the order
    if (n.orderId != null &&
        (type == NotificationType.newOrderAdded ||
            type == NotificationType.orderCancelled ||
            type == NotificationType.orderScheduleCancelled ||
            type == NotificationType.scheduleAssignmentCancelled ||
            type == NotificationType.jobCancelled ||
            type == NotificationType.jobRescheduled)) {
      final order = ref
          .read(ordersProvider)
          .where((o) => o.id == '${n.orderId}')
          .firstOrNull;
      if (order == null) return;
      final senior = ref
          .read(seniorsProvider)
          .where((s) => s.id == order.senior.id)
          .firstOrNull;
      if (senior == null) return;
      final orders = ref
          .read(ordersProvider)
          .where((o) => o.senior.id == senior.id)
          .toList();
      Navigator.of(context).pop(); // close drawer
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SeniorDetailScreen(senior: senior, orders: orders),
        ),
      );
      return;
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  Single notification tile
// ─────────────────────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onNavigate,
  });

  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconFg = _iconColor(notification.type);
    final iconBg = isDark
        ? iconFg.withValues(alpha: 0.15)
        : _iconBg(notification.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead
            ? null
            : HelpiColors.of(context).pastelTeal.withAlpha(50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon (tap to navigate) ──
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onNavigate,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _icon(notification.type),
                    size: 18,
                    color: iconFg,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ── Content ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.isRead
                                ? FontWeight.w400
                                : FontWeight.w600,
                            color: HelpiColors.of(context).textPrimary,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: HelpiTheme.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 13,
                      color: HelpiColors.of(context).textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: HelpiColors.of(context).textSecondary,
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

  static IconData _icon(NotificationType type) {
    return switch (type) {
      NotificationType.newStudentAdded => Icons.person_add_outlined,
      NotificationType.newSeniorAdded => Icons.person_add_outlined,
      NotificationType.newOrderAdded => Icons.shopping_bag_outlined,
      NotificationType.orderCancelled => Icons.shopping_bag_outlined,
      NotificationType.orderScheduleCancelled => Icons.event_busy_outlined,
      NotificationType.scheduleAssignmentCancelled => Icons.event_busy_outlined,
      NotificationType.jobCancelled => Icons.event_busy_outlined,
      NotificationType.jobRescheduled => Icons.event_repeat_outlined,
      NotificationType.contractAdded => Icons.description_outlined,
      NotificationType.contractUpdated => Icons.edit_document,
      NotificationType.contractExpired => Icons.warning_amber_rounded,
      NotificationType.contractDeleted => Icons.delete_outline,
      NotificationType.contractAboutToExpire => Icons.schedule_outlined,
      NotificationType.studentDeleted => Icons.person_remove_outlined,
      NotificationType.seniorDeleted => Icons.person_remove_outlined,
      NotificationType.customerDeleted => Icons.person_remove_outlined,
      NotificationType.adminDeleted => Icons.admin_panel_settings_outlined,
      NotificationType.availabilityChanged => Icons.schedule_outlined,
      NotificationType.orderBackToProcessing => Icons.pending_actions_outlined,
      _ => Icons.info_outline,
    };
  }

  static Color _iconColor(NotificationType type) {
    return switch (type) {
      // Added (green)
      NotificationType.newStudentAdded => HelpiTheme.statusActiveText,
      NotificationType.newSeniorAdded => HelpiTheme.statusActiveText,
      NotificationType.newOrderAdded => HelpiTheme.statusActiveText,
      NotificationType.contractAdded => HelpiTheme.statusActiveText,
      NotificationType.contractUpdated => HelpiTheme.statusActiveText,
      // Cancelled / deleted (red)
      NotificationType.orderCancelled => HelpiTheme.statusCancelledText,
      NotificationType.orderScheduleCancelled => HelpiTheme.statusCancelledText,
      NotificationType.scheduleAssignmentCancelled =>
        HelpiTheme.statusCancelledText,
      NotificationType.jobCancelled => HelpiTheme.statusCancelledText,
      NotificationType.contractDeleted => HelpiTheme.statusCancelledText,
      NotificationType.studentDeleted => HelpiTheme.statusCancelledText,
      NotificationType.seniorDeleted => HelpiTheme.statusCancelledText,
      NotificationType.customerDeleted => HelpiTheme.statusCancelledText,
      NotificationType.adminDeleted => HelpiTheme.statusCancelledText,
      // Warning / changes (orange)
      NotificationType.contractExpired => const Color(0xFFE65100),
      NotificationType.contractAboutToExpire => const Color(0xFFE65100),
      NotificationType.availabilityChanged => const Color(0xFFE65100),
      NotificationType.jobRescheduled => const Color(0xFFE65100),
      // Info
      NotificationType.orderBackToProcessing => HelpiTheme.primary,
      _ => HelpiTheme.textSecondary,
    };
  }

  static Color _iconBg(NotificationType type) {
    return switch (type) {
      // Added (green bg)
      NotificationType.newStudentAdded => HelpiTheme.statusActiveBg,
      NotificationType.newSeniorAdded => HelpiTheme.statusActiveBg,
      NotificationType.newOrderAdded => HelpiTheme.statusActiveBg,
      NotificationType.contractAdded => HelpiTheme.statusActiveBg,
      NotificationType.contractUpdated => HelpiTheme.statusActiveBg,
      // Cancelled / deleted (red bg)
      NotificationType.orderCancelled => HelpiTheme.statusCancelledBg,
      NotificationType.orderScheduleCancelled => HelpiTheme.statusCancelledBg,
      NotificationType.scheduleAssignmentCancelled =>
        HelpiTheme.statusCancelledBg,
      NotificationType.jobCancelled => HelpiTheme.statusCancelledBg,
      NotificationType.contractDeleted => HelpiTheme.statusCancelledBg,
      NotificationType.studentDeleted => HelpiTheme.statusCancelledBg,
      NotificationType.seniorDeleted => HelpiTheme.statusCancelledBg,
      NotificationType.customerDeleted => HelpiTheme.statusCancelledBg,
      NotificationType.adminDeleted => HelpiTheme.statusCancelledBg,
      // Warning / changes (orange bg)
      NotificationType.contractExpired => const Color(0xFFFFF3E0),
      NotificationType.contractAboutToExpire => const Color(0xFFFFF3E0),
      NotificationType.availabilityChanged => const Color(0xFFFFF3E0),
      NotificationType.jobRescheduled => const Color(0xFFFFF3E0),
      // Info (light blue bg)
      NotificationType.orderBackToProcessing => const Color(0xFFE3F2FD),
      _ => const Color(0xFFF5F5F5),
    };
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return AppStrings.justNow;
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} ${AppStrings.minutesAgo}';
    }
    if (diff.inHours < 24) return '${diff.inHours} ${AppStrings.hoursAgo}';
    return '${diff.inDays} ${AppStrings.daysAgo}';
  }
}

// ─────────────────────────────────────────────────────────────
//  Icon-only pill segment (left half — mark all read)
// ─────────────────────────────────────────────────────────────
class _PillIconButton extends StatelessWidget {
  const _PillIconButton({
    required this.icon,
    required this.onPressed,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(100)),
      onTap: enabled ? onPressed : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? HelpiTheme.accent
              : HelpiColors.of(context).textSecondary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Icon + text pill segment (right half — archive)
// ─────────────────────────────────────────────────────────────
class _PillTextButton extends StatelessWidget {
  const _PillTextButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? HelpiTheme.accent
        : HelpiColors.of(context).textSecondary;
    return InkWell(
      borderRadius: const BorderRadius.horizontal(right: Radius.circular(100)),
      onTap: enabled ? onPressed : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
