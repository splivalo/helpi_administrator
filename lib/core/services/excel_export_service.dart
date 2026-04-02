import 'dart:html' as html;
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/utils/formatters.dart';

/// Excel Export Service za export filtriranih podataka u .xlsx format.
class ExcelExportService {
  ExcelExportService._();

  /// Exporta listu studenata u Excel datoteku.
  /// Returns true if saved successfully, false if cancelled.
  static Future<bool> exportStudents(
    List<StudentModel> students,
    String filterName,
  ) async {
    final excel = Excel.createExcel();
    final sheetName = AppStrings.studentsTitle;
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    // Header row
    final headers = [
      AppStrings.studentFirstName,
      AppStrings.studentLastName,
      AppStrings.studentEmail,
      AppStrings.studentPhone,
      AppStrings.studentAddress,
      AppStrings.filterByCity,
      AppStrings.studentFaculty,
      AppStrings.studentDateOfBirth,
      AppStrings.studentGender,
      AppStrings.contractStatus,
      AppStrings.studentContractExpiry,
      AppStrings.studentRating,
      AppStrings.studentCompletedJobs,
      AppStrings.studentCancelledJobs,
      AppStrings.workHourlyRate,
      AppStrings.workSundayRate,
      AppStrings.studentCreatedAt,
    ];

    // Header style
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#4A90A4'),
      fontColorHex: ExcelColor.white,
      horizontalAlign: HorizontalAlign.Center,
    );

    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Data rows
    for (var rowIdx = 0; rowIdx < students.length; rowIdx++) {
      final s = students[rowIdx];
      final rowData = [
        s.firstName,
        s.lastName,
        s.email,
        s.phone,
        s.address,
        s.city,
        s.faculty,
        formatDate(s.dateOfBirth),
        _genderLabel(s.gender),
        _contractStatusLabel(s.contractStatus),
        s.contractExpiryDate != null ? formatDate(s.contractExpiryDate!) : '-',
        s.avgRating.toStringAsFixed(1),
        s.completedJobs.toString(),
        s.cancelledJobs.toString(),
        '${s.hourlyRate.toStringAsFixed(2)} €',
        '${s.sundayHourlyRate.toStringAsFixed(2)} €',
        formatDate(s.createdAt),
      ];

      for (var colIdx = 0; colIdx < rowData.length; colIdx++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: colIdx, rowIndex: rowIdx + 1),
        );
        cell.value = TextCellValue(rowData[colIdx]);
      }
    }

    // Auto width approximation (Excel package doesn't support auto-width directly)
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 18);
    }

    return _downloadExcel(excel, 'studenti_$filterName');
  }

  /// Exporta listu seniora u Excel datoteku.
  /// Returns true if saved successfully, false if cancelled.
  static Future<bool> exportSeniors(
    List<SeniorModel> seniors,
    String filterName,
  ) async {
    final excel = Excel.createExcel();
    final sheetName = AppStrings.seniorsTitle;
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    // Header row
    final headers = [
      AppStrings.seniorFirstName,
      AppStrings.seniorLastName,
      AppStrings.seniorEmail,
      AppStrings.seniorPhone,
      AppStrings.seniorAddress,
      AppStrings.filterByCity,
      AppStrings.studentDateOfBirth,
      AppStrings.studentGender,
      AppStrings.seniorOrdererName,
      AppStrings.seniorOrdererPhone,
      AppStrings.seniorOrdererEmail,
      AppStrings.studentCreatedAt,
    ];

    // Header style
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#4A90A4'),
      fontColorHex: ExcelColor.white,
      horizontalAlign: HorizontalAlign.Center,
    );

    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Data rows
    for (var rowIdx = 0; rowIdx < seniors.length; rowIdx++) {
      final s = seniors[rowIdx];
      final rowData = [
        s.firstName,
        s.lastName,
        s.email,
        s.phone,
        s.address,
        s.city,
        formatDate(s.dateOfBirth),
        _genderLabel(s.gender),
        s.hasOrderer ? s.ordererFullName : '-',
        s.hasOrderer ? (s.ordererPhone ?? '-') : '-',
        s.hasOrderer ? (s.ordererEmail ?? '-') : '-',
        formatDate(s.createdAt),
      ];

      for (var colIdx = 0; colIdx < rowData.length; colIdx++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: colIdx, rowIndex: rowIdx + 1),
        );
        cell.value = TextCellValue(rowData[colIdx]);
      }
    }

    // Set column widths
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 18);
    }

    return _downloadExcel(excel, 'seniori_$filterName');
  }

  static String _genderLabel(Gender gender) {
    return switch (gender) {
      Gender.male => AppStrings.genderMale,
      Gender.female => AppStrings.genderFemale,
    };
  }

  static String _contractStatusLabel(ContractStatus status) {
    return switch (status) {
      ContractStatus.active => AppStrings.contractActive,
      ContractStatus.expired => AppStrings.contractExpired,
      ContractStatus.none => AppStrings.contractNone,
    };
  }

  /// Data class for a single day of analytics.
  /// All 7 columns are pre-computed by the caller so the export has zero
  /// business-logic of its own.
  static Future<bool> exportAnalytics({
    required List<AnalyticsDayRow> currentData,
    required DateTime rangeStart,
    required DateTime rangeEnd,
    List<AnalyticsDayRow>? compData,
    DateTime? compStart,
    DateTime? compEnd,
  }) async {
    final excel = Excel.createExcel();
    String fmtDate(DateTime d) => '${d.day}.${d.month}.${d.year}';

    // ── Header style ──
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#4A90A4'),
      fontColorHex: ExcelColor.white,
      horizontalAlign: HorizontalAlign.Center,
    );
    final totalStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#E8F5E9'),
    );

    List<String> dayHeaders() => [
      AppStrings.analyticsExportDate,
      AppStrings.analyticsOrders,
      AppStrings.analyticsExportGrossRevenue,
      AppStrings.analyticsExportStripeFee,
      AppStrings.analyticsExportStudentPay,
      AppStrings.analyticsExportStudentService,
      AppStrings.analyticsEarnings,
      AppStrings.analyticsActiveSeniors,
    ];

    void writeDaySheet(Sheet sheet, List<AnalyticsDayRow> rows) {
      final headers = dayHeaders();
      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      for (var r = 0; r < rows.length; r++) {
        final row = rows[r];
        final vals = [
          fmtDate(row.date),
          row.orders.toStringAsFixed(0),
          '€${row.grossRevenue.toStringAsFixed(2)}',
          '€${row.stripeFee.toStringAsFixed(2)}',
          '€${row.studentPay.toStringAsFixed(2)}',
          '€${row.studentService.toStringAsFixed(2)}',
          '€${row.helpiNeto.toStringAsFixed(2)}',
          row.activeSeniors.toStringAsFixed(0),
        ];
        for (var c = 0; c < vals.length; c++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1))
              .value = TextCellValue(
            vals[c],
          );
        }
      }

      // Totals row
      final totIdx = rows.length + 1;
      final totals = _sumRows(rows);
      final totVals = [
        AppStrings.analyticsExportTotal,
        totals.orders.toStringAsFixed(0),
        '€${totals.grossRevenue.toStringAsFixed(2)}',
        '€${totals.stripeFee.toStringAsFixed(2)}',
        '€${totals.studentPay.toStringAsFixed(2)}',
        '€${totals.studentService.toStringAsFixed(2)}',
        '€${totals.helpiNeto.toStringAsFixed(2)}',
        totals.activeSeniors.toStringAsFixed(0),
      ];
      for (var c = 0; c < totVals.length; c++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: c, rowIndex: totIdx),
        );
        cell.value = TextCellValue(totVals[c]);
        cell.cellStyle = totalStyle;
      }

      for (var i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 20);
      }
    }

    // ── Sheet 1: Current period ──
    final sheetName = '${fmtDate(rangeStart)} - ${fmtDate(rangeEnd)}';
    excel.rename('Sheet1', sheetName);
    writeDaySheet(excel[sheetName], currentData);

    // ── Sheet 2 + 3: Comparison (only if comparison is active) ──
    if (compData != null && compStart != null && compEnd != null) {
      final compSheetName = '${fmtDate(compStart)} - ${fmtDate(compEnd)}';
      writeDaySheet(excel[compSheetName], compData);

      // Summary sheet
      final summarySheet = excel[AppStrings.analyticsExportSummarySheet];
      final summaryHeaders = [
        AppStrings.analyticsExportMetric,
        AppStrings.analyticsExportCurrentPeriod,
        AppStrings.analyticsExportPreviousPeriod,
        AppStrings.analyticsExportChange,
      ];
      for (var i = 0; i < summaryHeaders.length; i++) {
        final cell = summarySheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(summaryHeaders[i]);
        cell.cellStyle = headerStyle;
      }

      final curTot = _sumRows(currentData);
      final prevTot = _sumRows(compData);

      String pctStr(double cur, double prev) {
        if (prev == 0 && cur == 0) return '0%';
        if (prev == 0) return '+100%';
        final pct = ((cur - prev) / prev) * 100;
        return '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(1)}%';
      }

      final metrics = [
        [
          AppStrings.analyticsOrders,
          curTot.orders.toStringAsFixed(0),
          prevTot.orders.toStringAsFixed(0),
          pctStr(curTot.orders, prevTot.orders),
        ],
        [
          AppStrings.analyticsExportGrossRevenue,
          '€${curTot.grossRevenue.toStringAsFixed(2)}',
          '€${prevTot.grossRevenue.toStringAsFixed(2)}',
          pctStr(curTot.grossRevenue, prevTot.grossRevenue),
        ],
        [
          AppStrings.analyticsEarnings,
          '€${curTot.helpiNeto.toStringAsFixed(2)}',
          '€${prevTot.helpiNeto.toStringAsFixed(2)}',
          pctStr(curTot.helpiNeto, prevTot.helpiNeto),
        ],
        [
          AppStrings.analyticsActiveSeniors,
          curTot.activeSeniors.toStringAsFixed(0),
          prevTot.activeSeniors.toStringAsFixed(0),
          pctStr(curTot.activeSeniors, prevTot.activeSeniors),
        ],
      ];

      for (var r = 0; r < metrics.length; r++) {
        for (var c = 0; c < metrics[r].length; c++) {
          summarySheet
              .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1))
              .value = TextCellValue(
            metrics[r][c],
          );
        }
      }

      for (var i = 0; i < summaryHeaders.length; i++) {
        summarySheet.setColumnWidth(i, 22);
      }
    }

    final fileName = 'analitika_${fmtDate(rangeStart)}-${fmtDate(rangeEnd)}';
    return _downloadExcel(excel, fileName);
  }

  static AnalyticsDayRow _sumRows(List<AnalyticsDayRow> rows) {
    var orders = 0.0;
    var gross = 0.0;
    var stripe = 0.0;
    var student = 0.0;
    var service = 0.0;
    var neto = 0.0;
    var seniors = 0.0;
    for (final r in rows) {
      orders += r.orders;
      gross += r.grossRevenue;
      stripe += r.stripeFee;
      student += r.studentPay;
      service += r.studentService;
      neto += r.helpiNeto;
      if (r.activeSeniors > seniors) seniors = r.activeSeniors;
    }
    return AnalyticsDayRow(
      date: rows.first.date,
      orders: orders,
      grossRevenue: gross,
      stripeFee: stripe,
      studentPay: student,
      studentService: service,
      helpiNeto: neto,
      activeSeniors: seniors,
    );
  }

  /// Downloads Excel file. On web, file goes to browser's Downloads folder.
  /// User can configure browser to "Ask where to save" for folder picker.
  static Future<bool> _downloadExcel(Excel excel, String baseFileName) async {
    // Use encode() instead of save() to avoid auto-download on web
    // save() on web triggers default "FlutterExcel.xlsx" download
    final bytes = excel.encode();
    if (bytes == null) return false;

    final now = DateTime.now();
    final timestamp =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final suggestedName = '${baseFileName}_$timestamp.xlsx';

    final data = Uint8List.fromList(bytes);
    final blob = html.Blob([
      data,
    ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');

    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', suggestedName)
      ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    // Delay URL revocation to ensure download starts
    Future.delayed(const Duration(seconds: 1), () {
      html.Url.revokeObjectUrl(url);
    });

    return true;
  }
}

/// Pre-computed analytics data for a single day — used by [ExcelExportService.exportAnalytics].
class AnalyticsDayRow {
  final DateTime date;
  final double orders;
  final double grossRevenue;
  final double stripeFee;
  final double studentPay;
  final double studentService;
  final double helpiNeto;
  final double activeSeniors;

  const AnalyticsDayRow({
    required this.date,
    required this.orders,
    required this.grossRevenue,
    required this.stripeFee,
    required this.studentPay,
    required this.studentService,
    required this.helpiNeto,
    required this.activeSeniors,
  });
}
