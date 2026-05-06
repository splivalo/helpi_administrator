import 'package:file_selector/file_selector.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/l10n/locale_notifier.dart';
import 'package:helpi_admin/core/l10n/theme_notifier.dart';
import 'package:helpi_admin/core/network/api_client.dart';
import 'package:helpi_admin/core/network/api_endpoints.dart';
import 'package:helpi_admin/core/providers/data_providers.dart';
import 'package:helpi_admin/core/services/admin_api_service.dart';
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
  bool _studentCancelEnabled = true;

  // ── Availability change rules ──
  bool _availabilityChangeEnabled = true;
  final _availabilityChangeCutoffCtrl = TextEditingController();

  // ── Operational ──
  final _travelBufferCtrl = TextEditingController();
  final _paymentTimingCtrl = TextEditingController();

  // ── Student rates ──
  final _studentRateCtrl = TextEditingController();
  final _studentSundayRateCtrl = TextEditingController();

  // ── Earnings ──
  final _intermediaryPctCtrl = TextEditingController();
  final _vatCtrl = TextEditingController();

  // ── Sponsor ──
  final _adminApi = AdminApiService();
  final _sponsorNameCtrl = TextEditingController();
  final _sponsorLogoCtrl = TextEditingController();
  final _sponsorDarkLogoCtrl = TextEditingController();
  final _sponsorLabelCtrl = TextEditingController();
  Map<String, String> _sponsorLabelMap = {};
  bool _sponsorActive = false;
  int? _sponsorId;
  bool _sponsorLoading = true;
  bool _uploadingLight = false;
  bool _uploadingDark = false;
  bool _savingSponsor = false;
  bool _editingSponsor = false;

  // ── Google Calendar ──
  bool _calendarConnected = false;
  String? _calendarEmail;
  DateTime? _calendarConnectedAt;
  bool _calendarLoading = true;
  bool _calendarConnecting = false;
  bool _calendarDisconnecting = false;

  // ── Rules section (Ograničenja) ──
  bool _editingRules = false;
  bool _savingRules = false;
  Map<String, String> _rulesSnapshot = {};

  // Snapshot for cancel/revert
  Map<String, String> _snapshot = {};
  Map<String, dynamic> _sponsorSnapshot = {};

  int _lastPricingVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadSponsor();
    _loadCalendarStatus();
  }

  @override
  void dispose() {
    _weekdayRateCtrl.dispose();
    _sundayRateCtrl.dispose();
    _studentCutoffCtrl.dispose();
    _seniorCutoffCtrl.dispose();
    _availabilityChangeCutoffCtrl.dispose();
    _travelBufferCtrl.dispose();
    _paymentTimingCtrl.dispose();
    _studentRateCtrl.dispose();
    _studentSundayRateCtrl.dispose();
    _intermediaryPctCtrl.dispose();
    _vatCtrl.dispose();
    _sponsorNameCtrl.dispose();
    _sponsorLogoCtrl.dispose();
    _sponsorDarkLogoCtrl.dispose();
    _sponsorLabelCtrl.dispose();
    super.dispose();
  }

  void _takeSponsorSnapshot() {
    _sponsorSnapshot = {
      'name': _sponsorNameCtrl.text,
      'logo': _sponsorLogoCtrl.text,
      'darkLogo': _sponsorDarkLogoCtrl.text,
      'label': _sponsorLabelCtrl.text,
      'labelMap': Map<String, String>.from(_sponsorLabelMap),
      'active': _sponsorActive,
    };
  }

  void _restoreSponsorSnapshot() {
    _sponsorNameCtrl.text = _sponsorSnapshot['name'] as String? ?? '';
    _sponsorLogoCtrl.text = _sponsorSnapshot['logo'] as String? ?? '';
    _sponsorDarkLogoCtrl.text = _sponsorSnapshot['darkLogo'] as String? ?? '';
    _sponsorLabelCtrl.text = _sponsorSnapshot['label'] as String? ?? '';
    _sponsorLabelMap = Map<String, String>.from(
      _sponsorSnapshot['labelMap'] as Map<String, String>? ?? {},
    );
    _sponsorActive = _sponsorSnapshot['active'] as bool? ?? false;
  }

  void _startEditingSponsor() {
    _takeSponsorSnapshot();
    setState(() => _editingSponsor = true);
  }

  void _cancelEditingSponsor() {
    _restoreSponsorSnapshot();
    setState(() => _editingSponsor = false);
  }

  void _takeRulesSnapshot() {
    _rulesSnapshot = {
      'studentCutoff': _studentCutoffCtrl.text,
      'seniorCutoff': _seniorCutoffCtrl.text,
      'studentCancelEnabled': _studentCancelEnabled ? '1' : '0',
      'availabilityChangeEnabled': _availabilityChangeEnabled ? '1' : '0',
      'availabilityChangeCutoff': _availabilityChangeCutoffCtrl.text,
    };
  }

  void _restoreRulesSnapshot() {
    _studentCutoffCtrl.text = _rulesSnapshot['studentCutoff'] ?? '';
    _seniorCutoffCtrl.text = _rulesSnapshot['seniorCutoff'] ?? '';
    _studentCancelEnabled = _rulesSnapshot['studentCancelEnabled'] == '1';
    _availabilityChangeEnabled =
        _rulesSnapshot['availabilityChangeEnabled'] == '1';
    _availabilityChangeCutoffCtrl.text =
        _rulesSnapshot['availabilityChangeCutoff'] ?? '';
  }

  void _startEditingRules() {
    _takeRulesSnapshot();
    setState(() => _editingRules = true);
  }

  void _cancelEditingRules() {
    _restoreRulesSnapshot();
    setState(() => _editingRules = false);
  }

  Future<void> _saveRules() async {
    setState(() => _savingRules = true);
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
          'studentCancelEnabled': _studentCancelEnabled,
          'availabilityChangeEnabled': _availabilityChangeEnabled,
          'availabilityChangeCutoffHours':
              int.tryParse(_availabilityChangeCutoffCtrl.text) ?? 24,
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
        queryParameters: {'reason': 'Admin rules update'},
      );
      if (!mounted) return;
      ref.read(pricingVersionProvider.notifier).state++;
      if (!mounted) return;
      setState(() => _editingRules = false);
      _showSnack(AppStrings.settingsSaved);
    } catch (_) {
      if (!mounted) return;
      _showSnack(AppStrings.settingsSaveFailed, isError: true);
    }
    if (!mounted) return;
    setState(() => _savingRules = false);
  }

  void _takeSnapshot() {
    _snapshot = {
      'weekday': _weekdayRateCtrl.text,
      'sunday': _sundayRateCtrl.text,
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
        _studentCancelEnabled = (cfg['studentCancelEnabled'] as bool?) ?? true;
        _availabilityChangeEnabled =
            (cfg['availabilityChangeEnabled'] as bool?) ?? true;
        _availabilityChangeCutoffCtrl.text =
            '${(cfg['availabilityChangeCutoffHours'] as num?) ?? 24}';
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

  Future<void> _loadSponsor() async {
    setState(() => _sponsorLoading = true);
    try {
      final result = await _adminApi.getSponsors();
      if (!mounted) return;
      if (result.success && result.data != null && result.data!.isNotEmpty) {
        final s = result.data!.first;
        _sponsorId = (s['id'] as num).toInt();
        _sponsorNameCtrl.text = s['name'] as String? ?? '';
        _sponsorLogoCtrl.text = s['logoUrl'] as String? ?? '';
        _sponsorDarkLogoCtrl.text = s['darkLogoUrl'] as String? ?? '';
        _sponsorLabelCtrl.text = '';
        final rawLabel = s['label'];
        if (rawLabel is Map) {
          _sponsorLabelMap = Map<String, String>.from(
            rawLabel.map((k, v) => MapEntry(k.toString(), v.toString())),
          );
          _sponsorLabelCtrl.text =
              _sponsorLabelMap[AppStrings.currentLocale] ??
              _sponsorLabelMap['hr'] ??
              '';
        }
        _sponsorActive = s['isActive'] as bool? ?? false;
      }
    } catch (_) {
      if (!mounted) return;
      showErrorSnack(context, AppStrings.sponsorLoadFailed);
    }
    if (!mounted) return;
    setState(() => _sponsorLoading = false);
  }

  Future<void> _loadCalendarStatus() async {
    setState(() => _calendarLoading = true);
    final result = await _adminApi.getCalendarStatus();
    if (!mounted) return;
    if (result.success && result.data != null) {
      final data = result.data!;
      _calendarConnected = data['isConnected'] as bool? ?? false;
      _calendarEmail = data['connectedEmail'] as String?;
      final raw = data['connectedAt'] as String?;
      _calendarConnectedAt = raw != null
          ? DateTime.tryParse(raw)?.toLocal()
          : null;
    }
    setState(() => _calendarLoading = false);
  }

  Future<void> _connectCalendar() async {
    setState(() => _calendarConnecting = true);
    final result = await _adminApi.getCalendarConnectUrl();
    if (!mounted) return;
    if (!result.success || result.data == null) {
      setState(() => _calendarConnecting = false);
      showErrorSnack(context, AppStrings.calendarConnectFailed);
      return;
    }
    final uri = Uri.parse(result.data!);
    bool launched = false;
    try {
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      launched = false;
    }
    if (!mounted) return;
    setState(() => _calendarConnecting = false);
    if (!launched) {
      showErrorSnack(context, AppStrings.calendarConnectFailed);
      return;
    }
    // Record when we started waiting so we can ignore stale tokens
    final pollStart = DateTime.now().toUtc();
    setState(() => _calendarConnecting = true);
    // Poll every 3s for up to 60s — only accept connection NEWER than pollStart
    for (var i = 0; i < 20; i++) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      await _loadCalendarStatus();
      if (!mounted) return;
      if (_calendarConnected &&
          _calendarConnectedAt != null &&
          _calendarConnectedAt!.toUtc().isAfter(pollStart)) {
        setState(() => _calendarConnecting = false);
        return;
      }
    }
    setState(() => _calendarConnecting = false);
  }

  Future<void> _disconnectCalendar() async {
    setState(() => _calendarDisconnecting = true);
    final result = await _adminApi.disconnectCalendar();
    if (!mounted) return;
    setState(() => _calendarDisconnecting = false);
    if (result.success) {
      showSuccessSnack(context, AppStrings.calendarDisconnectSuccess);
      await _loadCalendarStatus();
    } else {
      showErrorSnack(
        context,
        result.error ?? AppStrings.calendarDisconnectFailed,
      );
    }
  }

  Future<void> _saveSponsor() async {
    // Merge current text into the label map for the active locale
    _sponsorLabelMap[AppStrings.currentLocale] = _sponsorLabelCtrl.text;

    if (_sponsorId != null) {
      final result = await _adminApi.updateSponsor(
        id: _sponsorId!,
        name: _sponsorNameCtrl.text,
        logoUrl: _sponsorLogoCtrl.text,
        darkLogoUrl: _sponsorDarkLogoCtrl.text,
        labelMap: _sponsorLabelMap,
        isActive: _sponsorActive,
      );
      if (!mounted) return;
      if (!result.success) {
        _showSnack(AppStrings.sponsorSaveFailed, isError: true);
      }
    } else {
      final result = await _adminApi.createSponsor(
        name: _sponsorNameCtrl.text.isEmpty ? 'Sponsor' : _sponsorNameCtrl.text,
        logoUrl: _sponsorLogoCtrl.text,
        darkLogoUrl: _sponsorDarkLogoCtrl.text,
        labelMap: _sponsorLabelMap,
        isActive: _sponsorActive,
      );
      if (!mounted) return;
      if (result.success && result.data != null) {
        _sponsorId = (result.data!['id'] as num).toInt();
      } else {
        _showSnack(AppStrings.sponsorSaveFailed, isError: true);
      }
    }
  }

  /// Save sponsor independently (from its own Save button).
  Future<void> _saveSponsorOnly() async {
    setState(() => _savingSponsor = true);
    await _saveSponsor();
    if (!mounted) return;
    setState(() {
      _savingSponsor = false;
      _editingSponsor = false;
    });
    _showSnack(AppStrings.sponsorSaved);
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
          'studentCancelEnabled': _studentCancelEnabled,
          'availabilityChangeEnabled': _availabilityChangeEnabled,
          'availabilityChangeCutoffHours':
              int.tryParse(_availabilityChangeCutoffCtrl.text) ?? 24,
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
      setState(() => _editing = false);
      ref.read(pricingVersionProvider.notifier).state++;
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
    // Reload pricing when SettingsChanged fires (only if not editing)
    final pv = ref.watch(pricingVersionProvider);
    if (pv != _lastPricingVersion) {
      _lastPricingVersion = pv;
      if (pv > 0 && !_editing && !_editingRules) _loadSettings();
    }

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: HelpiAppBar(
        title: Text(AppStrings.settingsTitle),
        actions: const [NotificationBell()],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 600;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ═══════════════════════════════════════════
                //  CONFIGURATION (locked under Edit)
                // ═══════════════════════════════════════════
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: HelpiColors.of(context).surface,
                    borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
                    border: Border.all(color: HelpiColors.of(context).border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header: title + Edit/Save/Cancel ──
                      Row(
                        children: [
                          Icon(
                            Icons.settings,
                            size: 22,
                            color: HelpiTheme.accent,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              AppStrings.settingsConfiguration,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: HelpiColors.of(context).textPrimary,
                              ),
                            ),
                          ),
                          if (_editing)
                            SizedBox(
                              height: 36,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: _saving ? null : _cancelEditing,
                                    child: Text(AppStrings.cancel),
                                  ),
                                  const SizedBox(width: 4),
                                  _saving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : TextButton.icon(
                                          onPressed: _saveSettings,
                                          icon: const Icon(
                                            Icons.save,
                                            size: 18,
                                          ),
                                          label: Text(AppStrings.save),
                                          style: TextButton.styleFrom(
                                            foregroundColor: HelpiTheme.accent,
                                          ),
                                        ),
                                ],
                              ),
                            )
                          else
                            SizedBox(
                              width: 36,
                              height: 36,
                              child: IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                tooltip: AppStrings.edit,
                                onPressed: _startEditing,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Pricing ──
                      _subSectionHeader(AppStrings.settingsPricing),
                      const SizedBox(height: 8),
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
                      const SizedBox(height: 20),

                      // ── Student rates ──
                      _subSectionHeader(AppStrings.settingsStudentRates),
                      const SizedBox(height: 8),
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
                      const SizedBox(height: 20),

                      // ── Operational ──
                      _subSectionHeader(AppStrings.settingsOperational),
                      const SizedBox(height: 8),
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
                          suffix: 'min prije',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Earnings ──
                      _subSectionHeader(AppStrings.settingsEarnings),
                      const SizedBox(height: 8),
                      _fieldPair(
                        wide: wide,
                        first: _numField(
                          _intermediaryPctCtrl,
                          AppStrings.intermediaryPercentage,
                          suffix: '%',
                          decimal: true,
                        ),
                        second: _numField(
                          _vatCtrl,
                          AppStrings.vatPercentage,
                          suffix: '%',
                          decimal: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // ═══════════════════════════════════════════
                //  OGRANIČENJA (rules — own Edit/Save/Cancel)
                // ═══════════════════════════════════════════
                _sectionCard(
                  icon: Icons.rule,
                  title: AppStrings.settingsRestrictions,
                  trailing: _editingRules
                      ? SizedBox(
                          height: 36,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: _savingRules
                                    ? null
                                    : _cancelEditingRules,
                                child: Text(AppStrings.cancel),
                              ),
                              const SizedBox(width: 4),
                              _savingRules
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : TextButton.icon(
                                      onPressed: _saveRules,
                                      icon: const Icon(Icons.save, size: 18),
                                      label: Text(AppStrings.save),
                                      style: TextButton.styleFrom(
                                        foregroundColor: HelpiTheme.accent,
                                      ),
                                    ),
                            ],
                          ),
                        )
                      : SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            tooltip: AppStrings.edit,
                            onPressed: _startEditingRules,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                  children: [
                    // ── Cancel rules ──
                    _subSectionHeader(AppStrings.settingsCancelRules),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Opacity(
                          opacity: _editingRules ? 1.0 : 0.5,
                          child: HelpiSwitch(
                            value: _studentCancelEnabled,
                            onChanged: _editingRules
                                ? (v) =>
                                      setState(() => _studentCancelEnabled = v)
                                : (_) {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.studentCancelEnabled,
                          style: TextStyle(
                            fontSize: 12,
                            color: HelpiColors.of(context).textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_studentCancelEnabled)
                      _fieldPair(
                        wide: wide,
                        first: _numField(
                          _seniorCutoffCtrl,
                          AppStrings.seniorCancelCutoff,
                          suffix: 'sati prije',
                          editing: _editingRules,
                        ),
                        second: _numField(
                          _studentCutoffCtrl,
                          AppStrings.studentCancelCutoff,
                          suffix: 'sati prije',
                          editing: _editingRules,
                        ),
                      )
                    else
                      _numField(
                        _seniorCutoffCtrl,
                        AppStrings.seniorCancelCutoff,
                        suffix: 'sati prije',
                        editing: _editingRules,
                      ),
                    const SizedBox(height: 20),

                    // ── Availability change rules ──
                    _subSectionHeader(AppStrings.settingsAvailabilityRules),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Opacity(
                          opacity: _editingRules ? 1.0 : 0.5,
                          child: HelpiSwitch(
                            value: _availabilityChangeEnabled,
                            onChanged: _editingRules
                                ? (v) => setState(
                                    () => _availabilityChangeEnabled = v,
                                  )
                                : (_) {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.availabilityChangeEnabled,
                          style: TextStyle(
                            fontSize: 12,
                            color: HelpiColors.of(context).textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (_availabilityChangeEnabled) ...[
                      const SizedBox(height: 12),
                      _numField(
                        _availabilityChangeCutoffCtrl,
                        AppStrings.availabilityChangeCutoff,
                        suffix: 'sati prije',
                        editing: _editingRules,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),

                // ═══════════════════════════════════════════
                //  PREFERENCES (always interactive)
                // ═══════════════════════════════════════════

                // ── Sponsor ──
                _sectionCard(
                  icon: Icons.handshake_outlined,
                  title: AppStrings.settingsSponsor,
                  trailing: _editingSponsor
                      ? SizedBox(
                          height: 36,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: _savingSponsor
                                    ? null
                                    : _cancelEditingSponsor,
                                child: Text(AppStrings.cancel),
                              ),
                              const SizedBox(width: 4),
                              _savingSponsor
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : TextButton.icon(
                                      onPressed: _saveSponsorOnly,
                                      icon: const Icon(Icons.save, size: 18),
                                      label: Text(AppStrings.save),
                                      style: TextButton.styleFrom(
                                        foregroundColor: HelpiTheme.accent,
                                      ),
                                    ),
                            ],
                          ),
                        )
                      : SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            tooltip: AppStrings.edit,
                            onPressed: _startEditingSponsor,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                  children: _sponsorLoading
                      ? [
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ]
                      : [
                          // Switch on top
                          Row(
                            children: [
                              Opacity(
                                opacity: _editingSponsor ? 1.0 : 0.5,
                                child: HelpiSwitch(
                                  value: _sponsorActive,
                                  onChanged: _editingSponsor
                                      ? (v) =>
                                            setState(() => _sponsorActive = v)
                                      : (_) {},
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppStrings.sponsorActive,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: HelpiColors.of(context).textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Label field below (greyed out when inactive)
                          Opacity(
                            opacity: _sponsorActive ? 1.0 : 0.5,
                            child: _sponsorTextField(
                              _sponsorLabelCtrl,
                              AppStrings.sponsorLabel,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Logo cards
                          if (wide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _logoCard(
                                    label: AppStrings.sponsorLogoUrl,
                                    currentUrl: _sponsorLogoCtrl.text,
                                    uploading: _uploadingLight,
                                    buttonLabel: AppStrings.sponsorChooseLogo,
                                    onPick: () => _pickAndUploadLogo('light'),
                                    onDelete: () => _deleteLogo('light'),
                                    canDelete: !_sponsorActive,
                                    enabled: _editingSponsor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _logoCard(
                                    label: AppStrings.sponsorDarkLogoUrl,
                                    currentUrl: _sponsorDarkLogoCtrl.text,
                                    uploading: _uploadingDark,
                                    buttonLabel:
                                        AppStrings.sponsorChooseDarkLogo,
                                    onPick: () => _pickAndUploadLogo('dark'),
                                    onDelete: () => _deleteLogo('dark'),
                                    canDelete: true,
                                    enabled: _editingSponsor,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _logoCard(
                              label: AppStrings.sponsorLogoUrl,
                              currentUrl: _sponsorLogoCtrl.text,
                              uploading: _uploadingLight,
                              buttonLabel: AppStrings.sponsorChooseLogo,
                              onPick: () => _pickAndUploadLogo('light'),
                              onDelete: () => _deleteLogo('light'),
                              canDelete: !_sponsorActive,
                              enabled: _editingSponsor,
                            ),
                            const SizedBox(height: 12),
                            _logoCard(
                              label: AppStrings.sponsorDarkLogoUrl,
                              currentUrl: _sponsorDarkLogoCtrl.text,
                              uploading: _uploadingDark,
                              buttonLabel: AppStrings.sponsorChooseDarkLogo,
                              onPick: () => _pickAndUploadLogo('dark'),
                              onDelete: () => _deleteLogo('dark'),
                              canDelete: true,
                              enabled: _editingSponsor,
                            ),
                          ],
                        ],
                ),
                const SizedBox(height: 10),

                // ── Google Calendar ──
                _sectionCard(
                  icon: Icons.calendar_today,
                  title: AppStrings.calendarTitle,
                  children: [
                    if (_calendarLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(AppStrings.calendarStatusLoading),
                      )
                    else if (_calendarConnected)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${AppStrings.calendarConnected} · ${AppStrings.calendarConnectedAs} ${_calendarEmail ?? ''}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ActionChipButton(
                            icon: Icons.link_off,
                            label: AppStrings.calendarDisconnect,
                            color: Colors.red,
                            loading: _calendarDisconnecting,
                            onTap: _calendarDisconnecting
                                ? () {}
                                : _disconnectCalendar,
                          ),
                        ],
                      )
                    else
                      ActionChipButton(
                        icon: Icons.add_link,
                        label: _calendarConnecting
                            ? AppStrings.calendarConnecting
                            : AppStrings.calendarConnect,
                        color: HelpiTheme.accent,
                        loading: _calendarConnecting,
                        onTap: _calendarConnecting ? () {} : _connectCalendar,
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Language ──
                _sectionCard(
                  icon: Icons.language,
                  title: AppStrings.settingsLanguage,
                  children: [
                    DropdownButtonFormField<String>(
                      value: AppStrings.currentLocale,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          value: 'hr',
                          child: Text(AppStrings.langHr),
                        ),
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(AppStrings.langEn),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          widget.localeNotifier.setLocale(v);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

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
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Sub-section header inside the config card ──
  Widget _subSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: HelpiColors.of(context).textPrimary,
      ),
    );
  }

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
    Widget? trailing,
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
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: HelpiColors.of(context).textPrimary,
                  ),
                ),
              ),
              ?trailing,
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
    bool? editing,
  }) {
    final isEditing = editing ?? _editing;
    return TextField(
      controller: ctrl,
      readOnly: !isEditing,
      enabled: isEditing,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        if (decimal)
          FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: label,
        fillColor: isEditing ? null : HelpiColors.of(context).chipBg,
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
          borderSide: BorderSide(color: HelpiColors.of(context).border),
        ),
        suffixIcon: (suffix != null || isEditing)
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
                    if (isEditing) ...[
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

  // ── Text field for Sponsor section (respects _editingSponsor) ──
  Widget _sponsorTextField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      readOnly: !_editingSponsor,
      enabled: _editingSponsor,
      decoration: InputDecoration(
        labelText: label,
        fillColor: _editingSponsor ? null : HelpiColors.of(context).chipBg,
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
          borderSide: BorderSide(color: HelpiColors.of(context).border),
        ),
      ),
    );
  }

  // ── Logo card: bordered box with larger preview, title, actions ──
  Widget _logoCard({
    required String label,
    required String currentUrl,
    required bool uploading,
    required String buttonLabel,
    required VoidCallback onPick,
    VoidCallback? onDelete,
    bool canDelete = true,
    bool enabled = true,
    String? hint,
  }) {
    final hasLogo = currentUrl.isNotEmpty;
    final fullUrl = '${ApiEndpoints.baseUrl}$currentUrl';
    final isSvg = currentUrl.toLowerCase().endsWith('.svg');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: HelpiColors.of(context).border.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: HelpiColors.of(context).textSecondary,
            ),
          ),
          if (hint != null && !hasLogo)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                hint,
                style: TextStyle(
                  fontSize: 11,
                  color: HelpiColors.of(
                    context,
                  ).textSecondary.withValues(alpha: 0.6),
                ),
              ),
            ),
          const SizedBox(height: 10),

          // Preview area
          Container(
            width: double.infinity,
            height: 72,
            decoration: BoxDecoration(
              color: HelpiColors.of(context).background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: HelpiColors.of(context).border.withValues(alpha: 0.3),
              ),
            ),
            child: hasLogo
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: isSvg
                          ? SvgPicture.network(
                              fullUrl,
                              fit: BoxFit.contain,
                              placeholderBuilder: (_) =>
                                  const Icon(Icons.image, size: 28),
                            )
                          : Image.network(
                              fullUrl,
                              fit: BoxFit.contain,
                              gaplessPlayback: true,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.broken_image, size: 28),
                            ),
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 28,
                      color: HelpiColors.of(
                        context,
                      ).textSecondary.withValues(alpha: 0.3),
                    ),
                  ),
          ),
          const SizedBox(height: 8),

          // Actions row
          Row(
            children: [
              Expanded(
                child: hasLogo
                    ? Text(
                        Uri.parse(currentUrl).pathSegments.last,
                        style: TextStyle(
                          fontSize: 11,
                          color: HelpiColors.of(context).textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text(
                        AppStrings.sponsorNoLogo,
                        style: TextStyle(
                          fontSize: 12,
                          color: HelpiColors.of(
                            context,
                          ).textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
              ),
              if (hasLogo && onDelete != null)
                IconButton(
                  onPressed: enabled && canDelete
                      ? onDelete
                      : enabled && !canDelete
                      ? () => showErrorSnack(
                          context,
                          AppStrings.sponsorDeleteLogoMsg,
                        )
                      : null,
                  icon: Icon(
                    Icons.close,
                    size: 16,
                    color: !enabled
                        ? HelpiColors.of(
                            context,
                          ).textSecondary.withValues(alpha: 0.2)
                        : canDelete
                        ? Colors.red.shade400
                        : HelpiColors.of(
                            context,
                          ).textSecondary.withValues(alpha: 0.4),
                  ),
                  tooltip: canDelete
                      ? AppStrings.sponsorDeleteLogoTitle
                      : AppStrings.sponsorDeleteLogoMsg,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  padding: EdgeInsets.zero,
                ),
              uploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton.icon(
                      onPressed: enabled ? onPick : null,
                      icon: const Icon(Icons.upload_file, size: 16),
                      label: Text(buttonLabel),
                      style: TextButton.styleFrom(
                        foregroundColor: HelpiTheme.accent,
                        disabledForegroundColor: HelpiColors.of(
                          context,
                        ).textSecondary.withValues(alpha: 0.3),
                        textStyle: const TextStyle(fontSize: 11),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Delete logo from backend ──
  Future<void> _deleteLogo(String variant) async {
    if (_sponsorId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.sponsorDeleteLogoTitle),
        content: Text(AppStrings.sponsorDeleteLogoConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: HelpiTheme.error),
            child: Text(AppStrings.sponsorDeleteLogoTitle),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    final result = await _adminApi.deleteSponsorLogo(
      sponsorId: _sponsorId!,
      variant: variant,
    );
    if (!mounted) return;

    if (result.success) {
      setState(() {
        if (variant == 'dark') {
          _sponsorDarkLogoCtrl.text = '';
        } else {
          _sponsorLogoCtrl.text = '';
        }
      });
    } else {
      showErrorSnack(context, result.error ?? AppStrings.sponsorDeleteFailed);
    }
  }

  // ── Pick image file and upload to backend ──
  Future<void> _pickAndUploadLogo(String variant) async {
    // Ensure sponsor exists in DB first
    if (_sponsorId == null) {
      final result = await _adminApi.createSponsor(
        name: _sponsorNameCtrl.text.isEmpty ? 'Sponsor' : _sponsorNameCtrl.text,
        logoUrl: '',
        isActive: _sponsorActive,
      );
      if (!mounted) return;
      if (!result.success || result.data == null) {
        showErrorSnack(context, AppStrings.sponsorSaveFailed);
        return;
      }
      _sponsorId = (result.data!['id'] as num).toInt();
    }

    const imageType = XTypeGroup(
      label: 'Images',
      extensions: ['svg', 'png', 'jpg', 'jpeg', 'webp'],
    );
    final file = await openFile(acceptedTypeGroups: [imageType]);
    if (!mounted || file == null) return;

    setState(() {
      if (variant == 'dark') {
        _uploadingDark = true;
      } else {
        _uploadingLight = true;
      }
    });

    final fileBytes = await file.readAsBytes();
    if (!mounted) return;

    final result = await _adminApi.uploadSponsorLogo(
      sponsorId: _sponsorId!,
      fileBytes: Uint8List.fromList(fileBytes),
      fileName: file.name,
      variant: variant,
    );

    if (!mounted) return;

    setState(() {
      if (variant == 'dark') {
        _uploadingDark = false;
      } else {
        _uploadingLight = false;
      }
    });

    if (result.success && result.data != null) {
      setState(() {
        if (variant == 'dark') {
          _sponsorDarkLogoCtrl.text = result.data!;
        } else {
          _sponsorLogoCtrl.text = result.data!;
        }
      });
    } else {
      showErrorSnack(context, result.error ?? AppStrings.sponsorUploadFailed);
    }
  }
}
