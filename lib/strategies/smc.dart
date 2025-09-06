import '../core/core.dart';
String analyzeSMC(List<Candle> c){
  if(c.length<15) return "SMC: بيانات قليلة.";
  final seg=c.takeLast(20).toList();
  int ups=0, downs=0;
  for(int i=1;i<seg.length;i++){ if(seg[i].c>seg[i-1].c) ups++; else downs++; }
  final bias= ups>downs? "صاعد":"هابط";
  return "SMC: ميل $bias (↑$ups/↓$downs خلال 20 شموع)";
}
