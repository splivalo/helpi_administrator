import 'package:flutter/material.dart';

import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/utils/formatters.dart';

/// Base class for session-preview helpers used by student-detail and
/// order-detail assign flows. Subclasses supply:
/// - [generateSessions] — different session-generation logic per context
/// - [buildConflictMessage] — different message format
/// - [isSubstituteCandidate] / [onNoAvailability] — substitute pre-filter hooks
abstract class SessionPreviewHelperBase {
  SessionPreviewHelperBase({required this.student, required this.order});

  final StudentModel student;
  final OrderModel order;

  // ── Abstract ────────────────────────────────────────────────

  List<SessionInstancePreview> generateSessions();
  String buildConflictMessage(SessionInstancePreview s);

  // ── Hooks (override to customise substitute filtering) ──────

  /// Return `false` to exclude a candidate before availability check.
  bool isSubstituteCandidate(StudentModel s) => s.id != student.id;

  /// Called when the candidate has no matching availability entry.
  /// Student-context returns `false`; order-context returns
  /// `s.availability.isEmpty` (treat "no data" as potentially available).
  bool onNoAvailability(StudentModel s) => false;

  /// Minutes of travel buffer between two consecutive Helpi sessions.
  static const _buffer = 15;

  // ── Shared: find scheduling conflict ────────────────────────

  OrderModel? findConflict({
    required DateTime date,
    required int weekday,
    required int startMin,
    required int endMin,
    required List<OrderModel> studentOrders,
  }) {
    for (final existing in studentOrders) {
      if (existing.dayEntries.isNotEmpty) {
        for (final entry in existing.dayEntries) {
          if (entry.dayOfWeek == weekday) {
            final exStart = toMinutes(entry.startTime);
            final exEnd = exStart + entry.durationHours * 60;
            if (timeOverlaps(
              startMin,
              endMin,
              exStart - _buffer,
              exEnd + _buffer,
            ))
              return existing;
          }
        }
      } else if (sameDay(existing.scheduledDate, date)) {
        final exStart = toMinutes(existing.scheduledStart);
        final exEnd = exStart + existing.durationHours * 60;
        if (timeOverlaps(startMin, endMin, exStart - _buffer, exEnd + _buffer))
          return existing;
      }
    }
    return null;
  }

  // ── Shared: find substitutes ────────────────────────────────

  List<StudentModel> findSubstitutes(SessionInstancePreview session) {
    return MockData.students.where((s) {
      if (!isSubstituteCandidate(s)) return false;
      final avail = s.availability.where(
        (a) => a.dayOfWeek == session.weekday && a.isEnabled,
      );
      if (avail.isEmpty) return onNoAvailability(s);
      final a = avail.first;
      final sStart = toMinutes(session.startTime);
      final sEnd = sStart + session.durationHours * 60;
      if (toMinutes(a.from) > sStart || toMinutes(a.to) < sEnd) return false;
      final subOrders = MockData.orders.where(
        (o) => o.student?.id == s.id && o.status != OrderStatus.cancelled,
      );
      for (final o in subOrders) {
        if (o.dayEntries.isNotEmpty) {
          for (final entry in o.dayEntries) {
            if (entry.dayOfWeek == session.weekday) {
              final exS = toMinutes(entry.startTime);
              if (timeOverlaps(
                sStart,
                sEnd,
                exS - _buffer,
                exS + entry.durationHours * 60 + _buffer,
              )) {
                return false;
              }
            }
          }
        } else if (sameDay(o.scheduledDate, session.date)) {
          final exS = toMinutes(o.scheduledStart);
          if (timeOverlaps(
            sStart,
            sEnd,
            exS - _buffer,
            exS + o.durationHours * 60 + _buffer,
          )) {
            return false;
          }
        }
      }
      return true;
    }).toList();
  }

  // ── Shared: find alternative time slots ─────────────────────

  List<TimeOfDay> findAltSlots(SessionInstancePreview session) {
    final avail = student.availability.where(
      (a) => a.dayOfWeek == session.weekday && a.isEnabled,
    );
    if (avail.isEmpty) return [];
    final a = avail.first;
    final availFrom = toMinutes(a.from);
    final availTo = toMinutes(a.to);
    final dur = session.durationHours * 60;

    final busy = <({int start, int end})>[];
    for (final o in MockData.orders.where(
      (o) => o.student?.id == student.id && o.status != OrderStatus.cancelled,
    )) {
      if (o.dayEntries.isNotEmpty) {
        for (final e in o.dayEntries) {
          if (e.dayOfWeek == session.weekday) {
            final s = toMinutes(e.startTime);
            busy.add((
              start: s - _buffer,
              end: s + e.durationHours * 60 + _buffer,
            ));
          }
        }
      } else if (sameDay(o.scheduledDate, session.date)) {
        final s = toMinutes(o.scheduledStart);
        busy.add((start: s - _buffer, end: s + o.durationHours * 60 + _buffer));
      }
    }
    busy.sort((a, b) => a.start.compareTo(b.start));

    final List<TimeOfDay> slots = [];
    int cursor = availFrom;
    for (final b in busy) {
      if (cursor + dur <= b.start) {
        slots.add(TimeOfDay(hour: cursor ~/ 60, minute: cursor % 60));
      }
      if (b.end > cursor) cursor = b.end;
    }
    if (cursor + dur <= availTo) {
      slots.add(TimeOfDay(hour: cursor ~/ 60, minute: cursor % 60));
    }
    slots.removeWhere(
      (t) =>
          t.hour == session.startTime.hour &&
          t.minute == session.startTime.minute,
    );
    return slots;
  }
}
