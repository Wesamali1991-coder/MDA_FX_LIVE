import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/core.dart';

class FxLiveClient {
  WebSocketChannel? _ch;
  final List<Candle> candles=[];

  void connect(String baseUrl, String symbol, String tf){
    disconnect();
    final url = Uri.parse("$baseUrl/ws/fx?symbol=$symbol&tf=$tf");
    _ch = WebSocketChannel.connect(url);
    _ch!.stream.listen((event){
      final m=json.decode(event);
      if(m is Map && m["t"]!=null){
        final c=Candle.raw(
          DateTime.fromMillisecondsSinceEpoch(m["t"]),
          (m["o"] as num).toDouble(),
          (m["h"] as num).toDouble(),
          (m["l"] as num).toDouble(),
          (m["c"] as num).toDouble(),
        );
        candles.add(c);
        if(candles.length>800) candles.removeAt(0);
      }
    }, onError: (e){}, onDone: (){});
  }

  void disconnect(){
    try{ _ch?.sink.close(); } catch(_){}
    _ch=null;
  }
}
