import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List?> loadJsonFromUrl(String url) async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return json.decode(response.body) as List;
  } else {
    throw Exception('Failed to load JSON data from $url');
  }
}
