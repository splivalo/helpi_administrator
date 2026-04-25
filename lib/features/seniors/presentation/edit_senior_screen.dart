import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/providers/data_providers.dart';
import 'package:helpi_admin/core/services/admin_api_service.dart';
import 'package:helpi_admin/core/widgets/address_autocomplete_field.dart';
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

  // Password (optional — admin can set/reset)
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  bool _isSaving = false;

  // Google Place IDs for address autocomplete
  late String _seniorGooglePlaceId;
  late String _ordererGooglePlaceId;

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
    _dateOfBirth = s.dateOfBirth.year >= 1900 ? s.dateOfBirth : null;

    _seniorGooglePlaceId = s.googlePlaceId ?? 'admin-manual-entry';
    _ordererGooglePlaceId = s.ordererGooglePlaceId ?? 'admin-manual-entry';

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
    _passwordCtrl.dispose();
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
              HelpiSwitch(
                value: _hasOrderer,
                onChanged: (v) {
                  setState(() {
                    _hasOrderer = v;
                    // Pre-fill orderer fields with senior data (same person before split)
                    if (v && !widget.senior.hasOrderer) {
                      _ordFirstNameCtrl.text = _firstNameCtrl.text;
                      _ordLastNameCtrl.text = _lastNameCtrl.text;
                      _ordEmailCtrl.text = _emailCtrl.text;
                      _ordPhoneCtrl.text = _phoneCtrl.text;
                      _ordAddressCtrl.text = _addressCtrl.text;
                      _ordGender = _gender;
                      _ordDateOfBirth = _dateOfBirth;
                      _ordererGooglePlaceId = _seniorGooglePlaceId;
                    }
                  });
                },
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
            AddressAutocompleteField(
              controller: _ordAddressCtrl,
              label: AppStrings.seniorOrdererAddress,
              required: true,
              onSelected: (addr) {
                _ordererGooglePlaceId = addr.placeId;
              },
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
          AddressAutocompleteField(
            controller: _addressCtrl,
            label: AppStrings.seniorAddress,
            required: true,
            onSelected: (addr) {
              _seniorGooglePlaceId = addr.placeId;
            },
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

          // ── Lozinka (samo kad ima naručitelja) ──
          if (_hasOrderer) ...[
            const SizedBox(height: 24),
            buildSectionLabel(AppStrings.setPasswordLabel, Icons.lock_outline),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: AppStrings.setPasswordLabel,
                hintText: AppStrings.setPasswordHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),

          // ── Save button ──
          if (widget.isModal)
            Align(
              alignment: Alignment.centerRight,
              child: ActionChipButton(
                icon: Icons.check,
                label: _isSaving ? AppStrings.saving : AppStrings.save,
                color: HelpiTheme.accent,
                size: ActionChipButtonSize.medium,
                onTap: _isSaving ? () {} : _onSave,
                loading: _isSaving,
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _onSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check, size: 20),
                label: Text(_isSaving ? AppStrings.saving : AppStrings.save),
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
          title: Text(AppStrings.editSeniorTitle),
          titleSpacing: HelpiAppBar.innerTitleSpacing,
        ),
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
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    if (_gender == null || _dateOfBirth == null) {
      showErrorSnack(context, AppStrings.fieldRequired);
      return;
    }

    if (_hasOrderer && (_ordGender == null || _ordDateOfBirth == null)) {
      showErrorSnack(context, AppStrings.fieldRequired);
      return;
    }

    setState(() => _isSaving = true);

    final api = AdminApiService();
    final seniorId = int.tryParse(widget.senior.id);

    // 1. Update relationship if changed
    final oldHasOrderer = widget.senior.hasOrderer;
    if (seniorId != null && _hasOrderer != oldHasOrderer) {
      final newRelationship = _hasOrderer ? 4 : 0;
      final result = await api.updateSenior(
        seniorId: seniorId,
        relationship: newRelationship,
      );
      if (!mounted) return;
      if (!result.success) {
        setState(() => _isSaving = false);
        showErrorSnack(context, result.error ?? 'Error');
        return;
      }
      // Reload only seniors to get updated contact IDs
      final seniorsResult = await api.getSeniors();
      if (!mounted) return;
      if (seniorsResult.success && seniorsResult.data != null) {
        ref.read(seniorsProvider.notifier).setAll(seniorsResult.data!);
      }
    }

    // Re-read the senior to get updated contact IDs (may have changed)
    final currentSenior =
        ref
            .read(seniorsProvider)
            .where((s) => s.id == widget.senior.id)
            .firstOrNull ??
        widget.senior;

    // Refresh googlePlaceIds from backend after relationship change
    final refreshedSeniorPlaceId = currentSenior.googlePlaceId;
    if (refreshedSeniorPlaceId != null && refreshedSeniorPlaceId.isNotEmpty) {
      _seniorGooglePlaceId = refreshedSeniorPlaceId;
    }
    final refreshedOrdererPlaceId = currentSenior.ordererGooglePlaceId;
    if (refreshedOrdererPlaceId != null && refreshedOrdererPlaceId.isNotEmpty) {
      _ordererGooglePlaceId = refreshedOrdererPlaceId;
    }

    // 2-4. Run contact updates + password reset in parallel
    final futures = <Future<ApiResult<void>>>[];

    // Senior contact update
    final seniorContactId = currentSenior.contactId;
    if (seniorContactId != null) {
      futures.add(
        api.updateContactInfo(
          contactId: seniorContactId,
          fullName:
              '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}',
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          fullAddress: _addressCtrl.text.trim(),
          gender: _gender == Gender.male ? 0 : 1,
          dateOfBirth: _dateOfBirth!.toIso8601String().split('T').first,
          googlePlaceId: _seniorGooglePlaceId,
        ),
      );
    }

    // Orderer contact update
    if (_hasOrderer) {
      final ordererContactId = currentSenior.ordererContactId;
      if (ordererContactId != null) {
        futures.add(
          api.updateContactInfo(
            contactId: ordererContactId,
            fullName:
                '${_ordFirstNameCtrl.text.trim()} ${_ordLastNameCtrl.text.trim()}',
            email: _ordEmailCtrl.text.trim(),
            phone: _ordPhoneCtrl.text.trim(),
            fullAddress: _ordAddressCtrl.text.trim(),
            gender: _ordGender == Gender.male ? 0 : 1,
            dateOfBirth: _ordDateOfBirth!.toIso8601String().split('T').first,
            googlePlaceId: _ordererGooglePlaceId,
          ),
        );
      }
    }

    // Password reset
    final newPassword = _passwordCtrl.text.trim();
    if (newPassword.isNotEmpty && currentSenior.userId != null) {
      futures.add(
        api.adminResetPassword(
          userId: currentSenior.userId!,
          newPassword: newPassword,
        ),
      );
    }

    if (futures.isNotEmpty) {
      final results = await Future.wait(futures);
      if (!mounted) return;
      for (final r in results) {
        if (!r.success) {
          setState(() => _isSaving = false);
          showErrorSnack(context, r.error ?? 'Error');
          return;
        }
      }
    }

    // 5. Refresh seniors from backend (targeted — no need to reload all data)
    final sResult = await api.getSeniors();
    if (!mounted) return;
    if (sResult.success && sResult.data != null) {
      AppData.seniors
        ..clear()
        ..addAll(sResult.data!);
      ref.read(seniorsProvider.notifier).setAll(sResult.data!);
    }

    final refreshed = ref
        .read(seniorsProvider)
        .where((s) => s.id == widget.senior.id)
        .firstOrNull;

    // Patch dateOfBirth locally — backend may return default 0001-01-01
    // until the next GET reloads from DB. This ensures the UI shows what was saved.
    final patched = (refreshed ?? widget.senior).withDateOfBirth(_dateOfBirth!);

    showSuccessSnack(context, AppStrings.editSeniorSuccess);
    Navigator.pop(context, patched);
  }
}
