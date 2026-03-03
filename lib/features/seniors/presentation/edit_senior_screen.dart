import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';

/// Ekran za uređivanje postojećeg seniora.
class EditSeniorScreen extends StatefulWidget {
  const EditSeniorScreen({super.key, required this.senior});

  final SeniorModel senior;

  @override
  State<EditSeniorScreen> createState() => _EditSeniorScreenState();
}

class _EditSeniorScreenState extends State<EditSeniorScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Korisnik usluga ──
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  Gender? _gender;
  DateTime? _dateOfBirth;

  // ── Naručitelj ──
  late bool _hasOrderer;
  late final TextEditingController _ordFirstNameCtrl;
  late final TextEditingController _ordLastNameCtrl;
  late final TextEditingController _ordEmailCtrl;
  late final TextEditingController _ordPhoneCtrl;
  late final TextEditingController _ordAddressCtrl;
  Gender? _ordGender;
  DateTime? _ordDateOfBirth;

  @override
  void initState() {
    super.initState();
    final s = widget.senior;

    _firstNameCtrl = TextEditingController(text: s.firstName);
    _lastNameCtrl = TextEditingController(text: s.lastName);
    _emailCtrl = TextEditingController(text: s.email);
    _phoneCtrl = TextEditingController(text: s.phone);
    _addressCtrl = TextEditingController(text: s.address);
    _gender = s.gender;
    _dateOfBirth = s.dateOfBirth;

    _hasOrderer = s.hasOrderer;
    _ordFirstNameCtrl = TextEditingController(text: s.ordererFirstName ?? '');
    _ordLastNameCtrl = TextEditingController(text: s.ordererLastName ?? '');
    _ordEmailCtrl = TextEditingController(text: s.ordererEmail ?? '');
    _ordPhoneCtrl = TextEditingController(text: s.ordererPhone ?? '');
    _ordAddressCtrl = TextEditingController(text: s.ordererAddress ?? '');
    _ordGender = s.ordererGender;
    _ordDateOfBirth = s.ordererDateOfBirth;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _ordFirstNameCtrl.dispose();
    _ordLastNameCtrl.dispose();
    _ordEmailCtrl.dispose();
    _ordPhoneCtrl.dispose();
    _ordAddressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.editSeniorTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Toggle naručitelj ──
            Row(
              children: [
                Switch(
                  value: _hasOrderer,
                  activeTrackColor: HelpiTheme.accent,
                  onChanged: (v) => setState(() => _hasOrderer = v),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.addSeniorHasOrderer,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Naručitelj sekcija ──
            if (_hasOrderer) ...[
              _buildSectionLabel(AppStrings.seniorOrdererTitle, Icons.people),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _ordFirstNameCtrl,
                label: AppStrings.seniorOrdererFirstName,
                required: true,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _ordLastNameCtrl,
                label: AppStrings.seniorOrdererLastName,
                required: true,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _ordEmailCtrl,
                label: AppStrings.seniorOrdererEmail,
                keyboardType: TextInputType.emailAddress,
                required: true,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _ordPhoneCtrl,
                label: AppStrings.seniorOrdererPhone,
                keyboardType: TextInputType.phone,
                required: true,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _ordAddressCtrl,
                label: AppStrings.seniorOrdererAddress,
                required: true,
              ),
              const SizedBox(height: 12),
              _buildGenderSelector(
                value: _ordGender,
                onChanged: (g) => setState(() => _ordGender = g),
              ),
              const SizedBox(height: 12),
              _buildDatePicker(
                label: AppStrings.seniorOrdererDob,
                value: _ordDateOfBirth,
                onChanged: (d) => setState(() => _ordDateOfBirth = d),
              ),
              const SizedBox(height: 24),
            ],

            // ── Korisnik usluga ──
            _buildSectionLabel(AppStrings.seniorServiceUser, Icons.elderly),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _firstNameCtrl,
              label: AppStrings.seniorFirstName,
              required: true,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _lastNameCtrl,
              label: AppStrings.seniorLastName,
              required: true,
            ),
            const SizedBox(height: 12),
            if (!_hasOrderer) ...[
              _buildTextField(
                controller: _emailCtrl,
                label: AppStrings.seniorEmail,
                keyboardType: TextInputType.emailAddress,
                required: true,
              ),
              const SizedBox(height: 12),
            ],
            _buildTextField(
              controller: _phoneCtrl,
              label: AppStrings.seniorPhone,
              keyboardType: TextInputType.phone,
              required: true,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _addressCtrl,
              label: AppStrings.seniorAddress,
              required: true,
            ),
            const SizedBox(height: 12),
            _buildGenderSelector(
              value: _gender,
              onChanged: (g) => setState(() => _gender = g),
            ),
            const SizedBox(height: 12),
            _buildDatePicker(
              label: AppStrings.seniorOrdererDob,
              value: _dateOfBirth,
              onChanged: (d) => setState(() => _dateOfBirth = d),
            ),
            const SizedBox(height: 32),

            // ── Save button ──
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

  // ─────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────

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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty)
                ? AppStrings.fieldRequired
                : null
          : null,
    );
  }

  Widget _buildGenderSelector({
    required Gender? value,
    required ValueChanged<Gender?> onChanged,
  }) {
    return DropdownButtonFormField<Gender>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: AppStrings.selectGender,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items: [
        DropdownMenuItem(
          value: Gender.male,
          child: Text(AppStrings.genderMale),
        ),
        DropdownMenuItem(
          value: Gender.female,
          child: Text(AppStrings.genderFemale),
        ),
      ],
      onChanged: onChanged,
      validator: (v) => v == null ? AppStrings.fieldRequired : null,
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime(1945, 1, 1),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          if (!context.mounted) return;
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
        ),
        child: Text(
          value != null
              ? '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}.'
              : AppStrings.selectDate,
          style: TextStyle(
            fontSize: 14,
            color: value != null
                ? HelpiTheme.textPrimary
                : HelpiTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    if (_gender == null || _dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.fieldRequired),
          backgroundColor: HelpiTheme.primary,
        ),
      );
      return;
    }

    if (_hasOrderer && (_ordGender == null || _ordDateOfBirth == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.fieldRequired),
          backgroundColor: HelpiTheme.primary,
        ),
      );
      return;
    }

    final updated = SeniorModel(
      id: widget.senior.id,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _hasOrderer ? _ordEmailCtrl.text.trim() : _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      gender: _gender!,
      dateOfBirth: _dateOfBirth!,
      isActive: widget.senior.isActive,
      isArchived: widget.senior.isArchived,
      createdAt: widget.senior.createdAt,
      ordererFirstName: _hasOrderer ? _ordFirstNameCtrl.text.trim() : null,
      ordererLastName: _hasOrderer ? _ordLastNameCtrl.text.trim() : null,
      ordererEmail: _hasOrderer ? _ordEmailCtrl.text.trim() : null,
      ordererPhone: _hasOrderer ? _ordPhoneCtrl.text.trim() : null,
      ordererAddress: _hasOrderer ? _ordAddressCtrl.text.trim() : null,
      ordererGender: _hasOrderer ? _ordGender : null,
      ordererDateOfBirth: _hasOrderer ? _ordDateOfBirth : null,
      creditCards: widget.senior.creditCards,
    );

    // Persist to MockData
    final idx = MockData.seniors.indexWhere((s) => s.id == updated.id);
    if (idx != -1) MockData.seniors[idx] = updated;

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.editSeniorSuccess),
        backgroundColor: HelpiTheme.accent,
      ),
    );
    Navigator.pop(context, updated);
  }
}
