import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/providers/data_providers.dart';
import 'package:helpi_admin/core/services/admin_api_service.dart';
import 'package:helpi_admin/core/services/data_loader.dart';
import 'package:helpi_admin/core/widgets/widgets.dart';
import 'package:helpi_admin/features/seniors/presentation/senior_form_helpers.dart';

/// Ekran za uređivanje postojećeg seniora.
class EditSeniorScreen extends ConsumerStatefulWidget {
  const EditSeniorScreen({
    super.key,
    required this.senior,
    this.isModal = false,
  });

  final SeniorModel senior;
  final bool isModal;

  @override
  ConsumerState<EditSeniorScreen> createState() => _EditSeniorScreenState();
}

class _EditSeniorScreenState extends ConsumerState<EditSeniorScreen>
    with SeniorFormHelpers {
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
    final formBody = Form(
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
            buildSectionLabel(AppStrings.seniorOrdererTitle, Icons.people),
            const SizedBox(height: 12),
            buildTextField(
              controller: _ordFirstNameCtrl,
              label: AppStrings.seniorOrdererFirstName,
              required: true,
            ),
            const SizedBox(height: 12),
            buildTextField(
              controller: _ordLastNameCtrl,
              label: AppStrings.seniorOrdererLastName,
              required: true,
            ),
            const SizedBox(height: 12),
            buildTextField(
              controller: _ordEmailCtrl,
              label: AppStrings.seniorOrdererEmail,
              keyboardType: TextInputType.emailAddress,
              required: true,
            ),
            const SizedBox(height: 12),
            buildTextField(
              controller: _ordPhoneCtrl,
              label: AppStrings.seniorOrdererPhone,
              keyboardType: TextInputType.phone,
              required: true,
            ),
            const SizedBox(height: 12),
            buildTextField(
              controller: _ordAddressCtrl,
              label: AppStrings.seniorOrdererAddress,
              required: true,
            ),
            const SizedBox(height: 12),
            buildGenderSelector(
              value: _ordGender,
              onChanged: (g) => setState(() => _ordGender = g),
            ),
            const SizedBox(height: 12),
            buildDatePicker(
              label: AppStrings.seniorOrdererDob,
              value: _ordDateOfBirth,
              onChanged: (d) => setState(() => _ordDateOfBirth = d),
            ),
            const SizedBox(height: 24),
          ],

          // ── Korisnik usluga ──
          buildSectionLabel(AppStrings.seniorServiceUser, Icons.elderly),
          const SizedBox(height: 12),
          buildTextField(
            controller: _firstNameCtrl,
            label: AppStrings.seniorFirstName,
            required: true,
          ),
          const SizedBox(height: 12),
          buildTextField(
            controller: _lastNameCtrl,
            label: AppStrings.seniorLastName,
            required: true,
          ),
          const SizedBox(height: 12),
          if (!_hasOrderer) ...[
            buildTextField(
              controller: _emailCtrl,
              label: AppStrings.seniorEmail,
              keyboardType: TextInputType.emailAddress,
              required: true,
            ),
            const SizedBox(height: 12),
          ],
          buildTextField(
            controller: _phoneCtrl,
            label: AppStrings.seniorPhone,
            keyboardType: TextInputType.phone,
            required: true,
          ),
          const SizedBox(height: 12),
          buildTextField(
            controller: _addressCtrl,
            label: AppStrings.seniorAddress,
            required: true,
          ),
          const SizedBox(height: 12),
          buildGenderSelector(
            value: _gender,
            onChanged: (g) => setState(() => _gender = g),
          ),
          const SizedBox(height: 12),
          buildDatePicker(
            label: AppStrings.seniorOrdererDob,
            value: _dateOfBirth,
            onChanged: (d) => setState(() => _dateOfBirth = d),
          ),
          const SizedBox(height: 32),

          // ── Save button ──
          if (widget.isModal)
            Align(
              alignment: Alignment.centerRight,
              child: ActionChipButton(
                icon: Icons.check,
                label: AppStrings.save,
                color: HelpiTheme.accent,
                size: ActionChipButtonSize.medium,
                onTap: _onSave,
              ),
            )
          else
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
    );

    if (!widget.isModal) {
      return Scaffold(
        appBar: HelpiAppBar(title: Text(AppStrings.editSeniorTitle)),
        body: formBody,
      );
    }

    // ── Modal layout: pinned header + scrollable form ──
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
                  AppStrings.editSeniorTitle,
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

  Future<void> _onSave() async {
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

    final api = AdminApiService();

    // Update senior contact info
    final seniorContactId = widget.senior.contactId;
    if (seniorContactId != null) {
      final result = await api.updateContactInfo(
        contactId: seniorContactId,
        fullName: '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}',
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        fullAddress: _addressCtrl.text.trim(),
        gender: _gender == Gender.male ? 0 : 1,
        dateOfBirth: _dateOfBirth!.toIso8601String().split('T').first,
      );
      if (!mounted) return;
      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Error'),
            backgroundColor: HelpiTheme.primary,
          ),
        );
        return;
      }
    }

    // Update orderer contact info if present
    if (_hasOrderer) {
      final ordererContactId = widget.senior.ordererContactId;
      if (ordererContactId != null) {
        final result = await api.updateContactInfo(
          contactId: ordererContactId,
          fullName:
              '${_ordFirstNameCtrl.text.trim()} ${_ordLastNameCtrl.text.trim()}',
          email: _ordEmailCtrl.text.trim(),
          phone: _ordPhoneCtrl.text.trim(),
          fullAddress: _ordAddressCtrl.text.trim(),
          gender: _ordGender == Gender.male ? 0 : 1,
          dateOfBirth: _ordDateOfBirth!.toIso8601String().split('T').first,
        );
        if (!mounted) return;
        if (!result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Error'),
              backgroundColor: HelpiTheme.primary,
            ),
          );
          return;
        }
      }
    }

    // Refresh data from backend
    await DataLoader.loadAll(ref: ref);
    if (!mounted) return;

    // Find refreshed senior from provider
    final refreshed = ref
        .read(seniorsProvider)
        .where((s) => s.id == widget.senior.id)
        .firstOrNull;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.editSeniorSuccess),
        backgroundColor: HelpiTheme.accent,
      ),
    );
    Navigator.pop(context, refreshed ?? widget.senior);
  }
}
