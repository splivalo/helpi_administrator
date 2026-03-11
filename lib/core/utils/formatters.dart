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

/// Converts a [TimeOfDay] to total minutes since midnight.
int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

/// Returns `true` if time range [s1,e1) overlaps with [s2,e2) (in minutes).
bool timeOverlaps(int s1, int e1, int s2, int e2) => s1 < e2 && s2 < e1;

/// Returns `true` if [a] and [b] fall on the same calendar day.
bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
