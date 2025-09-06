import '../core/core.dart';
String analyzeBreakoutTrap(List<Candle> c){
  if(c.length<25) return "Breakout Trap: بيانات قليلة.";
  final w=c.takeLast(20).toList();
  double hi=-1e9, lo=1e9;
  for(final k in w){ if(k.h>hi) hi=k.h; if(k.l<ll) ll=k.l; }
  final r=w.last;
  final up = r.h>=hi && r.c<hi;
  final dn = r.l<=lo && r.c>lo;
  if(up) return "Breakout Trap علوي: كسْر كاذب فوق المقاومة ثم إغلاق تحتها — بيع بعد إعادة اختبار.";
  if(dn) return "Breakout Trap سفلي: كسْر كاذب تحت الدعم ثم إغلاق فوقه — شراء بعد إعادة اختبار.";
  return "Breakout Trap: لا توجد مصيدة واضحة.";
}
