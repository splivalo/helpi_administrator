import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/l10n/locale_notifier.dart';
import 'package:helpi_admin/core/l10n/theme_notifier.dart';
import 'package:helpi_admin/core/network/api_client.dart';
import 'package:helpi_admin/core/network/api_endpoints.dart';
import 'package:helpi_admin/core/providers/data_providers.dart';
import 'package:helpi_admin/core/widgets/notification_bell.dart';
import 'package:helpi_admin/core/widgets/helpi_app_bar.dart';
import 'package:helpi_admin/core/widgets/shared_widgets.dart';

/// Admin Settings screen — pricing, cancel rules, operational, tax, language.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({
    super.key,
    required this.localeNotifier,
    required this.themeNotifier,
  });

  final LocaleNotifier localeNotifier;
  final ThemeNotifier themeNotifier;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _api = ApiClient();

  bool _loading = true;
  bool _saving = false;
  bool _editing = false;
  int _configId = 1;

  // ── Pricing ──
  final _weekdayRateCtrl = TextEditingController();
  final _sundayRateCtrl = TextEditingController();

  // ── Cancel rules ──
  final _studentCutoffCtrl = TextEditingController();
  final _seniorCutoffCtrl = TextEditingController();

  // ── Operational ──
  final _travelBufferCtrl = TextEditingController();
  final _paymentTimingCtrl = TextEditingController();

  // ── Student rates ──
  final _studentRateCtrl = TextEditingController();
  final _studentSundayRateCtrl = TextEditingController();

  // ── Earnings ──
  final _intermediaryPctCtrl = TextEditingController();
  final _vatCtrl = TextEditingController();

  // Snapshot for cancel/revert
  Map<String, String> _snapshot = {};

  int _lastPricingVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _weekdayRateCtrl.dispose();
    _sundayRateCtrl.dispose();
    _studentCutoffCtrl.dispose();
    _seniorCutoffCtrl.dispose();
    _travelBufferCtrl.dispose();
    _paymentTimingCtrl.dispose();
    _studentRateCtrl.dispose();
    _studentSundayRateCtrl.dispose();
    _intermediaryPctCtrl.dispose();
    _vatCtrl.dispose();
    super.dispose();
  }

  void _takeSnapshot() {
    _snapshot = {
      'weekday': _weekdayRateCtrl.text,
      'sunday': _sundayRateCtrl.text,
      'studentCutoff': _studentCutoffCtrl.text,
      'seniorCutoff': _seniorCutoffCtrl.text,
      'travelBuffer': _travelBufferCtrl.text,
      'paymentTiming': _paymentTimingCtrl.text,
      'studentRate': _studentRateCtrl.text,
      'studentSundayRate': _studentSundayRateCtrl.text,
      'intermediaryPct': _intermediaryPctCtrl.text,
      'vat': _vatCtrl.text,
    };
  }

  void _restoreSnapshot() {
    _weekdayRateCtrl.text = _snapshot['weekday'] ?? '';
    _sundayRateCtrl.text = _snapshot['sunday'] ?? '';
    _studentCutoffCtrl.text = _snapshot['studentCutoff'] ?? '';
    _seniorCutoffCtrl.text = _snapshot['seniorCutoff'] ?? '';
    _travelBufferCtrl.text = _snapshot['travelBuffer'] ?? '';
    _paymentTimingCtrl.text = _snapshot['paymentTiming'] ?? '';
    _studentRateCtrl.text = _snapshot['studentRate'] ?? '';
    _studentSundayRateCtrl.text = _snapshot['studentSundayRate'] ?? '';
    _intermediaryPctCtrl.text = _snapshot['intermediaryPct'] ?? '';
    _vatCtrl.text = _snapshot['vat'] ?? '';
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);
    try {
      final response = await _api.get(ApiEndpoints.pricingConfigurations);
      final list = response.data as List<dynamic>;
      if (list.isNotEmpty) {
        final cfg = list.first as Map<String, dynamic>;
        _configId = (cfg['id'] as num?)?.toInt() ?? 1;
        _weekdayRateCtrl.text = _fmt(cfg['jobHourlyRate']);
        _sundayRateCtrl.text = _fmt(cfg['sundayHourlyRate']);
        _studentCutoffCtrl.text =
            '${(cfg['studentCancelCutoffHours'] as num?) ?? 6}';
        _seniorCutoffCtrl.text =
            '${(cfg['seniorCancelCutoffHours'] as num?) ?? 1}';
        _travelBufferCtrl.text =
            '${(cfg['travelBufferMinutes'] as num?) ?? 15}';
        _paymentTimingCtrl.text =
            '${(cfg['paymentTimingMinutes'] as num?) ?? 30}';
        _studentRateCtrl.text = _fmt(cfg['studentHourlyRate'] ?? 7.40);
        _studentSundayRateCtrl.text = _fmt(
          cfg['studentSundayHourlyRate'] ?? 11.10,
        );
        _intermediaryPctCtrl.text = _fmt(cfg['intermediaryPercentage'] ?? 18);
        _vatCtrl.text = _fmt(cfg['vatPercentage']);
      }
    } catch (_) {
      if (!mounted) return;
      showErrorSnack(context, AppStrings.settingsLoadFailed);
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _showSnack(String message, {bool isError = false}) {
    if (isError) {
      showErrorSnack(context, message);
    } else {
      showSuccessSnack(context, message);
    }
  }

  String _fmt(dynamic v) {
    if (v == null) return '0';
    final d = (v as num).toDouble();
    return d == d.truncateToDouble() ? d.toInt().toString() : d.toString();
  }

  void _startEditing() {
    _takeSnapshot();
    setState(() => _editing = true);
  }

  void _cancelEditing() {
    _restoreSnapshot();
    setState(() => _editing = false);
  }

  void _increment(
    TextEditingController ctrl, {
    double step = 1,
    bool decimal = false,
  }) {
    final current = double.tryParse(ctrl.text) ?? 0;
    final next = current + step;
    ctrl.text = decimal ? _fmt(next) : next.toInt().toString();
  }

  void _decrement(
    TextEditingController ctrl, {
    double step = 1,
    bool decimal = false,
  }) {
    final current = double.tryParse(ctrl.text) ?? 0;
    final next = current - step;
    if (next < 0) return;
    ctrl.text = decimal ? _fmt(next) : next.toInt().toString();
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);
    try {
      await _api.put(
        '${ApiEndpoints.pricingConfigurations}/$_configId',
        data: {
          'id': _configId,
          'jobHourlyRate': double.tryParse(_weekdayRateCtrl.text) ?? 0,
          'sundayHourlyRate': double.tryParse(_sundayRateCtrl.text) ?? 0,
          'studentCancelCutoffHours':
              int.tryParse(_studentCutoffCtrl.text) ?? 6,
          'seniorCancelCutoffHours': int.tryParse(_seniorCutoffCtrl.text) ?? 1,
          'travelBufferMinutes': int.tryParse(_travelBufferCtrl.text) ?? 15,
          'paymentTimingMinutes': int.tryParse(_paymentTimingCtrl.text) ?? 30,
          'studentHourlyRate': double.tryParse(_studentRateCtrl.text) ?? 7.40,
          'studentSundayHourlyRate':
              double.tryParse(_studentSundayRateCtrl.text) ?? 11.10,
          'intermediaryPercentage':
              double.tryParse(_intermediaryPctCtrl.text) ?? 18,
          'vatEnabled': (double.tryParse(_vatCtrl.text) ?? 0) > 0,
          'vatPercentage': double.tryParse(_vatCtrl.text) ?? 0,
        },
        queryParameters: {'reason': 'Admin settings update'},
      );
      if (!mounted) return;
      ref.read(pricingVersionProvider.notifier).state++;
      setState(() => _editing = false);
      _showSnack(AppStrings.settingsSaved);
    } catch (_) {
      if (!mounted) return;
      _showSnack(AppStrings.settingsSaveFailed, isError: true);
    }
    if (!mounted) return;
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    // Reload pricing when SettingsChanged fires (only if not editing)
    final pv = ref.watch(pricingVersionProvider);
    if (pv != _lastPricingVersion) {
      _lastPricingVersion = pv;
      if (pv > 0 && !_editing) _loadSettings();
    }

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: HelpiAppBar(
        title: Text(AppStrings.settingsTitle),
        actions: [
          if (_editing) ...[
            TextButton(
              onPressed: _saving ? null : _cancelEditing,
              child: Text(AppStrings.cancel),
            ),
            IconButton(
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save, size: 22, color: HelpiTheme.accent),
              tooltip: AppStrings.save,
              onPressed: _saving ? null : _saveSettings,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.edit, size: 22),
              tooltip: AppStrings.edit,
              onPressed: _startEditing,
            ),
          ],
          const NotificationBell(),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 600;
              return ListView(
                children: [
                  // ── Pricing ──
                  _sectionCard(
                    icon: Icons.euro,
                    title: AppStrings.settingsPricing,
                    children: [
                      _fieldPair(
                        wide: wide,
                        first: _numField(
                          _weekdayRateCtrl,
                          AppStrings.weekdayRate,
                          suffix: '€',
                          decimal: true,
                        ),
                        second: _numField(
                          _sundayRateCtrl,
                          AppStrings.sundayRate,
                          suffix: '€',
                          decimal: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Student rates ──
                  _sectionCard(
                    icon: Icons.school_outlined,
                    title: AppStrings.settingsStudentRates,
                    children: [
                      _fieldPair(
                        wide: wide,
                        first: _numField(
                          _studentRateCtrl,
                          AppStrings.studentHourlyRate,
                          suffix: '€',
                          decimal: true,
                        ),
                        second: _numField(
                          _studentSundayRateCtrl,
                          AppStrings.studentSundayRate,
                          suffix: '€',
                          decimal: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Cancel rules ──
                  _sectionCard(
                    icon: Icons.timer_off,
                    title: AppStrings.settingsCancelRules,
                    children: [
                      _fieldPair(
                        wide: wide,
                        first: _numField(
                          _studentCutoffCtrl,
                          AppStrings.studentCancelCutoff,
                          suffix: 'h',
                        ),
                        second: _numField(
                          _seniorCutoffCtrl,
                          AppStrings.seniorCancelCutoff,
                          suffix: 'h',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Operational ──
                  _sectionCard(
                    icon: Icons.tune,
                    title: AppStrings.settingsOperational,
                    children: [
                      _fieldPair(
                        wide: wide,
                        first: _numField(
                          _travelBufferCtrl,
                          AppStrings.travelBuffer,
                          suffix: 'min',
                        ),
                        second: _numField(
                          _paymentTimingCtrl,
                          AppStrings.paymentTiming,
                          suffix: 'min',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Earnings (margin + VAT) ──
                  _sectionCard(
                    icon: Icons.calculate_outlined,
                    title: AppStrings.settingsEarnings,
                    children: [
                      if (wide)
                        Row(
                          children: [
                            Expanded(
                              child: _numField(
                                _intermediaryPctCtrl,
                                AppStrings.intermediaryPercentage,
                                suffix: '%',
                                decimal: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _numField(
                                _vatCtrl,
                                AppStrings.vatPercentage,
                                suffix: '%',
                                decimal: true,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _numField(
                          _intermediaryPctCtrl,
                          AppStrings.intermediaryPercentage,
                          suffix: '%',
                          decimal: true,
                        ),
                        const SizedBox(height: 12),
                        _numField(
                          _vatCtrl,
                          AppStrings.vatPercentage,
                          suffix: '%',
                          decimal: true,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Language ──
                  _sectionCard(
                    icon: Icons.language,
                    title: AppStrings.settingsLanguage,
                    children: [
                      DropdownButtonFormField<String>(
                        value: AppStrings.currentLocale,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'hr',
                            child: Text('Hrvatski'),
                          ),
                          DropdownMenuItem(value: 'en', child: Text('English')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            widget.localeNotifier.setLocale(v);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Theme ──
                  _sectionCard(
                    icon: Icons.brightness_6,
                    title: AppStrings.settingsTheme,
                    children: [
                      DropdownButtonFormField<ThemeMode>(
                        value: widget.themeNotifier.value,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text(AppStrings.themeSystem),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text(AppStrings.themeLight),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text(AppStrings.themeDark),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            widget.themeNotifier.setThemeMode(v);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Responsive field pair: Row on wide, Column on narrow ──
  Widget _fieldPair({
    required bool wide,
    required Widget first,
    required Widget second,
  }) {
    if (wide) {
      return Row(
        children: [
          Expanded(child: first),
          const SizedBox(width: 16),
          Expanded(child: second),
        ],
      );
    }
    return Column(children: [first, const SizedBox(height: 12), second]);
  }

  // ── Section card with icon + title (matches analytics Container pattern) ──
  Widget _sectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HelpiColors.of(context).surface,
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        border: Border.all(color: HelpiColors.of(context).border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: HelpiTheme.accent),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: HelpiColors.of(context).textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // ── Numeric text field with stepper arrows ──
  // Inherits theme InputDecorationTheme (same as login page).
  Widget _numField(
    TextEditingController ctrl,
    String label, {
    String? suffix,
    bool decimal = false,
    double step = 1,
  }) {
    return TextField(
      controller: ctrl,
      readOnly: !_editing,
      enabled: _editing,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        if (decimal)
          FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: label,
        fillColor: _editing ? null : HelpiColors.of(context).chipBg,
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
          borderSide: BorderSide(color: HelpiColors.of(context).border),
        ),
        suffixIcon: (suffix != null || _editing)
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (suffix != null)
                      Text(
                        suffix,
                        style: TextStyle(
                          fontSize: 14,
                          color: HelpiColors.of(context).textSecondary,
                        ),
                      ),
                    if (_editing) ...[
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 24,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 24,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                iconSize: 20,
                                icon: Icon(
                                  Icons.arrow_drop_up,
                                  color: HelpiColors.of(context).textSecondary,
                                ),
                                onPressed: () => _increment(
                                  ctrl,
                                  step: step,
                                  decimal: decimal,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                              width: 24,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                iconSize: 20,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: HelpiColors.of(context).textSecondary,
                                ),
                                onPressed: () => _decrement(
                                  ctrl,
                                  step: step,
                                  decimal: decimal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
      ),
    );
  }
}
