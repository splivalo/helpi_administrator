// Shared date/time formatters — eliminates inline formatting duplication.

import 'package:flutter/material.dart';

/// Formats a [DateTime] as `dd.MM.yyyy` (e.g. `05.03.2026`).
String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

/// Formats a [DateTime] time as `HH:mm` (e.g. `09:30`).
String formatTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Formats a [TimeOfDay] as `HH:mm` (e.g. `09:30`).
String formatTimeOfDay(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// Formats a [DateTime] as `dd.MM.yyyy` with trailing dot (e.g. `05.03.2026.`).
/// Used for birth dates in Croatian locale.
String formatDateDot(DateTime d) => '${formatDate(d)}.';
