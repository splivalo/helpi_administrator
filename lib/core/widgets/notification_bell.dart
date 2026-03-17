import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';

// TODO: Notifications are loaded from API but table is empty. Backend needs to create notifications when actions occur (order created, student assigned, etc.)

/// Bell icon with unread-count badge. Opens [NotificationsDrawer].
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final unread = MockData.notifications.where((n) => !n.isRead).length;
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
class _NotificationsDrawer extends StatefulWidget {
  const _NotificationsDrawer();

  @override
  State<_NotificationsDrawer> createState() => _NotificationsDrawerState();
}

class _NotificationsDrawerState extends State<_NotificationsDrawer> {
  @override
  Widget build(BuildContext context) {
    final notifications = MockData.notifications;
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        elevation: 8,
        child: Container(
          width: 360,
          height: double.infinity,
          color: HelpiTheme.background,
          child: Column(
            children: [
              // ── Header ──
              Container(
                padding: const EdgeInsets.fromLTRB(16, 48, 8, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: HelpiTheme.border)),
                ),
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: HelpiTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (unreadCount > 0)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            for (final n in notifications) {
                              n.isRead = true;
                            }
                          });
                        },
                        child: Text(
                          AppStrings.markAllRead,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // ── List ──
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.notifications_off_outlined,
                              size: 48,
                              color: HelpiTheme.border,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppStrings.noNotifications,
                              style: const TextStyle(
                                color: HelpiTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: notifications.length,
                        separatorBuilder: (context, i) =>
                            const Divider(height: 1, indent: 16, endIndent: 16),
                        itemBuilder: (context, index) {
                          final n = notifications[index];
                          return _NotificationTile(
                            notification: n,
                            onTap: () {
                              if (!n.isRead) {
                                setState(() => n.isRead = true);
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Single notification tile
// ─────────────────────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead ? null : HelpiTheme.pastelTeal.withAlpha(50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon ──
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _iconBg(notification.type),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _icon(notification.type),
                size: 18,
                color: _iconColor(notification.type),
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
                            color: HelpiTheme.textPrimary,
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
                    style: const TextStyle(
                      fontSize: 13,
                      color: HelpiTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: HelpiTheme.textSecondary,
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
      NotificationType.newOrder => Icons.shopping_bag_outlined,
      NotificationType.contractExpiring => Icons.warning_amber_rounded,
      NotificationType.sessionCancelled => Icons.event_busy_outlined,
      NotificationType.info => Icons.info_outline,
    };
  }

  static Color _iconColor(NotificationType type) {
    return switch (type) {
      NotificationType.newOrder => HelpiTheme.accent,
      NotificationType.contractExpiring => const Color(0xFFE65100),
      NotificationType.sessionCancelled => HelpiTheme.statusCancelledText,
      NotificationType.info => HelpiTheme.textSecondary,
    };
  }

  static Color _iconBg(NotificationType type) {
    return switch (type) {
      NotificationType.newOrder => HelpiTheme.pastelTeal,
      NotificationType.contractExpiring => const Color(0xFFFFF3E0),
      NotificationType.sessionCancelled => HelpiTheme.statusCancelledBg,
      NotificationType.info => const Color(0xFFF5F5F5),
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
