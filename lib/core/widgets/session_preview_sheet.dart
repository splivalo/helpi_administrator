import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/providers/data_providers.dart';
import 'package:helpi_admin/core/utils/formatters.dart';
import 'package:helpi_admin/core/widgets/shared_widgets.dart';

// ═══════════════════════════════════════════════════════════════
//  SESSION PREVIEW SHEET
//  Generates session instances for the next 8 weeks and shows
//  conflict status with action buttons per session.
// ═══════════════════════════════════════════════════════════════

/// Number of weeks to preview for recurring orders.
const int _previewWeeks = 8;

/// Shows a bottom sheet with session preview for assigning [student] to [order].
void showSessionPreviewSheet({
  required BuildContext context,
  required StudentModel student,
  required OrderModel order,
  required VoidCallback onAssigned,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return _SessionPreviewSheet(
        student: student,
        order: order,
        onAssigned: () {
          Navigator.pop(ctx);
          onAssigned();
        },
      );
    },
  );
}

class _SessionPreviewSheet extends ConsumerStatefulWidget {
  const _SessionPreviewSheet({
    required this.student,
    required this.order,
    required this.onAssigned,
  });

  final StudentModel student;
  final OrderModel order;
  final VoidCallback onAssigned;

  @override
  ConsumerState<_SessionPreviewSheet> createState() =>
      _SessionPreviewSheetState();
}

class _SessionPreviewSheetState extends ConsumerState<_SessionPreviewSheet> {
  /// Minutes of travel buffer between two consecutive Helpi sessions.
  static const _buffer = 15;

  late List<SessionInstancePreview> _sessions;

  @override
  void initState() {
    super.initState();
    _sessions = _generateSessions();
  }

  // ── Generate session instances ──────────────────────────────

  List<SessionInstancePreview> _generateSessions() {
    final order = widget.order;
    final student = widget.student;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Gather student's existing assigned orders (non-cancelled)
    final studentOrders = ref
        .read(ordersProvider)
        .where(
          (o) =>
              o.student?.id == student.id &&
              o.status != OrderStatus.cancelled &&
              o.id != order.id,
        )
        .toList();

    if (order.frequency == FrequencyType.oneTime) {
      // One-time: single session
      final conflict = _findConflict(
        date: order.scheduledDate,
        weekday: order.scheduledDate.weekday,
        startMin: _toMinutes(order.scheduledStart),
        endMin: _toMinutes(order.scheduledStart) + order.durationHours * 60,
        studentOrders: studentOrders,
      );
      return [
        SessionInstancePreview(
          date: order.scheduledDate,
          weekday: order.scheduledDate.weekday,
          startTime: order.scheduledStart,
          durationHours: order.durationHours,
          conflictType: conflict != null
              ? SessionConflictType.conflict
              : SessionConflictType.free,
          conflictingOrder: conflict,
        ),
      ];
    }

    // Recurring: generate next N weeks from dayEntries
    final List<SessionInstancePreview> result = [];

    for (final entry in order.dayEntries) {
      // Find next occurrence of this weekday from today
      var nextDate = today;
      while (nextDate.weekday != entry.dayOfWeek) {
        nextDate = nextDate.add(const Duration(days: 1));
      }

      for (int week = 0; week < _previewWeeks; week++) {
        final sessionDate = nextDate.add(Duration(days: week * 7));

        // Skip if past endDate
        if (order.endDate != null && sessionDate.isAfter(order.endDate!)) break;

        final startMin = _toMinutes(entry.startTime);
        final endMin = startMin + entry.durationHours * 60;

        final conflict = _findConflict(
          date: sessionDate,
          weekday: entry.dayOfWeek,
          startMin: startMin,
          endMin: endMin,
          studentOrders: studentOrders,
        );

        result.add(
          SessionInstancePreview(
            date: sessionDate,
            weekday: entry.dayOfWeek,
            startTime: entry.startTime,
            durationHours: entry.durationHours,
            conflictType: conflict != null
                ? SessionConflictType.conflict
                : SessionConflictType.free,
            conflictingOrder: conflict,
          ),
        );
      }
    }

    // Sort by date
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  // ── Conflict detection ──────────────────────────────────────

  /// Returns the conflicting order if the proposed session overlaps, else null.
  OrderModel? _findConflict({
    required DateTime date,
    required int weekday,
    required int startMin,
    required int endMin,
    required List<OrderModel> studentOrders,
  }) {
    for (final existing in studentOrders) {
      if (existing.dayEntries.isNotEmpty) {
        // Existing is recurring — check if any dayEntry matches this weekday
        for (final entry in existing.dayEntries) {
          if (entry.dayOfWeek == weekday) {
            final exStart = _toMinutes(entry.startTime);
            final exEnd = exStart + entry.durationHours * 60;
            if (_timesOverlap(
              startMin,
              endMin,
              exStart - _buffer,
              exEnd + _buffer,
            )) {
              return existing;
            }
          }
        }
      } else {
        // Existing is one-time — check exact date match
        if (_sameDate(existing.scheduledDate, date)) {
          final exStart = _toMinutes(existing.scheduledStart);
          final exEnd = exStart + existing.durationHours * 60;
          if (_timesOverlap(
            startMin,
            endMin,
            exStart - _buffer,
            exEnd + _buffer,
          )) {
            return existing;
          }
        }
      }
    }
    return null;
  }

  // ── Find substitute students ────────────────────────────────

  List<StudentModel> _findSubstitutes(SessionInstancePreview session) {
    return ref.read(studentsProvider).where((s) {
      if (s.id == widget.student.id) return false;
      // Check if this student has the weekday available
      final avail = s.availability.where(
        (a) => a.dayOfWeek == session.weekday && a.isEnabled,
      );
      if (avail.isEmpty) return false;
      final a = avail.first;
      final aFrom = _toMinutes(a.from);
      final aTo = _toMinutes(a.to);
      final sStart = _toMinutes(session.startTime);
      final sEnd = sStart + session.durationHours * 60;
      if (aFrom > sStart || aTo < sEnd) return false;

      // Also check the substitute doesn't have a conflict at this time
      final subOrders = ref
          .read(ordersProvider)
          .where(
            (o) => o.student?.id == s.id && o.status != OrderStatus.cancelled,
          );
      for (final o in subOrders) {
        if (o.dayEntries.isNotEmpty) {
          for (final entry in o.dayEntries) {
            if (entry.dayOfWeek == session.weekday) {
              final exStart = _toMinutes(entry.startTime);
              final exEnd = exStart + entry.durationHours * 60;
              if (_timesOverlap(
                sStart,
                sEnd,
                exStart - _buffer,
                exEnd + _buffer,
              )) {
                return false;
              }
            }
          }
        } else if (_sameDate(o.scheduledDate, session.date)) {
          final exStart = _toMinutes(o.scheduledStart);
          final exEnd = exStart + o.durationHours * 60;
          if (_timesOverlap(sStart, sEnd, exStart - _buffer, exEnd + _buffer)) {
            return false;
          }
        }
      }
      return true;
    }).toList();
  }

  // ── Find alternative free slots ─────────────────────────────

  List<TimeOfDay> _findAlternativeSlots(SessionInstancePreview session) {
    final avail = widget.student.availability.where(
      (a) => a.dayOfWeek == session.weekday && a.isEnabled,
    );
    if (avail.isEmpty) return [];

    final a = avail.first;
    final availFrom = _toMinutes(a.from);
    final availTo = _toMinutes(a.to);
    final duration = session.durationHours * 60;

    // Collect all busy intervals on this weekday
    final busyIntervals = <({int start, int end})>[];
    final studentOrders = ref
        .read(ordersProvider)
        .where(
          (o) =>
              o.student?.id == widget.student.id &&
              o.status != OrderStatus.cancelled,
        );
    for (final o in studentOrders) {
      if (o.dayEntries.isNotEmpty) {
        for (final entry in o.dayEntries) {
          if (entry.dayOfWeek == session.weekday) {
            final s = _toMinutes(entry.startTime);
            busyIntervals.add((
              start: s - _buffer,
              end: s + entry.durationHours * 60 + _buffer,
            ));
          }
        }
      } else if (session.date.weekday == o.scheduledDate.weekday &&
          _sameDate(o.scheduledDate, session.date)) {
        final s = _toMinutes(o.scheduledStart);
        busyIntervals.add((
          start: s - _buffer,
          end: s + o.durationHours * 60 + _buffer,
        ));
      }
    }
    busyIntervals.sort((a, b) => a.start.compareTo(b.start));

    // Find free slots that fit the duration
    final List<TimeOfDay> slots = [];
    int cursor = availFrom;
    for (final busy in busyIntervals) {
      if (cursor + duration <= busy.start) {
        // There's a free slot before this busy interval
        slots.add(TimeOfDay(hour: cursor ~/ 60, minute: cursor % 60));
      }
      if (busy.end > cursor) cursor = busy.end;
    }
    // Check remaining time after last busy interval
    if (cursor + duration <= availTo) {
      slots.add(TimeOfDay(hour: cursor ~/ 60, minute: cursor % 60));
    }

    // Remove the original conflicting time
    slots.removeWhere(
      (t) =>
          t.hour == session.startTime.hour &&
          t.minute == session.startTime.minute,
    );

    return slots;
  }

  // ── Time helpers ────────────────────────────────────────────

  static int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  static bool _timesOverlap(int s1, int e1, int s2, int e2) =>
      s1 < e2 && s2 < e1;

  static bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ── Stats ───────────────────────────────────────────────────

  int get _freeCount =>
      _sessions.where((s) => s.conflictType == SessionConflictType.free).length;

  int get _conflictCount => _sessions
      .where((s) => s.conflictType == SessionConflictType.conflict)
      .length;

  int get _unresolvedCount =>
      _sessions.where((s) => s.hasUnresolvedConflict).length;

  // ── Actions ─────────────────────────────────────────────────

  void _skipSession(int index) {
    setState(() => _sessions[index].isSkipped = true);
  }

  void _undoSkip(int index) {
    setState(() => _sessions[index].isSkipped = false);
  }

  void _reschedule(int index, TimeOfDay newTime) {
    setState(() => _sessions[index].rescheduledStart = newTime);
  }

  void _assignSubstitute(int index, StudentModel sub) {
    setState(() => _sessions[index].substituteStudent = sub);
  }

  void _showTimePickerSheet(int index) {
    final session = _sessions[index];
    final slots = _findAlternativeSlots(session);

    if (slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.noSubstitutesAvailable),
          backgroundColor: HelpiTheme.error,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppStrings.selectNewTime,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Divider(height: 1),
              ...slots.map((slot) {
                final endMin = _toMinutes(slot) + session.durationHours * 60;
                final endTime = TimeOfDay(
                  hour: endMin ~/ 60,
                  minute: endMin % 60,
                );
                return ListTile(
                  leading: const Icon(
                    Icons.access_time,
                    color: HelpiTheme.accent,
                  ),
                  title: Text(
                    '${formatTimeOfDay(slot)} – ${formatTimeOfDay(endTime)}',
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _reschedule(index, slot);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showSubstituteSheet(int index) {
    final session = _sessions[index];
    final subs = _findSubstitutes(session);

    if (subs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.noSubstitutesAvailable),
          backgroundColor: HelpiTheme.error,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppStrings.selectSubstitute,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Divider(height: 1),
              ...subs.map((sub) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: HelpiTheme.pastelTeal,
                    radius: 18,
                    child: Text(
                      '${sub.firstName[0]}${sub.lastName[0]}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: HelpiTheme.accent,
                      ),
                    ),
                  ),
                  title: Text(sub.fullName),
                  subtitle: Text(
                    '⭐ ${sub.avgRating.toStringAsFixed(1)}  •  ${sub.completedJobs} ${AppStrings.studentCompletedJobs.toLowerCase()}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _assignSubstitute(index, sub);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _confirmAssign() {
    if (_unresolvedCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.unresolvedConflicts),
          backgroundColor: HelpiTheme.error,
        ),
      );
      return;
    }
    widget.onAssigned();
  }

  // ── Day label (short) ───────────────────────────────────────

  static String _dayLabel(int weekday) {
    const labels = ['Pon', 'Uto', 'Sri', 'Čet', 'Pet', 'Sub', 'Ned'];
    return labels[weekday - 1];
  }

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: HelpiTheme.scaffold,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              const Padding(
                padding: EdgeInsets.only(top: 12, bottom: 4),
                child: DragHandle(),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: HelpiTheme.accent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppStrings.sessionPreviewTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Sub-header: order + student info
                    Text(
                      '#${widget.order.orderNumber} '
                      '${widget.order.senior.fullName}  →  '
                      '${widget.student.fullName}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: HelpiTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Stats bar
                    _buildStatsBar(),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Session list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _sessions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _buildSessionTile(i),
                ),
              ),

              // Bottom action bar
              _buildBottomBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsBar() {
    return Row(
      children: [
        _statChip(
          '✅ $_freeCount',
          HelpiTheme.statusActiveBg,
          HelpiTheme.statusActiveText,
        ),
        const SizedBox(width: 8),
        if (_conflictCount > 0) ...[
          _statChip(
            '⚠️ $_conflictCount',
            HelpiTheme.statusCancelledBg,
            HelpiTheme.statusCancelledText,
          ),
          const SizedBox(width: 8),
        ],
        _statChip(
          '${_sessions.length} ${AppStrings.sessionPreviewWeeks.toLowerCase()}',
          HelpiTheme.chipBg,
          HelpiTheme.textSecondary,
        ),
      ],
    );
  }

  Widget _statChip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  // ── Session tile ────────────────────────────────────────────

  Widget _buildSessionTile(int index) {
    final s = _sessions[index];
    final isFree = s.conflictType == SessionConflictType.free;
    final isResolved =
        s.isSkipped ||
        s.rescheduledStart != null ||
        s.substituteStudent != null;

    // Determine tile colors
    Color borderColor;
    Color bgColor;
    if (s.isSkipped) {
      borderColor = HelpiTheme.border;
      bgColor = HelpiTheme.chipBg;
    } else if (isFree || isResolved) {
      borderColor = HelpiTheme.statusActiveText.withAlpha(80);
      bgColor = Colors.white;
    } else {
      borderColor = HelpiTheme.statusCancelledText.withAlpha(120);
      bgColor = HelpiTheme.statusCancelledBg;
    }

    final endMin =
        _toMinutes(s.rescheduledStart ?? s.startTime) + s.durationHours * 60;
    final endTime = TimeOfDay(hour: endMin ~/ 60, minute: endMin % 60);
    final displayStart = s.rescheduledStart ?? s.startTime;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Date + Status
          Row(
            children: [
              // Day label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: HelpiTheme.accent.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _dayLabel(s.weekday),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: HelpiTheme.accent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Date
              Text(
                formatDate(s.date),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: s.isSkipped ? TextDecoration.lineThrough : null,
                  color: s.isSkipped ? HelpiTheme.textSecondary : null,
                ),
              ),
              const SizedBox(width: 8),
              // Time
              Text(
                '${formatTimeOfDay(displayStart)} – ${formatTimeOfDay(endTime)}',
                style: TextStyle(
                  fontSize: 13,
                  color: s.isSkipped ? HelpiTheme.textSecondary : null,
                  decoration: s.isSkipped ? TextDecoration.lineThrough : null,
                ),
              ),
              const Spacer(),
              // Status badge
              _buildStatusBadge(s, isResolved),
            ],
          ),

          // Row 2: Conflict info or resolution info
          if (!isFree && !s.isSkipped) ...[
            const SizedBox(height: 8),
            if (s.rescheduledStart != null) ...[
              _resolutionInfo(
                Icons.schedule,
                '${AppStrings.sessionRescheduled}: '
                '${formatTimeOfDay(s.rescheduledStart!)}',
                HelpiTheme.statusProcessingText,
              ),
            ] else if (s.substituteStudent != null) ...[
              _resolutionInfo(
                Icons.person_outline,
                '${AppStrings.sessionSubstitute}: '
                '${s.substituteStudent!.fullName}',
                HelpiTheme.accent,
              ),
            ] else ...[
              // Unresolved conflict
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 14,
                    color: HelpiTheme.statusCancelledText,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${AppStrings.conflictWith} '
                      '#${s.conflictingOrder?.orderNumber ?? "?"} '
                      '${s.conflictingOrder?.senior.fullName ?? ""}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: HelpiTheme.statusCancelledText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Action buttons
              Row(
                children: [
                  _actionBtn(
                    Icons.skip_next,
                    AppStrings.skipSession,
                    HelpiTheme.textSecondary,
                    () => _skipSession(index),
                  ),
                  const SizedBox(width: 8),
                  _actionBtn(
                    Icons.schedule,
                    AppStrings.changeTime,
                    HelpiTheme.statusProcessingText,
                    () => _showTimePickerSheet(index),
                  ),
                  const SizedBox(width: 8),
                  _actionBtn(
                    Icons.person_add_alt_1,
                    AppStrings.findSubstitute,
                    HelpiTheme.accent,
                    () => _showSubstituteSheet(index),
                  ),
                ],
              ),
            ],
          ],

          // Skipped → undo
          if (s.isSkipped) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  AppStrings.sessionSkipped,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: HelpiTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                _actionBtn(
                  Icons.undo,
                  AppStrings.undoSkip,
                  HelpiTheme.accent,
                  () => _undoSkip(index),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(SessionInstancePreview s, bool isResolved) {
    String label;
    Color bg;
    Color fg;

    if (s.isSkipped) {
      label = AppStrings.sessionSkipped;
      bg = HelpiTheme.chipBg;
      fg = HelpiTheme.textSecondary;
    } else if (s.rescheduledStart != null) {
      final isNarrow = MediaQuery.sizeOf(context).width < 600;
      label = isNarrow
          ? AppStrings.sessionRescheduledShort
          : AppStrings.sessionRescheduled;
      bg = HelpiTheme.statusProcessingBg;
      fg = HelpiTheme.statusProcessingText;
    } else if (s.substituteStudent != null) {
      label = AppStrings.sessionSubstitute;
      bg = HelpiTheme.pastelTeal;
      fg = HelpiTheme.accent;
    } else if (s.conflictType == SessionConflictType.free) {
      label = AppStrings.sessionFree;
      bg = HelpiTheme.statusActiveBg;
      fg = HelpiTheme.statusActiveText;
    } else {
      label = AppStrings.sessionConflict;
      bg = HelpiTheme.statusCancelledBg;
      fg = HelpiTheme.statusCancelledText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _resolutionInfo(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 12, color: color)),
        ),
      ],
    );
  }

  Widget _actionBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom bar ──────────────────────────────────────────────

  Widget _buildBottomBar() {
    final hasUnresolved = _unresolvedCount > 0;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: HelpiTheme.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasUnresolved) ...[
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: HelpiTheme.statusCancelledText,
                ),
                const SizedBox(width: 6),
                Text(
                  '${AppStrings.unresolvedConflicts} ($_unresolvedCount)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: HelpiTheme.statusCancelledText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            child: ActionChipButton(
              icon: Icons.check_circle,
              label: AppStrings.confirmAssign,
              color: hasUnresolved
                  ? HelpiTheme.textSecondary
                  : HelpiTheme.accent,
              size: ActionChipButtonSize.medium,
              onTap: _confirmAssign,
            ),
          ),
        ],
      ),
    );
  }
}
