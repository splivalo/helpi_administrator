import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/utils/formatters.dart';
import 'package:helpi_admin/core/widgets/status_badges.dart';

/// Single-screen form for creating or editing an order (admin side).
///
/// When [senior] is provided the senior-picker section is skipped
/// and the order is pre-assigned to that senior (used from senior detail).
///
/// When [existingOrder] is provided the form enters **edit mode** —
/// all fields are pre-filled with the order's current data.
/// On save the existing order is updated in-place (sessions are kept).
class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key, this.senior, this.existingOrder});

  final SeniorModel? senior;
  final OrderModel? existingOrder;

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollCtrl = ScrollController();
  late final TextEditingController _notesCtrl;
  final _seniorSearchCtrl = TextEditingController();

  // ── Mode ──
  bool get _isEditMode => widget.existingOrder != null;

  // ── Senior ──
  SeniorModel? _selectedSenior;
  bool _showSeniorSearch = false;

  // ── Frequency ──
  FrequencyType _frequency = FrequencyType.oneTime;

  // ── One-time ──
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  int? _durationHours;

  // ── Recurring ──
  DateTime? _startDate;
  DateTime? _endDate;
  bool _hasEndDate = false;
  final List<_DayEntryState> _dayEntries = [];

  @override
  void initState() {
    super.initState();

    final order = widget.existingOrder;
    if (order != null) {
      // ── Edit mode: pre-fill from existing order ──
      _selectedSenior = order.senior;
      _notesCtrl = TextEditingController(text: order.notes ?? '');

      _frequency = order.frequency == FrequencyType.oneTime
          ? FrequencyType.oneTime
          : FrequencyType.recurring;

      // One-time fields
      _scheduledDate = order.scheduledDate;
      _scheduledTime = order.scheduledStart;
      _durationHours = order.durationHours;

      // Recurring fields
      _startDate = order.scheduledDate;
      _endDate = order.endDate;
      _hasEndDate = order.endDate != null;

      // Day entries
      for (final de in order.dayEntries) {
        _dayEntries.add(
          _DayEntryState(dayOfWeek: de.dayOfWeek)
            ..startHour = de.startTime.hour
            ..startMinute = de.startTime.minute
            ..durationHours = de.durationHours,
        );
      }

      // Services
      _selectedServices.addAll(order.services);
    } else {
      // ── Create mode ──
      _selectedSenior = widget.senior;
      _notesCtrl = TextEditingController();
    }
  }

  bool _showingDayPicker = false;

  // ── Services ──
  final Set<ServiceType> _selectedServices = {};

  // ── Duration options ──
  static const _durationOptions = [1, 2, 3, 4];

  // ── Time options ──
  static const _timeHours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19];
  static const _timeMinutes = [0, 15, 30, 45];

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _notesCtrl.dispose();
    _seniorSearchCtrl.dispose();
    super.dispose();
  }

  // ── Auto-scroll helper ────────────────────────
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─── Helpers ──────────────────────────────────────────────────

  String _dayName(int weekday) {
    return switch (weekday) {
      1 => AppStrings.dayMonFull,
      2 => AppStrings.dayTueFull,
      3 => AppStrings.dayWedFull,
      4 => AppStrings.dayThuFull,
      5 => AppStrings.dayFriFull,
      6 => AppStrings.daySatFull,
      7 => AppStrings.daySunFull,
      _ => '',
    };
  }

  String _dayShortName(int weekday) {
    return switch (weekday) {
      1 => AppStrings.dayMon,
      2 => AppStrings.dayTue,
      3 => AppStrings.dayWed,
      4 => AppStrings.dayThu,
      5 => AppStrings.dayFri,
      6 => AppStrings.daySat,
      7 => AppStrings.daySun,
      _ => '',
    };
  }

  List<SeniorModel> get _filteredSeniors {
    final q = _seniorSearchCtrl.text.toLowerCase();
    if (q.isEmpty) return MockData.seniors;
    return MockData.seniors
        .where((s) => s.fullName.toLowerCase().contains(q))
        .toList();
  }

  Set<int> get _usedDays => _dayEntries.map((e) => e.dayOfWeek).toSet();

  List<int> get _availableDays =>
      [1, 2, 3, 4, 5, 6, 7].where((d) => !_usedDays.contains(d)).toList();

  // ─── BUILD ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? AppStrings.editOrderTitle : AppStrings.createOrder,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollCtrl,
          padding: const EdgeInsets.all(16),
          children: [
            // ══════════════════════════════════════
            // 1) ODABERI SENIORA
            // ══════════════════════════════════════
            if (widget.senior == null && !_isEditMode) ...[
              _buildSectionLabel(AppStrings.selectSenior, Icons.elderly),
              const SizedBox(height: 12),
              _buildSeniorPicker(),
              const SizedBox(height: 24),
            ],

            // ══════════════════════════════════════
            // 2) UČESTALOST
            // ══════════════════════════════════════
            _buildSectionLabel(AppStrings.orderFrequency, Icons.repeat),
            const SizedBox(height: 12),
            _buildFrequencySelector(),
            const SizedBox(height: 24),

            // ══════════════════════════════════════
            // 3) KADA?
            // ══════════════════════════════════════
            if (_frequency == FrequencyType.oneTime)
              _buildOneTimeSection()
            else
              _buildRecurringSection(),
            const SizedBox(height: 24),

            // ══════════════════════════════════════
            // 4) USLUGE
            // ══════════════════════════════════════
            _buildSectionLabel(AppStrings.selectServices, Icons.handyman),
            const SizedBox(height: 12),
            _buildServiceChips(),
            const SizedBox(height: 24),

            // ══════════════════════════════════════
            // 5) NAPOMENA
            // ══════════════════════════════════════
            _buildSectionLabel(AppStrings.orderNotes, Icons.notes),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: AppStrings.orderNotesHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ══════════════════════════════════════
            // SAVE BUTTON
            // ══════════════════════════════════════
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _onSave,
                icon: const Icon(Icons.check, size: 20),
                label: Text(AppStrings.save),
                style: FilledButton.styleFrom(
                  backgroundColor: HelpiTheme.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      HelpiTheme.buttonRadius,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SECTION LABEL
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: HelpiTheme.accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: HelpiTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SENIOR PICKER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSeniorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected senior or tap to select
        GestureDetector(
          onTap: () => setState(() => _showSeniorSearch = !_showSeniorSearch),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
              border: Border.all(color: HelpiTheme.border),
            ),
            child: Row(
              children: [
                if (_selectedSenior != null) ...[
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: HelpiTheme.accent.withValues(alpha: 0.12),
                    child: Text(
                      _selectedSenior!.firstName[0],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: HelpiTheme.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedSenior!.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _selectedSenior!.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: HelpiTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.person_search,
                    size: 20,
                    color: HelpiTheme.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.selectSenior,
                    style: const TextStyle(
                      fontSize: 14,
                      color: HelpiTheme.textSecondary,
                    ),
                  ),
                ],
                const Spacer(),
                Icon(
                  _showSeniorSearch
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: HelpiTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),

        // Search dropdown
        if (_showSeniorSearch) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _seniorSearchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: AppStrings.selectSeniorHint,
              prefixIcon: const Icon(Icons.search, color: HelpiTheme.accent),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
              border: Border.all(color: HelpiTheme.border),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredSeniors.length,
              itemBuilder: (ctx, i) {
                final senior = _filteredSeniors[i];
                final isSelected = _selectedSenior?.id == senior.id;
                return ListTile(
                  dense: true,
                  selected: isSelected,
                  selectedTileColor: HelpiTheme.accent.withValues(alpha: 0.06),
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: HelpiTheme.accent.withValues(alpha: 0.12),
                    child: Text(
                      senior.firstName[0],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: HelpiTheme.accent,
                      ),
                    ),
                  ),
                  title: Text(
                    senior.fullName,
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    senior.address,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: HelpiTheme.accent,
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedSenior = senior;
                      _showSeniorSearch = false;
                      _seniorSearchCtrl.clear();
                    });
                    _scrollToBottom();
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  FREQUENCY SELECTOR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFrequencySelector() {
    final options = [
      (AppStrings.oneTime, FrequencyType.oneTime),
      (AppStrings.recurring, FrequencyType.recurring),
    ];
    return Row(
      children: [
        for (int i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: _buildSelectionChip(
              label: options[i].$1,
              isSelected: _frequency == options[i].$2,
              onTap: () => setState(() {
                _frequency = options[i].$2;
              }),
            ),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  ONE-TIME SECTION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildOneTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Datum
        _buildSectionLabel(AppStrings.scheduledDate, Icons.calendar_today),
        const SizedBox(height: 12),
        _buildDateButton(
          date: _scheduledDate,
          onTap: () => _pickDate(
            initial: _scheduledDate,
            onPicked: (d) {
              setState(() => _scheduledDate = d);
              _scrollToBottom();
            },
          ),
        ),

        if (_scheduledDate != null) ...[
          const SizedBox(height: 16),

          // Vrijeme
          _buildSectionLabel(AppStrings.scheduledTime, Icons.access_time),
          const SizedBox(height: 12),
          _buildTimeSelector(
            selectedHour: _scheduledTime?.hour,
            selectedMinute: _scheduledTime?.minute,
            onHourSelected: (h) {
              setState(() {
                _scheduledTime = TimeOfDay(hour: h, minute: 0);
              });
              _scrollToBottom();
            },
            onMinuteSelected: (m) {
              setState(() {
                _scheduledTime = TimeOfDay(
                  hour: _scheduledTime!.hour,
                  minute: m,
                );
              });
              _scrollToBottom();
            },
          ),

          if (_scheduledTime != null) ...[
            const SizedBox(height: 16),

            // Trajanje
            _buildSectionLabel(AppStrings.durationHoursLabel, Icons.timelapse),
            const SizedBox(height: 12),
            _buildDurationSelector(
              selected: _durationHours,
              onSelected: (d) {
                setState(() => _durationHours = d);
                _scrollToBottom();
              },
            ),
          ],
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  RECURRING SECTION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRecurringSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Start date
        _buildSectionLabel(AppStrings.scheduledDate, Icons.calendar_today),
        const SizedBox(height: 12),
        _buildDateButton(
          date: _startDate,
          onTap: () => _pickDate(
            initial: _startDate,
            onPicked: (d) {
              setState(() {
                _startDate = d;
                if (_endDate != null && _endDate!.isBefore(d)) {
                  _endDate = null;
                }
              });
              _scrollToBottom();
            },
          ),
        ),

        if (_startDate != null) ...[
          const SizedBox(height: 16),

          // Toggle end date
          Row(
            children: [
              Switch(
                value: _hasEndDate,
                activeTrackColor: HelpiTheme.accent,
                onChanged: (v) => setState(() {
                  _hasEndDate = v;
                  if (!v) _endDate = null;
                }),
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.hasEndDate,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          if (_hasEndDate) ...[
            const SizedBox(height: 8),
            _buildDateButton(
              date: _endDate,
              onTap: () => _pickDate(
                initial: _endDate ?? _startDate,
                firstDate: _startDate,
                onPicked: (d) => setState(() => _endDate = d),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Day entries (existing)
          ..._dayEntries.asMap().entries.map((e) {
            return _buildDayEntryCard(e.key, e.value);
          }),

          // Day picker — auto-show when no days yet, or after "+" tap
          if ((_dayEntries.isEmpty || _showingDayPicker) &&
              _availableDays.isNotEmpty)
            _buildDayPickerSection(),

          // "+ Dodaj dan" button — only when existing entries are complete
          if (_dayEntries.isNotEmpty &&
              !_showingDayPicker &&
              _availableDays.isNotEmpty &&
              _dayEntries.every(
                (e) => e.startHour != null && e.startMinute != null,
              ))
            _buildAddDayButton(),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  DAY ENTRY CARD (recurring)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDayEntryCard(int index, _DayEntryState entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        border: Border.all(color: HelpiTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: day name + remove
          Row(
            children: [
              Text(
                _dayName(entry.dayOfWeek),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _dayEntries.removeAt(index)),
                child: const Icon(
                  Icons.close,
                  size: 20,
                  color: HelpiTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Time selector
          _buildTimeSelector(
            selectedHour: entry.startHour,
            selectedMinute: entry.startMinute,
            onHourSelected: (h) {
              setState(() {
                entry.startHour = h;
                entry.startMinute = null;
              });
              _scrollToBottom();
            },
            onMinuteSelected: (m) {
              setState(() {
                entry.startMinute = m;
              });
              _scrollToBottom();
            },
          ),

          if (entry.startHour != null && entry.startMinute != null) ...[
            const SizedBox(height: 12),
            _buildDurationSelector(
              selected: entry.durationHours,
              onSelected: (d) {
                setState(() => entry.durationHours = d);
                _scrollToBottom();
              },
            ),
          ],
        ],
      ),
    );
  }

  // Add day chip picker (like senior app)
  Widget _buildDayPickerSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        border: Border.all(color: HelpiTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.selectDay,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              if (_dayEntries.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() => _showingDayPicker = false),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: HelpiTheme.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (int i = 0; i < _availableDays.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _buildSelectionChip(
                    label: _dayShortName(_availableDays[i]),
                    isSelected: false,
                    onTap: () {
                      setState(() {
                        _dayEntries.add(
                          _DayEntryState(dayOfWeek: _availableDays[i]),
                        );
                        _showingDayPicker = false;
                      });
                      _scrollToBottom();
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // "+ Dodaj dan" button
  Widget _buildAddDayButton() {
    return GestureDetector(
      onTap: () {
        setState(() => _showingDayPicker = true);
        _scrollToBottom();
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
          border: Border.all(color: HelpiTheme.accent, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline,
              color: HelpiTheme.accent,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              AppStrings.addDay,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: HelpiTheme.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SERVICE CHIPS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildServiceChips() {
    final allServices = ServiceType.values;
    const perRow = 3;
    final rows = <Widget>[];
    for (var i = 0; i < allServices.length; i += perRow) {
      final rowItems = allServices.sublist(
        i,
        (i + perRow > allServices.length) ? allServices.length : i + perRow,
      );
      rows.add(
        Row(
          children: [
            for (var j = 0; j < perRow; j++) ...[
              if (j > 0) const SizedBox(width: 8),
              Expanded(
                child: j < rowItems.length
                    ? _buildSelectionChip(
                        label: serviceLabel(rowItems[j]),
                        isSelected: _selectedServices.contains(rowItems[j]),
                        onTap: () {
                          setState(() {
                            if (_selectedServices.contains(rowItems[j])) {
                              _selectedServices.remove(rowItems[j]);
                            } else {
                              _selectedServices.add(rowItems[j]);
                            }
                          });
                        },
                      )
                    : const SizedBox(),
              ),
            ],
          ],
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          rows[i],
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SHARED WIDGETS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSelectionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? HelpiTheme.accent.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? HelpiTheme.accent : HelpiTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? HelpiTheme.accent : HelpiTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton({
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
          border: Border.all(color: HelpiTheme.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 18,
              color: HelpiTheme.accent,
            ),
            const SizedBox(width: 12),
            Text(
              date != null ? formatDate(date) : AppStrings.selectDate,
              style: TextStyle(
                fontSize: 14,
                color: date != null
                    ? HelpiTheme.textPrimary
                    : HelpiTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector({
    required int? selectedHour,
    required int? selectedMinute,
    required ValueChanged<int> onHourSelected,
    required ValueChanged<int> onMinuteSelected,
  }) {
    const perRow = 4;
    final hourRows = <Widget>[];
    for (var i = 0; i < _timeHours.length; i += perRow) {
      final chunk = _timeHours.sublist(
        i,
        (i + perRow > _timeHours.length) ? _timeHours.length : i + perRow,
      );
      hourRows.add(
        Row(
          children: [
            for (var j = 0; j < perRow; j++) ...[
              if (j > 0) const SizedBox(width: 8),
              Expanded(
                child: j < chunk.length
                    ? _buildSelectionChip(
                        label: '${chunk[j].toString().padLeft(2, '0')}:00',
                        isSelected: selectedHour == chunk[j],
                        onTap: () => onHourSelected(chunk[j]),
                      )
                    : const SizedBox(),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hours — rows of 4
        for (var i = 0; i < hourRows.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          hourRows[i],
        ],

        if (selectedHour != null) ...[
          const SizedBox(height: 12),
          // Minutes
          Row(
            children: [
              for (int i = 0; i < _timeMinutes.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _buildSelectionChip(
                    label: ':${_timeMinutes[i].toString().padLeft(2, '0')}',
                    isSelected: selectedMinute == _timeMinutes[i],
                    onTap: () => onMinuteSelected(_timeMinutes[i]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDurationSelector({
    required int? selected,
    required ValueChanged<int> onSelected,
  }) {
    return Row(
      children: [
        for (int i = 0; i < _durationOptions.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _buildSelectionChip(
              label: '${_durationOptions[i]}h',
              isSelected: selected == _durationOptions[i],
              onTap: () => onSelected(_durationOptions[i]),
            ),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  DATE PICKER
  // ═══════════════════════════════════════════════════════════════
  Future<void> _pickDate({
    required DateTime? initial,
    DateTime? firstDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: firstDate ?? now,
      lastDate: DateTime(now.year + 2),
    );
    if (!context.mounted) return;
    if (picked != null) onPicked(picked);
  }

  // ═══════════════════════════════════════════════════════════════
  //  SAVE
  // ═══════════════════════════════════════════════════════════════
  void _onSave() {
    if (_selectedSenior == null) {
      _showError(AppStrings.seniorRequired);
      return;
    }

    if (_selectedServices.isEmpty) {
      _showError(AppStrings.selectAtLeastOneService);
      return;
    }

    if (_frequency == FrequencyType.oneTime) {
      if (_scheduledDate == null) {
        _showError(AppStrings.dateRequired);
        return;
      }
    } else {
      if (_startDate == null) {
        _showError(AppStrings.dateRequired);
        return;
      }
      if (_dayEntries.isEmpty) {
        _showError(AppStrings.addDay);
        return;
      }
    }

    // Build shared values
    final FrequencyType freq;
    if (_frequency == FrequencyType.oneTime) {
      freq = FrequencyType.oneTime;
    } else if (_hasEndDate && _endDate != null) {
      freq = FrequencyType.recurringWithEnd;
    } else {
      freq = FrequencyType.recurring;
    }

    final DateTime scheduledDate;
    final TimeOfDay scheduledTime;
    final int duration;
    final List<DayEntry> dayEntries;

    if (_frequency == FrequencyType.oneTime) {
      scheduledDate = _scheduledDate!;
      scheduledTime = _scheduledTime ?? const TimeOfDay(hour: 10, minute: 0);
      duration = _durationHours ?? 2;
      dayEntries = [];
    } else {
      scheduledDate = _startDate!;
      // Use first day entry's time as scheduled start
      final first = _dayEntries.first;
      scheduledTime = TimeOfDay(
        hour: first.startHour ?? 10,
        minute: first.startMinute ?? 0,
      );
      duration = first.durationHours ?? 2;
      dayEntries = _dayEntries
          .map(
            (e) => DayEntry(
              dayOfWeek: e.dayOfWeek,
              startTime: TimeOfDay(
                hour: e.startHour ?? 10,
                minute: e.startMinute ?? 0,
              ),
              durationHours: e.durationHours ?? 2,
            ),
          )
          .toList();
    }

    if (_isEditMode) {
      _saveEdit(freq, scheduledDate, scheduledTime, duration, dayEntries);
    } else {
      _saveNew(freq, scheduledDate, scheduledTime, duration, dayEntries);
    }
  }

  // ── Edit mode: update existing order, keep sessions ──
  void _saveEdit(
    FrequencyType freq,
    DateTime scheduledDate,
    TimeOfDay scheduledTime,
    int duration,
    List<DayEntry> dayEntries,
  ) {
    final existing = widget.existingOrder!;

    final updated = OrderModel(
      id: existing.id,
      orderNumber: existing.orderNumber,
      senior: existing.senior,
      student: existing.student,
      status: existing.status,
      frequency: freq,
      services: _selectedServices.toList(),
      createdAt: existing.createdAt,
      scheduledDate: scheduledDate,
      scheduledStart: scheduledTime,
      durationHours: duration,
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      address: existing.senior.address,
      endDate: _endDate,
      dayEntries: dayEntries,
      sessions: existing.sessions, // keep existing sessions
    );

    final idx = MockData.orders.indexWhere((o) => o.id == updated.id);
    if (idx != -1) MockData.orders[idx] = updated;

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.editOrderSuccess),
        backgroundColor: HelpiTheme.accent,
      ),
    );
    Navigator.pop(context, updated);
  }

  // ── Create mode: generate sessions & add new order ──
  void _saveNew(
    FrequencyType freq,
    DateTime scheduledDate,
    TimeOfDay scheduledTime,
    int duration,
    List<DayEntry> dayEntries,
  ) {
    final orderNum = (MockData.orders.length + 1).toString().padLeft(4, '0');
    final orderId = 'o${MockData.orders.length + 1}';

    // Generate sessions (for one-time: 1 session, for recurring: ~4 weeks)
    final sessions = <SessionModel>[];
    if (_frequency == FrequencyType.oneTime) {
      sessions.add(
        SessionModel(
          id: '${orderId}s1',
          date: scheduledDate,
          weekday: scheduledDate.weekday,
          startTime: scheduledTime,
          durationHours: duration,
        ),
      );
    } else {
      // Generate sessions for recurring orders (next 4 weeks)
      int sessionIdx = 1;
      final end = _endDate ?? _startDate!.add(const Duration(days: 28));
      for (final entry in _dayEntries) {
        var date = _nextOccurrence(entry.dayOfWeek, _startDate!);
        while (!date.isAfter(end)) {
          sessions.add(
            SessionModel(
              id: '${orderId}s$sessionIdx',
              date: date,
              weekday: date.weekday,
              startTime: TimeOfDay(
                hour: entry.startHour ?? 10,
                minute: entry.startMinute ?? 0,
              ),
              durationHours: entry.durationHours ?? 2,
            ),
          );
          sessionIdx++;
          date = date.add(const Duration(days: 7));
        }
      }
    }

    final order = OrderModel(
      id: orderId,
      orderNumber: orderNum,
      senior: _selectedSenior!,
      status: OrderStatus.processing,
      frequency: freq,
      services: _selectedServices.toList(),
      createdAt: DateTime.now(),
      scheduledDate: scheduledDate,
      scheduledStart: scheduledTime,
      durationHours: duration,
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      address: _selectedSenior!.address,
      endDate: _endDate,
      dayEntries: dayEntries,
      sessions: sessions,
    );

    MockData.orders.add(order);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.createOrderSuccess),
        backgroundColor: HelpiTheme.accent,
      ),
    );
    Navigator.pop(context, true);
  }

  DateTime _nextOccurrence(int weekday, DateTime from) {
    final diff = (weekday - from.weekday + 7) % 7;
    return from.add(Duration(days: diff == 0 ? 0 : diff));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: HelpiTheme.primary),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  DAY ENTRY STATE (mutable for recurring)
// ═══════════════════════════════════════════════════════════════
class _DayEntryState {
  _DayEntryState({required this.dayOfWeek});

  final int dayOfWeek;
  int? startHour;
  int? startMinute;
  int? durationHours;
}
