import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/models/faculty.dart';
import 'package:helpi_admin/core/providers/data_providers.dart';
import 'package:helpi_admin/core/services/admin_api_service.dart';
import 'package:helpi_admin/core/utils/formatters.dart';
import 'package:helpi_admin/core/widgets/address_autocomplete_field.dart';
import 'package:helpi_admin/core/widgets/widgets.dart';
import 'package:helpi_admin/features/seniors/presentation/senior_form_helpers.dart';

/// Ekran za uređivanje postojećeg studenta (osobni podaci + dostupnost).
class EditStudentScreen extends ConsumerStatefulWidget {
  const EditStudentScreen({
    super.key,
    required this.student,
    required this.availability,
    this.isModal = false,
  });

  final StudentModel student;
  final List<DayAvailability> availability;
  final bool isModal;

  @override
  ConsumerState<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends ConsumerState<EditStudentScreen>
    with SeniorFormHelpers {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // ── Personal data ──
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  Gender? _gender;
  DateTime? _dateOfBirth;
  Faculty? _selectedFaculty;
  late String _googlePlaceId;

  // ── Availability ──
  late List<_DaySlot> _days;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _googlePlaceId = s.googlePlaceId ?? 'admin-manual-entry';

    _firstNameCtrl = TextEditingController(text: s.firstName);
    _lastNameCtrl = TextEditingController(text: s.lastName);
    _emailCtrl = TextEditingController(text: s.email);
    _phoneCtrl = TextEditingController(text: s.phone);
    _addressCtrl = TextEditingController(text: s.address);
    _gender = s.gender;
    _dateOfBirth = s.dateOfBirth.year >= 1900 ? s.dateOfBirth : null;
    _selectedFaculty =
        (s.facultyId != null ? Faculty.byId(s.facultyId!) : null) ??
        Faculty.byFullName(s.faculty);

    _days = List.generate(7, (i) {
      final dayOfWeek = i + 1;
      final match = widget.availability
          .where((a) => a.dayOfWeek == dayOfWeek)
          .firstOrNull;
      return _DaySlot(
        dayOfWeek: dayOfWeek,
        enabled: match?.isEnabled ?? false,
        from: match?.from ?? const TimeOfDay(hour: 8, minute: 0),
        to: match?.to ?? const TimeOfDay(hour: 16, minute: 0),
      );
    });
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dayLabels = [
      AppStrings.dayMonFull,
      AppStrings.dayTueFull,
      AppStrings.dayWedFull,
      AppStrings.dayThuFull,
      AppStrings.dayFriFull,
      AppStrings.daySatFull,
      AppStrings.daySunFull,
    ];

    final formBody = Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Osobni podaci ──
          buildSectionLabel(AppStrings.studentPersonalData, Icons.person),
          const SizedBox(height: 12),
          buildTextField(
            controller: _firstNameCtrl,
            label: AppStrings.studentFirstName,
            required: true,
          ),
          const SizedBox(height: 12),
          buildTextField(
            controller: _lastNameCtrl,
            label: AppStrings.studentLastName,
            required: true,
          ),
          const SizedBox(height: 12),
          buildTextField(
            controller: _emailCtrl,
            label: AppStrings.studentEmail,
            keyboardType: TextInputType.emailAddress,
            required: true,
          ),
          const SizedBox(height: 12),
          buildTextField(
            controller: _phoneCtrl,
            label: AppStrings.studentPhone,
            keyboardType: TextInputType.phone,
            required: true,
          ),
          const SizedBox(height: 12),
          AddressAutocompleteField(
            controller: _addressCtrl,
            label: AppStrings.studentAddress,
            required: true,
            onSelected: (addr) {
              _googlePlaceId = addr.placeId;
            },
          ),
          const SizedBox(height: 12),
          buildGenderSelector(
            value: _gender,
            onChanged: (g) => setState(() => _gender = g),
          ),
          const SizedBox(height: 12),
          buildDatePicker(
            label: AppStrings.studentDateOfBirth,
            value: _dateOfBirth,
            onChanged: (d) => setState(() => _dateOfBirth = d),
            defaultYear: 2000,
          ),
          const SizedBox(height: 12),
          // ── Fakultet ──
          DropdownButtonFormField<Faculty>(
            value: _selectedFaculty,
            decoration: InputDecoration(
              labelText: AppStrings.studentFaculty,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            isExpanded: true,
            items: Faculty.all
                .map(
                  (f) => DropdownMenuItem(
                    value: f,
                    child: Text(f.fullName, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (f) => setState(() => _selectedFaculty = f),
            validator: (v) => v == null ? AppStrings.fieldRequired : null,
          ),
          const SizedBox(height: 24),

          // ── Dostupnost ──
          buildSectionLabel(AppStrings.studentAvailability, Icons.schedule),
          const SizedBox(height: 12),
          ...List.generate(7, (i) {
            final day = _days[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Checkbox(
                      value: day.enabled,
                      activeColor: HelpiTheme.accent,
                      onChanged: (v) =>
                          setState(() => day.enabled = v ?? false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 110,
                    child: Text(
                      dayLabels[i],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: day.enabled
                            ? HelpiColors.of(context).textPrimary
                            : HelpiColors.of(context).textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildTimePicker(
                    enabled: day.enabled,
                    value: day.from,
                    onChanged: (t) => setState(() => day.from = t),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text('–'),
                  ),
                  _buildTimePicker(
                    enabled: day.enabled,
                    value: day.to,
                    onChanged: (t) => setState(() => day.to = t),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          // ── Save button ──
          if (widget.isModal)
            Align(
              alignment: Alignment.centerRight,
              child: ActionChipButton(
                icon: Icons.check,
                label: _saving ? AppStrings.saving : AppStrings.save,
                color: HelpiTheme.accent,
                size: ActionChipButtonSize.medium,
                onTap: _saving ? () {} : _onSave,
                loading: _saving,
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _saving ? null : _onSave,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check, size: 20),
                label: Text(_saving ? AppStrings.saving : AppStrings.save),
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
    );

    if (!widget.isModal) {
      return Scaffold(
        appBar: HelpiAppBar(
          title: Text(AppStrings.editStudentTitle),
          titleSpacing: HelpiAppBar.innerTitleSpacing,
        ),
        body: formBody,
      );
    }

    // ── Modal layout ──
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
          child: Row(
            children: [
              const Icon(Icons.edit, color: HelpiTheme.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.editStudentTitle,
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
        const Divider(height: 1),
        Expanded(child: formBody),
      ],
    );
  }

  Widget _buildTimePicker({
    required bool enabled,
    required TimeOfDay value,
    required ValueChanged<TimeOfDay> onChanged,
  }) {
    return InkWell(
      onTap: enabled
          ? () async {
              final picked = await show15MinTimePicker(context, initial: value);
              if (picked != null && mounted) onChanged(picked);
            }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled
                ? HelpiColors.of(context).border
                : HelpiColors.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          formatTimeOfDay(value),
          style: TextStyle(
            color: enabled
                ? HelpiColors.of(context).textPrimary
                : HelpiColors.of(context).textSecondary,
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_gender == null || _dateOfBirth == null) {
      showErrorSnack(context, AppStrings.fieldRequired);
      return;
    }

    setState(() => _saving = true);

    final api = AdminApiService();
    final studentId = int.tryParse(widget.student.id);

    // 1. Update contact info
    final contactId = widget.student.contactId;
    if (contactId != null) {
      final result = await api.updateContactInfo(
        contactId: contactId,
        fullName: '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}',
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        fullAddress: _addressCtrl.text.trim(),
        gender: _gender == Gender.male ? 0 : 1,
        dateOfBirth: _dateOfBirth!.toIso8601String().split('T').first,
        googlePlaceId: _googlePlaceId,
      );
      if (!mounted) return;
      if (!result.success) {
        setState(() => _saving = false);
        showErrorSnack(context, result.error ?? 'Error');
        return;
      }
    }

    // 2. Update faculty if changed
    if (studentId != null && _selectedFaculty != null) {
      final currentFacultyId = widget.student.facultyId;
      if (currentFacultyId != _selectedFaculty!.id) {
        final result = await api.updateStudentFaculty(
          studentId: studentId,
          facultyId: _selectedFaculty!.id,
        );
        if (!mounted) return;
        if (!result.success) {
          setState(() => _saving = false);
          showErrorSnack(context, result.error ?? 'Error');
          return;
        }
      }
    }

    // 3. Update availability
    if (studentId != null) {
      final enabledSlots = _days
          .where((d) => d.enabled)
          .map(
            (d) => DayAvailability(
              dayOfWeek: d.dayOfWeek,
              isEnabled: true,
              from: d.from,
              to: d.to,
            ),
          )
          .toList();
      final result = await api.updateStudentAvailability(
        studentId: studentId,
        slots: enabledSlots,
      );
      if (!mounted) return;
      if (!result.success) {
        setState(() => _saving = false);
        showErrorSnack(context, result.error ?? 'Error');
        return;
      }
    }

    // 4. Refresh students from backend (targeted — no need to reload all data)
    final sResult = await api.getStudents();
    if (!mounted) return;
    if (sResult.success && sResult.data != null) {
      AppData.students
        ..clear()
        ..addAll(sResult.data!);
      ref.read(studentsProvider.notifier).setAll(sResult.data!);
    }

    final refreshed = ref
        .read(studentsProvider)
        .where((s) => s.id == widget.student.id)
        .firstOrNull;

    // Patch dateOfBirth locally — backend may return default 0001-01-01
    // until the next GET reloads from DB. This ensures the UI shows what was saved.
    final patched = (refreshed ?? widget.student).withDateOfBirth(
      _dateOfBirth!,
    );

    setState(() => _saving = false);

    showSuccessSnack(context, AppStrings.editStudentSuccess);
    Navigator.pop(context, patched);
  }
}

class _DaySlot {
  _DaySlot({
    required this.dayOfWeek,
    required this.enabled,
    required this.from,
    required this.to,
  });

  final int dayOfWeek;
  bool enabled;
  TimeOfDay from;
  TimeOfDay to;
}
