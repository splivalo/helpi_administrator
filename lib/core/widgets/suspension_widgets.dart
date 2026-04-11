import 'package:flutter/material.dart';
import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/suspension_models.dart';
import 'package:helpi_admin/core/network/api_client.dart';
import 'package:helpi_admin/core/network/api_endpoints.dart';
import 'package:helpi_admin/core/utils/formatters.dart' as fmt;
import 'package:helpi_admin/core/widgets/widgets.dart';

/// Card showing the suspension history timeline with suspend/activate action.
class SuspensionHistoryCard extends StatelessWidget {
  const SuspensionHistoryCard({
    super.key,
    required this.status,
    this.onSuspend,
    this.onActivate,
  });
  final UserSuspensionStatus status;
  final VoidCallback? onSuspend;
  final VoidCallback? onActivate;

  @override
  Widget build(BuildContext context) {
    final isSuspended = status.isSuspended;
    return SectionCard(
      title: AppStrings.suspensionHistory,
      icon: Icons.history,
      children: [
        if (onSuspend != null || onActivate != null) ...[
          ActionChipButton(
            icon: isSuspended ? Icons.check_circle : Icons.block,
            label: isSuspended ? AppStrings.activate : AppStrings.suspend,
            color: isSuspended ? HelpiTheme.accent : HelpiTheme.error,
            onTap: () => isSuspended ? onActivate?.call() : onSuspend?.call(),
          ),
          const SizedBox(height: 12),
        ],
        if (status.suspensionHistory.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 36,
                    color: HelpiColors.of(context).border,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.noSuspensionHistory,
                    style: TextStyle(
                      color: HelpiColors.of(context).textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...status.suspensionHistory.map((l) => _buildLogEntry(context, l)),
      ],
    );
  }

  Widget _buildLogEntry(BuildContext context, SuspensionLogModel log) {
    final isSuspension = log.action == SuspensionAction.suspended;
    final color = isSuspension ? HelpiTheme.error : HelpiTheme.accent;
    final icon = isSuspension ? Icons.block : Icons.check_circle;
    final label = isSuspension
        ? AppStrings.actionSuspended
        : AppStrings.actionActivated;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${fmt.formatDate(log.createdAt)} ${fmt.formatTime(log.createdAt)}',
                      style: TextStyle(
                        color: HelpiColors.of(context).textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (log.reason != null && log.reason!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(log.reason!, style: const TextStyle(fontSize: 13)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge shown in AppBar when user is suspended.
class SuspendedBadge extends StatelessWidget {
  const SuspendedBadge({super.key});

  @override
  Widget build(BuildContext context) => StatusBadge.suspended();
}

/// Shows suspend reason input dialog. Returns the reason or null if cancelled.
Future<String?> showSuspendDialog(BuildContext context, String userName) async {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(AppStrings.suspendConfirmTitle),
      content: SizedBox(
        width: 400,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.suspendConfirmMsg(userName)),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                maxLength: 500,
                maxLines: 3,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  labelText: AppStrings.suspensionReason,
                  hintText: AppStrings.suspensionReasonHint,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.suspensionReasonRequired;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(AppStrings.cancel),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: HelpiTheme.error),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(ctx, controller.text.trim());
            }
          },
          child: Text(AppStrings.suspend),
        ),
      ],
    ),
  );
}

/// Helper to load suspension status from API.
Future<UserSuspensionStatus?> loadSuspensionStatus(
  ApiClient api,
  int userId,
) async {
  try {
    final response = await api.get(ApiEndpoints.suspensionStatus(userId));
    return UserSuspensionStatus.fromJson(response.data as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}

/// Helper to suspend a user via API. Returns null on success, or error message.
Future<String?> suspendUserApi(ApiClient api, int userId, String reason) async {
  try {
    await api.post(ApiEndpoints.suspendUser(userId), data: {'reason': reason});
    return null;
  } catch (e) {
    debugPrint('[suspendUserApi] ERROR: $e');
    return e.toString();
  }
}

/// Helper to activate a user via API. Returns null on success, or error message.
Future<String?> activateUserApi(ApiClient api, int userId) async {
  try {
    await api.post(ApiEndpoints.activateUser(userId));
    return null;
  } catch (e) {
    debugPrint('[activateUserApi] ERROR: $e');
    return e.toString();
  }
}
