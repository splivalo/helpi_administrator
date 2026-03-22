/// Croatian public holidays — 13 fixed + 2 Easter-based.
class CroatianHolidays {
  CroatianHolidays._();

  /// Returns true if [date] is a Croatian public holiday.
  static bool isPublicHoliday(DateTime date) {
    final m = date.month;
    final d = date.day;

    // 13 fixed holidays
    if ((m == 1 && d == 1) || // Nova godina
        (m == 1 && d == 6) || // Sveta tri kralja
        (m == 5 && d == 1) || // Praznik rada
        (m == 5 && d == 30) || // Dan državnosti
        (m == 6 && d == 22) || // Dan antifašističke borbe
        (m == 8 && d == 5) || // Dan pobjede
        (m == 8 && d == 15) || // Velika Gospa
        (m == 10 && d == 8) || // Dan neovisnosti
        (m == 11 && d == 1) || // Svi sveti
        (m == 11 && d == 18) || // Dan sjećanja na Vukovar
        (m == 12 && d == 25) || // Božić
        (m == 12 && d == 26)) // Sveti Stjepan
    {
      return true;
    }

    // Easter-based holidays
    final easter = _computeEasterSunday(date.year);
    final easterMonday = easter.add(const Duration(days: 1));
    final corpusChristi = easter.add(const Duration(days: 60));

    return _sameDay(date, easterMonday) || _sameDay(date, corpusChristi);
  }

  /// Returns true if [date] is Sunday or a Croatian public holiday.
  static bool isOvertimeDay(DateTime date) =>
      date.weekday == DateTime.sunday || isPublicHoliday(date);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Computus — Anonymous Gregorian algorithm for Easter Sunday.
  static DateTime _computeEasterSunday(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = ((h + l - 7 * m + 114) % 31) + 1;

    return DateTime(year, month, day);
  }
}
