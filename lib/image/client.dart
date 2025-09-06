import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> analyzeImage(String baseUrl, File file) async {
  final uri = Uri.parse("$baseUrl/analyze-image");
  final req = http.MultipartRequest("POST", uri);
  req.files.add(await http.MultipartFile.fromPath('file', file.path));
  final res = await req.send();
  final body = await res.stream.bytesToString();
  if(res.statusCode>=200 && res.statusCode<300){
    return body;
  }
  return "خطأ ${res.statusCode}: $body";
}
