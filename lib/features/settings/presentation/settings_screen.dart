import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/l10n/locale_notifier.dart';
import 'package:helpi_admin/core/network/api_client.dart';
import 'package:helpi_admin/core/network/api_endpoints.dart';

/// Admin Settings screen — pricing, cancel rules, operational, tax, language.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.localeNotifier});

  final LocaleNotifier localeNotifier;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _api = ApiClient();

  bool _loading = true;
  bool _saving = false;
  int _configId = 1;

  // ── Pricing ──
  final _weekdayRateCtrl = TextEditingController();
  final _sundayRateCtrl = TextEditingController();
  final _companyPctCtrl = TextEditingController();
  final _studentPctCtrl = TextEditingController();

  // ── Cancel rules ──
  final _studentCutoffCtrl = TextEditingController();
  final _seniorCutoffCtrl = TextEditingController();

  // ── Operational ──
  final _travelBufferCtrl = TextEditingController();
  final _paymentTimingCtrl = TextEditingController();

  // ── Tax ──
  bool _vatEnabled = false;
  final _vatCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _weekdayRateCtrl.dispose();
    _sundayRateCtrl.dispose();
    _companyPctCtrl.dispose();
    _studentPctCtrl.dispose();
    _studentCutoffCtrl.dispose();
    _seniorCutoffCtrl.dispose();
    _travelBufferCtrl.dispose();
    _paymentTimingCtrl.dispose();
    _vatCtrl.dispose();
    super.dispose();
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
        _companyPctCtrl.text = _fmt(cfg['companyPercentage']);
        _studentPctCtrl.text = _fmt(cfg['serviceProviderPercentage']);
        _studentCutoffCtrl.text =
            '${(cfg['studentCancelCutoffHours'] as num?) ?? 6}';
        _seniorCutoffCtrl.text =
            '${(cfg['seniorCancelCutoffHours'] as num?) ?? 1}';
        _travelBufferCtrl.text =
            '${(cfg['travelBufferMinutes'] as num?) ?? 15}';
        _paymentTimingCtrl.text =
            '${(cfg['paymentTimingMinutes'] as num?) ?? 30}';
        _vatEnabled = cfg['vatEnabled'] == true;
        _vatCtrl.text = _fmt(cfg['vatPercentage']);
      }
    } catch (_) {
      if (!mounted) return;
      _showSnack(AppStrings.settingsLoadFailed, isError: true);
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? HelpiTheme.error : HelpiTheme.accent,
      ),
    );
  }

  String _fmt(dynamic v) {
    if (v == null) return '0';
    final d = (v as num).toDouble();
    return d == d.truncateToDouble() ? d.toInt().toString() : d.toString();
  }

  Future<void> _saveSettings() async {
    // Validate company + student = 100
    final companyPct = double.tryParse(_companyPctCtrl.text) ?? 0;
    final studentPct = double.tryParse(_studentPctCtrl.text) ?? 0;
    if ((companyPct + studentPct - 100).abs() > 0.01) {
      _showSnack(AppStrings.settingsPercentageError, isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      await _api.put(
        '${ApiEndpoints.pricingConfigurations}/$_configId',
        data: {
          'id': _configId,
          'jobHourlyRate': double.tryParse(_weekdayRateCtrl.text) ?? 0,
          'sundayHourlyRate': double.tryParse(_sundayRateCtrl.text) ?? 0,
          'companyPercentage': companyPct,
          'serviceProviderPercentage': studentPct,
          'studentCancelCutoffHours':
              int.tryParse(_studentCutoffCtrl.text) ?? 6,
          'seniorCancelCutoffHours': int.tryParse(_seniorCutoffCtrl.text) ?? 1,
          'travelBufferMinutes': int.tryParse(_travelBufferCtrl.text) ?? 15,
          'paymentTimingMinutes': int.tryParse(_paymentTimingCtrl.text) ?? 30,
          'vatEnabled': _vatEnabled,
          'vatPercentage': double.tryParse(_vatCtrl.text) ?? 0,
        },
        queryParameters: {'reason': 'Admin settings update'},
      );
      if (!mounted) return;
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.settingsTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: _saving ? null : _saveSettings,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save, size: 20),
              label: Text(AppStrings.save),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Pricing ──
                  _sectionCard(
                    icon: Icons.euro,
                    title: AppStrings.settingsPricing,
                    children: [
                      _numField(
                        _weekdayRateCtrl,
                        AppStrings.weekdayRate,
                        suffix: '€',
                        decimal: true,
                      ),
                      const SizedBox(height: 16),
                      _numField(
                        _sundayRateCtrl,
                        AppStrings.sundayRate,
                        suffix: '€',
                        decimal: true,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _numField(
                              _companyPctCtrl,
                              AppStrings.companyPercentage,
                              suffix: '%',
                              decimal: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _numField(
                              _studentPctCtrl,
                              AppStrings.studentPercentage,
                              suffix: '%',
                              decimal: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Cancel rules ──
                  _sectionCard(
                    icon: Icons.timer_off,
                    title: AppStrings.settingsCancelRules,
                    children: [
                      _numField(
                        _studentCutoffCtrl,
                        AppStrings.studentCancelCutoff,
                        suffix: 'h',
                      ),
                      const SizedBox(height: 16),
                      _numField(
                        _seniorCutoffCtrl,
                        AppStrings.seniorCancelCutoff,
                        suffix: 'h',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Operational ──
                  _sectionCard(
                    icon: Icons.settings,
                    title: AppStrings.settingsOperational,
                    children: [
                      _numField(
                        _travelBufferCtrl,
                        AppStrings.travelBuffer,
                        suffix: 'min',
                      ),
                      const SizedBox(height: 16),
                      _numField(
                        _paymentTimingCtrl,
                        AppStrings.paymentTiming,
                        suffix: 'min',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Tax ──
                  _sectionCard(
                    icon: Icons.receipt_long,
                    title: AppStrings.settingsTax,
                    children: [
                      SwitchListTile(
                        title: Text(AppStrings.vatEnabled),
                        value: _vatEnabled,
                        onChanged: (v) => setState(() => _vatEnabled = v),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_vatEnabled) ...[
                        const SizedBox(height: 8),
                        _numField(
                          _vatCtrl,
                          AppStrings.vatPercentage,
                          suffix: '%',
                          decimal: true,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Language ──
                  _sectionCard(
                    icon: Icons.language,
                    title: AppStrings.settingsLanguage,
                    children: [
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'hr',
                            label: Text('Hrvatski'),
                            icon: Icon(Icons.flag),
                          ),
                          ButtonSegment(
                            value: 'en',
                            label: Text('English'),
                            icon: Icon(Icons.flag_outlined),
                          ),
                        ],
                        selected: {AppStrings.currentLocale},
                        onSelectionChanged: (sel) {
                          widget.localeNotifier.setLocale(sel.first);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Section card with icon + title ──
  Widget _sectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        side: BorderSide(color: HelpiTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 22, color: HelpiTheme.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: HelpiTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  // ── Numeric text field ──
  Widget _numField(
    TextEditingController ctrl,
    String label, {
    String? suffix,
    bool decimal = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        if (decimal)
          FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
