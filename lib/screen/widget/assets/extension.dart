import 'package:flutter/material.dart';

extension CustomDateUtils on DateUtils {
  static bool isSameWeek(DateTime? a, DateTime? b) {
    if (a == null && b == null) return true;
    a = DateUtils.dateOnly(a!);
    b = DateUtils.dateOnly(b!);
    final firstDayOfWeek = a.subtract(Duration(days: a.weekday - 1));
    final lastDayOfWeek = a.add(Duration(days: DateTime.daysPerWeek - a.weekday));
    return (firstDayOfWeek.isBefore(b) || firstDayOfWeek.isAtSameMomentAs(b)) && (lastDayOfWeek.isAfter(b) || lastDayOfWeek.isAtSameMomentAs(b));
  }
}
