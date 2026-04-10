import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/widgets/widgets.dart';
import 'package:helpi_admin/core/services/admin_api_service.dart';
import 'package:helpi_admin/core/services/data_loader.dart';
import 'package:helpi_admin/features/seniors/presentation/senior_form_helpers.dart';

/// Ekran za dodavanje novog seniora.
///
/// Kad je [isModal] `true`, renderira se bez [Scaffold]
/// pa se može staviti u dialog ili bottom-sheet.
class AddSeniorScreen extends ConsumerStatefulWidget {
  const AddSeniorScreen({super.key, this.isModal = false});

  final bool isModal;

  @override
  ConsumerState<AddSeniorScreen> createState() => _AddSeniorScreenState();
}

class _AddSeniorScreenState extends ConsumerState<AddSeniorScreen>
    with SeniorFormHelpers {
  final _formKey = GlobalKey<FormState>();

  // ── Korisnik usluga ──
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  Gender? _gender;
  DateTime? _dateOfBirth;

  // ── Naručitelj ──
  bool _hasOrderer = false;
  final _ordFirstNameCtrl = TextEditingController();
  final _ordLastNameCtrl = TextEditingController();
  final _ordEmailCtrl = TextEditingController();
  final _ordPhoneCtrl = TextEditingController();
  final _ordAddressCtrl = TextEditingController();
  Gender? _ordGender;
  DateTime? _ordDateOfBirth;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _passwordCtrl.dispose();
    _ordFirstNameCtrl.dispose();
    _ordLastNameCtrl.dispose();
    _ordEmailCtrl.dispose();
    _ordPhoneCtrl.dispose();
    _ordAddressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formBody = _buildFormBody();

    if (widget.isModal) return formBody;

    return Scaffold(
      appBar: HelpiAppBar(title: Text(AppStrings.addSeniorTitle)),
      body: formBody,
    );
  }

  Widget _buildFormBody() {
    final form = Form(
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
              controller: _passwordCtrl,
              label: AppStrings.password,
              obscureText: true,
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
            buildTextField(
              controller: _passwordCtrl,
              label: AppStrings.password,
              obscureText: true,
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

    if (!widget.isModal) return form;

    // ── Modal layout: pinned header + scrollable form ──
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
          child: Row(
            children: [
              const Icon(Icons.person_add, color: HelpiTheme.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.addSeniorTitle,
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
        Expanded(child: form),
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
    final int relationship;
    final String email;

    Map<String, dynamic> buildContactInfo({
      required String firstName,
      required String lastName,
      required String phone,
      required String address,
      required int gender,
      required String dateOfBirth,
    }) {
      return {
        'fullName': '$firstName $lastName',
        'phone': phone,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        'googlePlaceId': 'admin-manual-entry',
        'fullAddress': address,
        'languageCode': 'hr',
        'country': 'Croatia',
      };
    }

    Map<String, dynamic> contactInfo;
    Map<String, dynamic>? seniorContactInfo;

    if (_hasOrderer) {
      email = _ordEmailCtrl.text.trim();
      relationship = 3; // Relative
      contactInfo = buildContactInfo(
        firstName: _ordFirstNameCtrl.text.trim(),
        lastName: _ordLastNameCtrl.text.trim(),
        phone: _ordPhoneCtrl.text.trim(),
        address: _ordAddressCtrl.text.trim(),
        gender: _ordGender == Gender.male ? 0 : 1,
        dateOfBirth: _ordDateOfBirth!.toIso8601String().split('T').first,
      );
      seniorContactInfo = buildContactInfo(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        gender: _gender == Gender.male ? 0 : 1,
        dateOfBirth: _dateOfBirth!.toIso8601String().split('T').first,
      );
    } else {
      email = _emailCtrl.text.trim();
      relationship = 0; // Self
      contactInfo = buildContactInfo(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        gender: _gender == Gender.male ? 0 : 1,
        dateOfBirth: _dateOfBirth!.toIso8601String().split('T').first,
      );
    }

    final result = await api.registerCustomer(
      email: email,
      password: _passwordCtrl.text,
      relationship: relationship,
      contactInfo: contactInfo,
      seniorContactInfo: seniorContactInfo,
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

    await DataLoader.loadAll(ref: ref);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.addSeniorSuccess),
        backgroundColor: HelpiTheme.accent,
      ),
    );
    Navigator.pop(context, true);
  }
}
