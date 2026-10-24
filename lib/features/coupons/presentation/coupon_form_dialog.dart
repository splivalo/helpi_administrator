import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
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
  bool _combinable = false;
  bool _isActive = true;
  // Doseg: false = "Svi" (bilo tko s kodom), true = "Odabrani" (samo s popisa).
  bool _restrictToSelected = false;
  // "Odmah dodijeli" — odmah grantaj eligible seniorima (ili svima ako doseg = Svi).
  bool _assignImmediately = false;
  DateTime _validFrom = DateTime.now();
  DateTime _validUntil = DateTime.now().add(const Duration(days: 365));

  // City dropdown
  List<_CityOption> _cities = [];
  int? _selectedCityId;

  // Assign-to-users (optional, same modal)
  final _seniorSearchCtrl = TextEditingController();
  List<SeniorModel> _seniors = [];
  final Set<int> _selectedSeniorIds = {};
  Set<int> _alreadyAssigned = {};
  String _seniorQuery = '';
  bool _seniorsLoading = true;

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
      _restrictToSelected = e.restrictToSelected;
      _validFrom = DateFormat('yyyy-MM-dd').parse(e.validFrom);
      _validUntil = DateFormat('yyyy-MM-dd').parse(e.validUntil);
      // _selectedCityId is set in _loadCities() after cities are fetched
    }
    _loadCities();
    _seniorSearchCtrl.addListener(
      () => setState(
        () => _seniorQuery = _seniorSearchCtrl.text.trim().toLowerCase(),
      ),
    );
    _loadSeniors();
    if (_isEdit) _loadEligible();
  }

  /// Loads the coupon's eligibility allowlist (fetched by id — the list view
  /// doesn't carry it) and pre-checks those seniors in the picker.
  Future<void> _loadEligible() async {
    final res = await _api.getCouponById(widget.existing!.id);
    if (!mounted) return;
    if (res.success && res.data != null) {
      final ids = (res.data!['eligibleSeniorIds'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toInt())
          .toSet();
      setState(() {
        _alreadyAssigned = ids;
        _selectedSeniorIds
          ..clear()
          ..addAll(ids);
      });
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _descCtrl.dispose();
    _valueCtrl.dispose();
    _seniorSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSeniors() async {
    final res = await _api.getSeniors();
    if (!mounted) return;
    setState(() {
      if (res.success && res.data != null) {
        _seniors = res.data!
            .where((s) => s.isActive && !s.isArchived)
            .toList();
      }
      _seniorsLoading = false;
    });
  }

  int _sid(SeniorModel s) => int.tryParse(s.id) ?? -1;

  List<SeniorModel> _filteredSeniors() {
    Iterable<SeniorModel> list = _seniors;

    // Scope to the coupon's selected city (city is chosen in the dropdown above,
    // so it is not part of the text search). "All cities" → no city filter.
    if (_selectedCityId != null) {
      final cityName = _cities
          .where((c) => c.id == _selectedCityId)
          .map((c) => c.name)
          .firstOrNull;
      if (cityName != null) {
        list = list.where((s) => s.city == cityName);
      }
    }

    // Text search — same logic as the seniors page: matches the senior and the
    // orderer (the person who orders for the senior), plus email/phone.
    if (_seniorQuery.isNotEmpty) {
      final q = _seniorQuery;
      list = list.where(
        (s) =>
            s.fullName.toLowerCase().contains(q) ||
            s.contactName.toLowerCase().contains(q) ||
            s.email.toLowerCase().contains(q) ||
            s.phone.contains(q),
      );
    }

    // Already-assigned seniors first, then the rest; alphabetical within each group.
    final result = list.toList()
      ..sort((a, b) {
        final aAssigned = _alreadyAssigned.contains(_sid(a));
        final bAssigned = _alreadyAssigned.contains(_sid(b));
        if (aAssigned != bAssigned) return aAssigned ? -1 : 1;
        return a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
      });
    return result;
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
          restrictToSelected: _restrictToSelected,
          eligibleSeniorIds: _restrictToSelected
              ? _selectedSeniorIds.toList()
              : const [],
          assignImmediately: _assignImmediately,
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
            restrictToSelected: _restrictToSelected,
            eligibleSeniorIds: _restrictToSelected
                ? _selectedSeniorIds.toList()
                : const [],
            createdAt: widget.existing!.createdAt,
          );
          if (!mounted) return;
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
          restrictToSelected: _restrictToSelected,
          eligibleSeniorIds: _restrictToSelected
              ? _selectedSeniorIds.toList()
              : const [],
          assignImmediately: _assignImmediately,
        );
        if (!mounted) return;
        if (result.success) {
          final created = CouponModel.fromJson(result.data!);
          if (!mounted) return;
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
    final filteredSeniors = _filteredSeniors();

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
                _isEdit ? AppStrings.couponEdit : AppStrings.couponNew,
                style: const TextStyle(
                  fontSize: 18,
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

              // ── Dostupnost: doseg (Svi / Odabrani) + "Odmah dodijeli" ──
              const Divider(height: 1),
              const SizedBox(height: 12),
              Text(
                AppStrings.couponScopeTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              RadioListTile<bool>(
                value: false,
                groupValue: _restrictToSelected,
                onChanged: (_) => setState(() => _restrictToSelected = false),
                title: Text(
                  AppStrings.couponScopeAll,
                  style: const TextStyle(fontSize: 13),
                ),
                subtitle: Text(
                  AppStrings.couponScopeAllHint,
                  style: const TextStyle(fontSize: 11),
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              RadioListTile<bool>(
                value: true,
                groupValue: _restrictToSelected,
                onChanged: (_) => setState(() => _restrictToSelected = true),
                title: Text(
                  AppStrings.couponScopeSelected,
                  style: const TextStyle(fontSize: 13),
                ),
                subtitle: Text(
                  AppStrings.couponScopeSelectedHint,
                  style: const TextStyle(fontSize: 11),
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.couponAssignImmediately,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  HelpiSwitch(
                    value: _assignImmediately,
                    onChanged: (v) => setState(() => _assignImmediately = v),
                  ),
                ],
              ),
              if (_restrictToSelected) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _seniorSearchCtrl,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, size: 18),
                    hintText: AppStrings.couponAssignSearchHint,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: HelpiColors.of(context).border),
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: _seniorsLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredSeniors.isEmpty
                    ? Center(child: Text(AppStrings.couponAssignNoSeniors))
                    : ListView.builder(
                        itemCount: filteredSeniors.length,
                        itemBuilder: (_, i) {
                          final s = filteredSeniors[i];
                          final id = _sid(s);
                          final already = _alreadyAssigned.contains(id);
                          // Show the user like the seniors page: senior name as
                          // title, and the orderer (if any) as the subtitle.
                          final subtitle = s.hasOrderer
                              ? AppStrings.couponAssignOrderer(s.ordererFullName)
                              : s.email;
                          // Thin separator between the already-assigned group
                          // (on top) and the rest of the users.
                          final showDivider =
                              i > 0 &&
                              !already &&
                              _alreadyAssigned.contains(
                                _sid(filteredSeniors[i - 1]),
                              );

                          final tile = CheckboxListTile(
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: _selectedSeniorIds.contains(id),
                            onChanged: (v) => setState(() {
                              if (v == true) {
                                _selectedSeniorIds.add(id);
                              } else {
                                _selectedSeniorIds.remove(id);
                              }
                            }),
                            title: Text(
                              s.fullName,
                              style: const TextStyle(fontSize: 13),
                            ),
                            subtitle: subtitle.isEmpty
                                ? null
                                : Text(
                                    subtitle,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                          );

                          if (!showDivider) return tile;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [const Divider(height: 1), tile],
                          );
                        },
                      ),
              ),
              const SizedBox(height: 4),
              Builder(
                builder: (context) {
                  // All seniors in the current (city + search) view.
                  final selectableIds = filteredSeniors
                      .map(_sid)
                      .where((id) => id > 0)
                      .toList();
                  final allSelected =
                      selectableIds.isNotEmpty &&
                      selectableIds.every(_selectedSeniorIds.contains);

                  return Row(
                    children: [
                      Text(
                        AppStrings.couponAssignSelectedCount(
                          _selectedSeniorIds.length,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: HelpiColors.of(context).textSecondary,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: selectableIds.isEmpty
                            ? null
                            : () => setState(() {
                                if (allSelected) {
                                  _selectedSeniorIds.removeAll(selectableIds);
                                } else {
                                  _selectedSeniorIds.addAll(selectableIds);
                                }
                              }),
                        child: Text(
                          allSelected
                              ? AppStrings.couponAssignDeselectAll
                              : AppStrings.couponAssignSelectAll,
                        ),
                      ),
                    ],
                  );
                },
              ),
              ],
              const SizedBox(height: 12),

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
