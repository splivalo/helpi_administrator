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
      AppStrings.studentName,
      AppStrings.studentEmail,
      AppStrings.studentPhone,
      AppStrings.studentAddress,
      AppStrings.filterByCity,
      AppStrings.studentFaculty,
      AppStrings.studentIdNumber,
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
        s.fullName,
        s.email,
        s.phone,
        s.address,
        s.city,
        s.faculty,
        s.studentIdNumber,
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
      AppStrings.seniorName,
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
        s.fullName,
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

  /// Downloads Excel file. On web, file goes to browser's Downloads folder.
  /// User can configure browser to "Ask where to save" for folder picker.
  static Future<bool> _downloadExcel(Excel excel, String baseFileName) async {
    final bytes = excel.save();
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
