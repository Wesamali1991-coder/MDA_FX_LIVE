import '../core/core.dart';
String analyzeClassic(List<Candle> c){
  if(c.isEmpty) return "Indicators: لا توجد بيانات.";
  final cl=[for(final k in c) k.c];
  final e9=ema(cl,9).last;
  final e21=ema(cl,21).last;
  final e50=ema(cl,50).last;
  final r=rsi(cl,14).last;
  final a=atr(c,14).last;
  final bias = e9>e21 && e21>e50? "صاعد" : (e9<e21 && e21<e50? "هابط":"متذبذب");
  return "Indicators: EMA9/21/50=%.5f/%.5f/%.5f · RSI=%.1f · ATR≈%.5f · ميل=%s"
    .replaceFirst("%.5f", e9.toStringAsFixed(5))
    .replaceFirst("%.5f", e21.toStringAsFixed(5))
    .replaceFirst("%.5f", e50.toStringAsFixed(5))
    .replaceFirst("%.1f", r.isNaN?0:r)
    .replaceFirst("%.5f", a.isNaN?0:a)
    .replaceFirst("%s", bias);
}
