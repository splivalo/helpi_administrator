import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/utils/formatters.dart';
import 'package:helpi_admin/core/widgets/shared_widgets.dart';

/// Shared session preview content used by both student-detail and order-detail
/// assign flows.
///
/// Callers supply:
/// - [generateSessions] — different session-generation logic per context
/// - [findSubstitutes] — different eligibility criteria per context
/// - [buildConflictMessage] — different message (time mismatch vs order conflict)
/// - [findAltSlots] — finds alternative time slots for rescheduling
class SessionPreviewContent extends StatefulWidget {
  const SessionPreviewContent({
    super.key,
    required this.student,
    required this.order,
    required this.onBack,
    required this.onAssigned,
    required this.generateSessions,
    required this.findSubstitutes,
    required this.findAltSlots,
    required this.buildConflictMessage,
    this.useDialog = false,
  });

  final StudentModel student;
  final OrderModel order;
  final VoidCallback onBack;
  final void Function(List<SessionInstancePreview> sessions) onAssigned;
  final List<SessionInstancePreview> Function() generateSessions;
  final List<StudentModel> Function(SessionInstancePreview session)
  findSubstitutes;
  final List<TimeOfDay> Function(SessionInstancePreview session) findAltSlots;
  final String Function(SessionInstancePreview session) buildConflictMessage;
  final bool useDialog;

  @override
  State<SessionPreviewContent> createState() => _SessionPreviewContentState();
}

class _SessionPreviewContentState extends State<SessionPreviewContent> {
  late List<SessionInstancePreview> _sessions;
  int? _expandedIndex;
  String? _expandedType; // 'time' or 'substitute'

  @override
  void initState() {
    super.initState();
    _sessions = widget.generateSessions();
  }

  // ── Helpers ─────────────────────────────────────────────────

  int get _freeCount =>
      _sessions.where((s) => s.conflictType == SessionConflictType.free).length;
  int get _conflictCount => _sessions
      .where((s) => s.conflictType == SessionConflictType.conflict)
      .length;
  int get _unresolvedCount =>
      _sessions.where((s) => s.hasUnresolvedConflict).length;

  static const _dayLabelsShort = [
    'Pon',
    'Uto',
    'Sri',
    'Čet',
    'Pet',
    'Sub',
    'Ned',
  ];

  // ── Actions ─────────────────────────────────────────────────

  void _skipSession(int i) => setState(() => _sessions[i].isSkipped = true);
  void _undoSkip(int i) => setState(() => _sessions[i].isSkipped = false);

  void _toggleTimePicker(int index) {
    setState(() {
      if (_expandedIndex == index && _expandedType == 'time') {
        _expandedIndex = null;
        _expandedType = null;
      } else {
        _expandedIndex = index;
        _expandedType = 'time';
      }
    });
  }

  void _toggleSubstitutePicker(int index) {
    setState(() {
      if (_expandedIndex == index && _expandedType == 'substitute') {
        _expandedIndex = null;
        _expandedType = null;
      } else {
        _expandedIndex = index;
        _expandedType = 'substitute';
      }
    });
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
    widget.onAssigned(_sessions);
  }

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!widget.useDialog)
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 4),
            child: DragHandle(),
          ),
        // Header with back button
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: widget.onBack,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              const Icon(Icons.calendar_month, color: HelpiTheme.accent),
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
        ),
        // Sub-header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              _buildStatsBar(),
            ],
          ),
        ),
        const Divider(height: 1),
        // Session list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _sessions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _buildSessionTile(i),
          ),
        ),
        // Bottom bar
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Row(
      children: [
        _statChip(
          Icons.check_box_outlined,
          '$_freeCount',
          HelpiTheme.statusActiveBg,
          HelpiTheme.statusActiveText,
        ),
        const SizedBox(width: 8),
        if (_conflictCount > 0) ...[
          _statChip(
            Icons.warning_amber_rounded,
            '$_conflictCount',
            HelpiTheme.statusCancelledBg,
            HelpiTheme.statusCancelledText,
          ),
          const SizedBox(width: 8),
        ],
        _statChip(
          Icons.event_note,
          AppStrings.sessionCountChip(_sessions.length),
          HelpiTheme.chipBg,
          HelpiTheme.textSecondary,
        ),
      ],
    );
  }

  Widget _statChip(IconData icon, String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: fg.withAlpha(50)),
        borderRadius: BorderRadius.circular(HelpiTheme.pillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(int index) {
    final s = _sessions[index];
    final isFree = s.conflictType == SessionConflictType.free;
    final isResolved =
        s.isSkipped ||
        s.rescheduledStart != null ||
        s.substituteStudent != null;

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
      bgColor = Colors.white;
    }

    final displayStart = s.rescheduledStart ?? s.startTime;
    final endMin = toMinutes(displayStart) + s.durationHours * 60;
    final endTime = TimeOfDay(hour: endMin ~/ 60, minute: endMin % 60);

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (!isFree && !isResolved && !s.isSkipped)
                      ? HelpiTheme.statusCancelledText.withAlpha(20)
                      : HelpiTheme.accent.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _dayLabelsShort[s.weekday - 1],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: (!isFree && !isResolved && !s.isSkipped)
                        ? HelpiTheme.statusCancelledText
                        : HelpiTheme.accent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
              Text(
                '${formatTimeOfDay(displayStart)} – ${formatTimeOfDay(endTime)}',
                style: TextStyle(
                  fontSize: 13,
                  color: s.isSkipped ? HelpiTheme.textSecondary : null,
                  decoration: s.isSkipped ? TextDecoration.lineThrough : null,
                ),
              ),
              const Spacer(),
              _buildBadge(s),
            ],
          ),

          // Conflict info / resolution
          if (!isFree && !s.isSkipped) ...[
            const SizedBox(height: 8),
            if (s.rescheduledStart != null)
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 14,
                    color: HelpiTheme.accent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formatTimeOfDay(s.rescheduledStart!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: HelpiTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _actionBtn(
                    Icons.undo,
                    AppStrings.undoSkip,
                    HelpiTheme.accent,
                    () => setState(() {
                      _sessions[index].rescheduledStart = null;
                    }),
                  ),
                ],
              )
            else if (s.substituteStudent != null)
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 14,
                    color: HelpiTheme.accent,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      s.substituteStudent!.fullName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: HelpiTheme.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _actionBtn(
                    Icons.undo,
                    AppStrings.undoSkip,
                    HelpiTheme.accent,
                    () => setState(() {
                      _sessions[index].substituteStudent = null;
                    }),
                  ),
                ],
              )
            else ...[
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 14,
                    color: HelpiTheme.statusCancelledText,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.buildConflictMessage(s),
                      style: const TextStyle(
                        fontSize: 12,
                        color: HelpiTheme.statusCancelledText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
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
                    HelpiTheme.accent,
                    () => _toggleTimePicker(index),
                  ),
                  const SizedBox(width: 8),
                  _actionBtn(
                    Icons.person_add_alt_1,
                    AppStrings.findSubstitute,
                    HelpiTheme.accent,
                    () => _toggleSubstitutePicker(index),
                  ),
                ],
              ),
              // ── Inline time picker ──
              if (_expandedIndex == index && _expandedType == 'time')
                _buildInlineTimePicker(index),
              // ── Inline substitute picker ──
              if (_expandedIndex == index && _expandedType == 'substitute')
                _buildInlineSubstitutePicker(index),
            ],
          ],

          if (s.isSkipped) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.skip_next,
                  size: 14,
                  color: HelpiTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  AppStrings.sessionSkipped,
                  style: const TextStyle(
                    fontSize: 12,
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

  Widget _buildBadge(SessionInstancePreview s) {
    String label;
    Color bg;
    Color fg;
    if (s.isSkipped) {
      label = AppStrings.sessionSkipped;
      bg = HelpiTheme.chipBg;
      fg = HelpiTheme.textSecondary;
    } else if (s.rescheduledStart != null) {
      label = AppStrings.sessionRescheduled;
      bg = HelpiTheme.statusProcessingBg;
      fg = HelpiTheme.statusProcessingText;
    } else if (s.substituteStudent != null) {
      label = AppStrings.sessionSubstitute;
      bg = HelpiTheme.statusProcessingBg;
      fg = HelpiTheme.statusProcessingText;
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
        border: Border.all(color: fg.withAlpha(50)),
        borderRadius: BorderRadius.circular(HelpiTheme.pillRadius),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  // ── Inline pickers ──────────────────────────────────────────

  Widget _buildInlineTimePicker(int index) {
    final session = _sessions[index];
    final slots = widget.findAltSlots(session);
    if (slots.isEmpty) {
      return _buildEmptyInlineMessage(
        Icons.schedule,
        AppStrings.noAlternativeSlots,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.selectNewTime,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: HelpiTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: slots.map((slot) {
              final endMin = toMinutes(slot) + session.durationHours * 60;
              final end = TimeOfDay(hour: endMin ~/ 60, minute: endMin % 60);
              return Material(
                color: HelpiTheme.accent.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  hoverColor: HelpiTheme.accent.withAlpha(25),
                  splashColor: HelpiTheme.accent.withAlpha(35),
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    setState(() {
                      _sessions[index].rescheduledStart = slot;
                      _expandedIndex = null;
                      _expandedType = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: HelpiTheme.accent.withAlpha(60),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 13,
                          color: HelpiTheme.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${formatTimeOfDay(slot)} – ${formatTimeOfDay(end)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: HelpiTheme.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineSubstitutePicker(int index) {
    final session = _sessions[index];
    final subs = widget.findSubstitutes(session);
    if (subs.isEmpty) {
      return _buildEmptyInlineMessage(
        Icons.person_off,
        AppStrings.noSubstitutesAvailable,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.selectSubstitute,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: HelpiTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          ...subs.map(
            (sub) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(HelpiTheme.pillRadius),
                child: InkWell(
                  borderRadius: BorderRadius.circular(HelpiTheme.pillRadius),
                  hoverColor: HelpiTheme.accent.withAlpha(15),
                  splashColor: HelpiTheme.accent.withAlpha(25),
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    setState(() {
                      _sessions[index].substituteStudent = sub;
                      _expandedIndex = null;
                      _expandedType = null;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        HelpiTheme.pillRadius,
                      ),
                      border: Border.all(
                        color: HelpiTheme.accent.withAlpha(60),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: HelpiTheme.accent.withAlpha(30),
                          radius: 14,
                          child: Text(
                            '${sub.firstName[0]}${sub.lastName[0]}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: HelpiTheme.accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sub.fullName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${sub.avgRating}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade700,
                          ),
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
    );
  }

  Widget _buildEmptyInlineMessage(IconData icon, String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: HelpiTheme.statusCancelledBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: HelpiTheme.statusCancelledText.withAlpha(40),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: HelpiTheme.statusCancelledText),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: HelpiTheme.statusCancelledText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: color.withAlpha(20),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        hoverColor: color.withAlpha(25),
        splashColor: color.withAlpha(35),
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
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
      ),
    );
  }

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
          Align(
            alignment: Alignment.centerLeft,
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
