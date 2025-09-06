import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/core.dart';
import 'strategies/ict.dart';
import 'strategies/smc.dart';
import 'strategies/breakout_trap.dart';
import 'strategies/classic.dart';
import 'live/client.dart';
import 'image/client.dart';

void main()=> runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_)=> M(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: Colors.blueGrey),
        home: const Home(),
      ),
    );
  }
}

class M extends ChangeNotifier{
  // config
  String server = "ws://10.0.2.2:8000".replaceFirst("ws://", "http://"); // display form expects http base
  String get httpBase => server;
  String get wsBase => server.replaceFirst("http://", "ws://");

  // live
  final live = FxLiveClient();
  String symbol="EURUSD";
  String tf="1m";
  String liveText="";
  void startLive(){
    live.connect(wsBase, symbol, tf);
    liveText="جاري استقبال بيانات...";
    notifyListeners();
  }
  void stopLive(){ live.disconnect(); notifyListeners(); }

  // csv
  String csvText="";
  String csvResult="";
  Future<void> runCsv(BuildContext ctx) async {
    final data = csvText.isEmpty ? await DefaultAssetBundle.of(ctx).loadString("assets/ohlc_sample.csv"): csvText;
    final candles=parseCsv(data);
    csvResult = candles.isEmpty? "CSV غير صالح" : _analyze(candles);
    notifyListeners();
  }

  String _analyze(List<Candle> c){
    final parts=[
      analyzeICT(c),
      analyzeSMC(c),
      analyzeBreakoutTrap(c),
      analyzeClassic(c),
    ];
    return parts.join("\n\n");
  }

  // image
  String imgResult="";
  Future<void> runImage(File f) async {
    imgResult = "جاري التحليل...";
    notifyListeners();
    final r = await analyzeImage(httpBase, f);
    imgResult = r;
    notifyListeners();
  }
}

class Home extends StatefulWidget{
  const Home({super.key});
  @override State<Home> createState()=> _HomeState();
}
class _HomeState extends State<Home> with SingleTickerProviderStateMixin{
  late final TabController ctl=TabController(length:3, vsync:this);
  @override void dispose(){ ctl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context){
    final m=context.watch<M>();
    return Scaffold(
      appBar: AppBar(title: const Text("MDA — Forex LIVE | CSV | Image"), bottom: const TabBar(tabs:[Tab(text:"LIVE FX"), Tab(text:"CSV"), Tab(text:"IMAGE")])),
      body: TabBarView(controller: ctl, children: const [LiveTab(), CsvTab(), ImageTab()]),
    );
  }
}

class LiveTab extends StatelessWidget{
  const LiveTab({super.key});
  @override Widget build(BuildContext context){
    final m=context.watch<M>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Row(children:[
            const Text("Server (http):"), const SizedBox(width:8),
            SizedBox(width: 240, child: TextField(
              controller: TextEditingController(text: m.httpBase),
              onSubmitted: (v){ m.server=v; m.notifyListeners(); },
            )),
          ]),
          const SizedBox(height:8),
          Row(children:[
            const Text("Symbol:"), const SizedBox(width:8),
            SizedBox(width:120, child: TextField(
              controller: TextEditingController(text: m.symbol),
              onSubmitted: (v){ m.symbol=v; m.notifyListeners(); },
            )),
            const SizedBox(width:12),
            const Text("TF:"), const SizedBox(width:8),
            DropdownButton<String>(value:m.tf, items: const [
              DropdownMenuItem(value:"1m",child:Text("1m")),
              DropdownMenuItem(value:"5m",child:Text("5m")),
              DropdownMenuItem(value:"15m",child:Text("15m")),
            ], onChanged:(v){ if(v!=null){ m.tf=v; m.notifyListeners(); } }),
            const SizedBox(width:12),
            ElevatedButton(onPressed:m.startLive, child: const Text("Start LIVE")),
            const SizedBox(width:8),
            TextButton(onPressed:m.stopLive, child: const Text("Stop")),
          ]),
          const SizedBox(height:12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
              child: SingleChildScrollView(
                child: Text(
                  m.live.candles.length<5? "انتظر وصول بيانات من الخادم..." : m._analyze(m.live.candles),
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CsvTab extends StatelessWidget{
  const CsvTab({super.key});
  @override Widget build(BuildContext context){
    final m=context.watch<M>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        const Text("ألصق CSV (timestamp,open,high,low,close) أو اتركه فارغًا لاستخدام العيّنة:"),
        const SizedBox(height:8),
        TextField(minLines:5,maxLines:8, onChanged:(v)=> m.csvText=v, decoration: const InputDecoration(border: OutlineInputBorder(), hintText:"timestamp,open,high,low,close\n2024-09-01,1.0900,1.0950,1.0880,1.0920") ),
        const SizedBox(height:8),
        ElevatedButton.icon(onPressed: ()=>m.runCsv(context), icon: const Icon(Icons.analytics), label: const Text("حلّل CSV")),
        const SizedBox(height:12),
        Expanded(child: SingleChildScrollView(child: Text(m.csvResult.isEmpty? "..." : m.csvResult))),
      ]),
    );
  }
}

class ImageTab extends StatefulWidget{ const ImageTab({super.key}); @override State<ImageTab> createState()=>_ImageTabState(); }
class _ImageTabState extends State<ImageTab>{
  File? f;
  @override Widget build(BuildContext context){
    final m=context.watch<M>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        const Text("ارفع صورة شارت (MT4/TradingView لقطة شاشة) وسيتم تحليلها عبر الخادم:"),
        const SizedBox(height:8),
        Row(children:[
          ElevatedButton(onPressed: () async {
            // keep it simple to avoid complex platform code here — instruct via server side
          }, child: const Text("اختر صورة من الهاتف (استخدم تطبيق الكاميرا/الصور ثم شاركها للتطبيق)")),
          const SizedBox(width:12),
          ElevatedButton(onPressed: f==null? null : (){ m.runImage(f!); }, child: const Text("إرسال للتحليل")),
        ]),
        const SizedBox(height:12),
        Expanded(child: SingleChildScrollView(child: Text(m.imgResult.isEmpty? "..." : m.imgResult))),
      ]),
    );
  }
}
