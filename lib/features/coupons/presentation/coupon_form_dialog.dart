import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/network/api_client.dart';
import 'package:helpi_admin/core/network/api_endpoints.dart';
import 'package:helpi_admin/core/services/admin_api_service.dart';
import 'package:helpi_admin/core/widgets/widgets.dart';
import 'package:helpi_admin/features/coupons/data/coupon_model.dart';

/// Create / Edit dialog for a coupon.
/// Returns the resulting [CouponModel] via `Navigator.pop`.
class CouponFormDialog extends StatefulWidget {
  const CouponFormDialog({super.key, this.existing});

  /// If non-null the dialog is in **edit** mode.
  final CouponModel? existing;

  @override
  State<CouponFormDialog> createState() => _CouponFormDialogState();
}

class _CouponFormDialogState extends State<CouponFormDialog> {
  final _api = AdminApiService();
  final _cityApi = ApiClient();
  bool _submitted = false;

  late final TextEditingController _codeCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _valueCtrl;

  CouponType _type = CouponType.monthlyHours;
  bool _combinable = true;
  bool _isActive = true;
  DateTime _validFrom = DateTime.now();
  DateTime _validUntil = DateTime.now().add(const Duration(days: 365));

  // City dropdown
  List<_CityOption> _cities = [];
  int? _selectedCityId;

  bool _saving = false;
  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _codeCtrl = TextEditingController(text: e?.code ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _valueCtrl = TextEditingController(
      text: e != null ? e.value.toString() : '',
    );
    if (e != null) {
      _type = e.type;
      _combinable = e.isCombainable;
      _isActive = e.isActive;
      _validFrom = DateFormat('yyyy-MM-dd').parse(e.validFrom);
      _validUntil = DateFormat('yyyy-MM-dd').parse(e.validUntil);
      // _selectedCityId is set in _loadCities() after cities are fetched
    }
    _loadCities();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _descCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    try {
      final response = await _cityApi.get(ApiEndpoints.cities);
      if (!mounted) return;
      final list =
          (response.data as List<dynamic>)
              .map((e) {
                final m = e as Map<String, dynamic>;
                return _CityOption(
                  id: m['id'] as int,
                  name: (m['name'] as String?)?.trim() ?? '',
                );
              })
              .where((c) => c.name.isNotEmpty)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
      setState(() {
        _cities = list;
        // Restore saved cityId only if it exists in the loaded list
        final saved = widget.existing?.cityId;
        if (saved != null && list.any((c) => c.id == saved)) {
          _selectedCityId = saved;
        }
      });
    } catch (_) {
      // cities are optional — dropdown stays empty
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _validFrom : _validUntil;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      if (isFrom) {
        _validFrom = picked;
      } else {
        _validUntil = picked;
      }
    });
  }

  /// Returns red error border when the field fails validation after submit.
  OutlineInputBorder? _errBorder(String text, {int minLength = 1}) {
    if (!_submitted || text.trim().length >= minLength) return null;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
      borderSide: const BorderSide(color: HelpiTheme.error, width: 2),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);

    final code = _codeCtrl.text.trim();
    final name = code; // backend requires name — use code
    final value = double.tryParse(_valueCtrl.text.trim());
    if (code.length < 3 || value == null || value <= 0) {
      return;
    }

    setState(() => _saving = true);

    final dateFmt = DateFormat('yyyy-MM-dd');
    final desc = _descCtrl.text.trim();

    try {
      if (_isEdit) {
        final result = await _api.updateCoupon(
          widget.existing!.id,
          name: name,
          description: desc.isEmpty ? null : desc,
          value: value,
          isCombainable: _combinable,
          cityId: _selectedCityId,
          validFrom: dateFmt.format(_validFrom),
          validUntil: dateFmt.format(_validUntil),
          isActive: _isActive,
        );
        if (!mounted) return;
        if (result.success) {
          // Build updated model from form fields
          final updated = CouponModel(
            id: widget.existing!.id,
            code: widget.existing!.code,
            name: name,
            description: desc.isEmpty ? null : desc,
            type: widget.existing!.type,
            value: value,
            isCombainable: _combinable,
            cityId: _selectedCityId,
            cityName: _selectedCityId != null
                ? _cities
                      .where((c) => c.id == _selectedCityId)
                      .map((c) => c.name)
                      .firstOrNull
                : null,
            validFrom: dateFmt.format(_validFrom),
            validUntil: dateFmt.format(_validUntil),
            isActive: _isActive,
            assignmentCount: widget.existing!.assignmentCount,
            createdAt: widget.existing!.createdAt,
          );
          Navigator.pop(context, updated);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(AppStrings.couponSaved)));
        } else {
          debugPrint('[CouponForm] update failed: ${result.error}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? AppStrings.couponSaveFailed),
            ),
          );
        }
      } else {
        final result = await _api.createCoupon(
          code: code,
          name: name,
          description: desc.isEmpty ? null : desc,
          type: _type.index,
          value: value,
          isCombainable: _combinable,
          cityId: _selectedCityId,
          validFrom: dateFmt.format(_validFrom),
          validUntil: dateFmt.format(_validUntil),
        );
        if (!mounted) return;
        if (result.success) {
          final created = CouponModel.fromJson(result.data!);
          Navigator.pop(context, created);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(AppStrings.couponSaved)));
        } else {
          debugPrint('[CouponForm] create failed: ${result.error}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? AppStrings.couponSaveFailed),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('[CouponForm] exception: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.error)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd.MM.yyyy');

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Title ──
              Text(
                _isEdit ? AppStrings.couponName : AppStrings.couponNew,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // ── Code (full width) ──
              TextField(
                controller: _codeCtrl,
                decoration: InputDecoration(
                  labelText: AppStrings.couponCode,
                  enabledBorder: _errBorder(_codeCtrl.text, minLength: 3),
                  focusedBorder: _errBorder(_codeCtrl.text, minLength: 3),
                ),
                enabled: !_isEdit,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 12),

              // ── Description (full width) ──
              TextField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: AppStrings.couponDescription,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 12),

              // ── Type + Value ──
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<CouponType>(
                      value: _type,
                      decoration: InputDecoration(
                        labelText: AppStrings.couponType,
                      ),
                      items: CouponType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                t.label,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _isEdit
                          ? null
                          : (v) {
                              if (v != null) setState(() => _type = v);
                            },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _valueCtrl,
                      decoration: InputDecoration(
                        labelText: AppStrings.couponValue,
                        suffixText: _valueSuffix,
                        enabledBorder: _errBorder(_valueCtrl.text),
                        focusedBorder: _errBorder(_valueCtrl.text),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── City dropdown ──
              DropdownButtonFormField<int?>(
                value: _selectedCityId,
                decoration: InputDecoration(labelText: AppStrings.couponCity),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(AppStrings.couponCityAll),
                  ),
                  ..._cities.map(
                    (c) => DropdownMenuItem<int?>(
                      value: c.id,
                      child: Text(c.name),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _selectedCityId = v),
              ),
              const SizedBox(height: 12),

              // ── Date range ──
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: AppStrings.couponValidFrom,
                      value: dateFmt.format(_validFrom),
                      onTap: () => _pickDate(isFrom: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: AppStrings.couponValidUntil,
                      value: dateFmt.format(_validUntil),
                      onTap: () => _pickDate(isFrom: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Combinable toggle (HelpiSwitch) ──
              Row(
                children: [
                  Text(
                    AppStrings.couponCombinable,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  HelpiSwitch(
                    value: _combinable,
                    onChanged: (v) => setState(() => _combinable = v),
                  ),
                  if (_isEdit) ...[
                    const SizedBox(width: 24),
                    Text(
                      AppStrings.couponActive,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    HelpiSwitch(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 20),

              // ── Actions ──
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppStrings.cancel),
                  ),
                  const SizedBox(width: 8),
                  ActionChipButton(
                    icon: Icons.check,
                    label: AppStrings.save,
                    color: HelpiTheme.accent,
                    size: ActionChipButtonSize.medium,
                    loading: _saving,
                    onTap: _submit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _valueSuffix => 'h';
}

// ─────────────────────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────────────────────

class _CityOption {
  final int id;
  final String name;
  const _CityOption({required this.id, required this.name});
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(value),
      ),
    );
  }
}
