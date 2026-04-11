import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/utils/formatters.dart';

// Shared form helpers for add/edit senior screens.
mixin SeniorFormHelpers<T extends StatefulWidget> on State<T> {
  Widget buildSectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: HelpiTheme.accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: HelpiColors.of(context).textPrimary,
          ),
        ),
      ],
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty)
                ? AppStrings.fieldRequired
                : null
          : null,
    );
  }

  Widget buildGenderSelector({
    required Gender? value,
    required ValueChanged<Gender?> onChanged,
  }) {
    return DropdownButtonFormField<Gender>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: AppStrings.selectGender,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items: [
        DropdownMenuItem(
          value: Gender.male,
          child: Text(AppStrings.genderMale),
        ),
        DropdownMenuItem(
          value: Gender.female,
          child: Text(AppStrings.genderFemale),
        ),
      ],
      onChanged: onChanged,
      validator: (v) => v == null ? AppStrings.fieldRequired : null,
    );
  }

  Widget buildDatePicker({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime(1945, 1, 1),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          confirmText: AppStrings.ok,
          cancelText: AppStrings.cancel,
        );
        if (picked != null) {
          if (!context.mounted) return;
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
        ),
        child: Text(
          value != null ? formatDateDot(value) : AppStrings.selectDate,
          style: TextStyle(
            fontSize: 14,
            color: value != null
                ? HelpiColors.of(context).textPrimary
                : HelpiColors.of(context).textSecondary,
          ),
        ),
      ),
    );
  }
}
