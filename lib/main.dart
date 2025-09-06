// lib/main.dart
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MDAApp());
}

class MDAApp extends StatelessWidget {
  const MDAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MDA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E1116),
        cardColor: const Color(0xFF161B22),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF161B22),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF30363D)),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF30363D)),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF58A6FF)),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// هذا الإصدار لا يحتوي على أي قفل/Overlay.
/// لا AbsorbPointer ولا IgnorePointer ولا ModalBarrier.
/// مجرد واجهة نظيفة مع تبويبات تعمل دومًا.
class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final TextEditingController serverCtl =
      TextEditingController(text: 'http://192.168.68.104:8000'); // عدّل IP حسب جهازك
  final TextEditingController symbolCtl = TextEditingController(text: 'EURUSD');
  String tf = '1m';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    serverCtl.dispose();
    symbolCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MDA'),
        centerTitle: true,
        backgroundColor: const Color(0xFF161B22),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'LIVE FX'),
            Tab(text: 'CSV'),
            Tab(text: 'IMAGE'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        // ملاحظة: لا يوجد Stack هنا وبالتالي لا طبقة رمادية
        children: [
          _LiveFxTab(
            serverCtl: serverCtl,
            symbolCtl: symbolCtl,
            tf: tf,
            onTfChanged: (v) => setState(() => tf = v),
          ),
          const _CsvTab(),
          const _ImageTab(),
        ],
      ),
    );
  }
}

class _LiveFxTab extends StatelessWidget {
  const _LiveFxTab({
    required this.serverCtl,
    required this.symbolCtl,
    required this.tf,
    required this.onTfChanged,
  });

  final TextEditingController serverCtl;
  final TextEditingController symbolCtl;
  final String tf;
  final ValueChanged<String> onTfChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: serverCtl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Server (http)',
                    hintText: 'http://192.168.x.x:8000',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: symbolCtl,
                  decoration: const InputDecoration(labelText: 'Symbol'),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: tf,
                  items: const [
                    DropdownMenuItem(value: '1m', child: Text('1m')),
                    DropdownMenuItem(value: '5m', child: Text('5m')),
                    DropdownMenuItem(value: '15m', child: Text('15m')),
                    DropdownMenuItem(value: '1h', child: Text('1h')),
                  ],
                  onChanged: (v) {
                    if (v != null) onTfChanged(v);
                  },
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () {
                  // هنا استدعِ عميل الـLIVE الحقيقي لديك (بدون أي قفل)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Starting LIVE → ${symbolCtl.text} @ $tf via ${serverCtl.text}'),
                    ),
                  );
                },
                child: const Text('Start LIVE'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // مساحات العرض – ضع Widgets التحليل الحقيقية عندك هنا
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _CardBox(
                  title: 'الحالة',
                  child: Text(
                    'ينبغي أن تظهر بيانات البث الحي هنا بعد الربط بالخادم.\n'
                    'لا توجد أي طبقة قفل – الشاشة تظل تفاعلية.',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CardBox(
                  title: 'التحليل',
                  child: Text(
                    'اعرض إشاراتك (ICT / Breakout Trap / Classic…)\n'
                    'أو أي رسومات/نتائج مباشرة.',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CsvTab extends StatelessWidget {
  const _CsvTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _CardBox(
        title: 'CSV',
        child: Text(
          'الصق CSV بالتنسيق: timestamp,open,high,low,close\n'
          'ألغينا أي قفل—المجال مفتوح للتفاعل فورًا.',
        ),
      ),
    );
  }
}

class _ImageTab extends StatelessWidget {
  const _ImageTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _CardBox(
        title: 'تحليل صورة الشارت',
        child: Text(
          'ارفع صورة (TradingView/MT4) وسيجري التحليل.\n'
          'لا توجد طبقة رمادية أو امتصاص نقرات.',
        ),
      ),
    );
  }
}

class _CardBox extends StatelessWidget {
  const _CardBox({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
