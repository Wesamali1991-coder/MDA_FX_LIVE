import '../core/core.dart';

String analyzeClassic(List<Candle> c) {
  if (c.length < 20) return "Classic: بيانات قليلة.";

  final closes = [for (final k in c) k.c];
  // SMA20 بسيط
  final last20 = closes.takeLast(20).toList();
  final sma20 = last20.reduce((a, b) => a + b) / last20.length;

  final last = c.last.c;
  final pos = last > sma20 ? "فوق" : "تحت";

  // RSI14
  final r = rsi(closes, 14);
  final rsiVal = r.isEmpty ? 0.0 : r.last;

  return "Classic: السعر $pos SMA20 (${sma20.toStringAsFixed(5)}), RSI14=${rsiVal.toStringAsFixed(1)}";
}
