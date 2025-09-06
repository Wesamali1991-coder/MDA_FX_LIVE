import '../core/core.dart';

String analyzeBreakoutTrap(List<Candle> c) {
  if (c.length < 25) return "Breakout Trap: بيانات قليلة.";
  final w = c.takeLast(20).toList();

  double hi = -1e9, lo = 1e9;
  for (final k in w) {
    if (k.h > hi) hi = k.h;
    if (k.l < lo) lo = k.l;
  }

  final r = w.last;
  final upTrap = r.h >= hi && r.c < hi;   // كسر فوق ثم إغلاق تحت
  final dnTrap = r.l <= lo && r.c > lo;   // كسر تحت ثم إغلاق فوق

  if (upTrap) {
    return "Breakout Trap علوي: كسر كاذب فوق المقاومة ثم إغلاق دونها — بيع بعد إعادة اختبار.";
  }
  if (dnTrap) {
    return "Breakout Trap سفلي: كسر كاذب تحت الدعم ثم إغلاق فوقه — شراء بعد إعادة اختبار.";
  }
  return "Breakout Trap: لا توجد مصيدة واضحة.";
}
