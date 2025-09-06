import '../core/core.dart';

String analyzeICT(List<Candle> c) {
  if (c.length < 20) return "ICT: بيانات قليلة.";

  // اكتشاف FVG بسيط
  final fvg = <int>[];
  for (int i = 2; i < c.length - 2; i++) {
    final bull = c[i - 1].h < c[i + 1].l && c[i].c > c[i].o;
    final bear = c[i - 1].l > c[i + 1].h && c[i].c < c[i].o;
    if (bull || bear) fvg.add(i);
  }

  final last = c.takeLast(30).toList();
  double hi = -1e9, lo = 1e9;
  for (final k in last) {
    if (k.h > hi) hi = k.h;
    if (k.l < lo) lo = k.l;
  }
  final bias = last.last.c > last.first.c ? "صاعد" : "هابط";

  return "ICT: ميل $bias · نطاق ${lo.toStringAsFixed(5)}–${hi.toStringAsFixed(5)} · "
      "${fvg.isEmpty ? "لا FVG حديث" : "آخر FVG #${fvg.last}"}";
}
