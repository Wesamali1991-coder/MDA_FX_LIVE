import 'dart:math';

class Candle {
  final DateTime t;
  final double o,h,l,c;
  Candle(this.t,this.o,this.h,this.c): l=min(h,c); // incorrect intentionally? fix
  // Let's correct:
  Candle.raw(DateTime t,double o,double h,double l,double c): t=t,o=o,h=h,l=l,c=c;
}

List<Candle> parseCsv(String csv){
  final lines = csv.trim().split(RegExp(r'\r?\n'));
  final out=<Candle>[];
  for(int i=1;i<lines.length;i++){
    final p = lines[i].split(',');
    if(p.length<5) continue;
    final t = DateTime.tryParse(p[0].trim()) ?? DateTime.fromMillisecondsSinceEpoch(0);
    double toD(String s)=> double.tryParse(s.trim())??0;
    out.add(Candle.raw(t,toD(p[1]),toD(p[2]),toD(p[3]),toD(p[4])));
  }
  return out;
}

List<double> ema(List<double> x,int n){
  if(x.isEmpty) return [];
  final k = 2/(n+1);
  final out=<double>[];
  double prev=x.first;
  for(int i=0;i<x.length;i++){
    final v = i==0? x[i] : (x[i]-prev)*k + prev;
    out.add(v);
    prev=v;
  }
  return out;
}

List<double> rsi(List<double> close,int n){
  if(close.length<2) return List.filled(close.length,0);
  final gains=<double>[]; final losses=<double>[];
  for(int i=1;i<close.length;i++){
    final ch = close[i]-close[i-1];
    gains.add(ch>0?ch:0); losses.add(ch<0?-ch:0);
  }
  double avgGain = gains.take(n-1).fold(0.0,(a,b)=>a+b)/(n-1);
  double avgLoss = losses.take(n-1).fold(0.0,(a,b)=>a+b)/(n-1);
  final out=List<double>.filled(close.length,0);
  for(int i=n;i<close.length;i++){
    final g=gains[i-1], l=losses[i-1];
    avgGain=(avgGain*(n-1)+g)/n;
    avgLoss=(avgLoss*(n-1)+l)/n;
    final rs = avgLoss==0? 100.0 : (avgGain/avgLoss);
    out[i]= 100- (100/(1+rs));
  }
  return out;
}

List<double> atr(List<Candle> c,int n){
  if(c.isEmpty) return [];
  double tr(int i){
    if(i==0) return c[i].h - c[i].l;
    final pc=c[i-1].c;
    final a=(c[i].h-c[i].l).abs();
    final b=(c[i].h-pc).abs();
    final d=(c[i].l-pc).abs();
    return max(a,max(b,d));
  }
  final trs=[for(int i=0;i<c.length;i++) tr(i)];
  return ema(trs,n);
}

extension TakeTail<T> on List<T>{
  Iterable<T> takeLast(int n)=> skip(length>n? length-n : 0);
}
