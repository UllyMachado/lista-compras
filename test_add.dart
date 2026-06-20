import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // First, get a list id
  var resList = await http.get(Uri.parse('http://localhost:8090/api/lists'));
  if (resList.statusCode != 200) {
     print('Lists fetch failed');
     return;
  }
  var lists = jsonDecode(resList.body);
  if (lists.isEmpty) {
     print('No lists');
     return;
  }
  var listId = lists[0]['id'];

  var item = {
    "id": null,
    "description": "Banana",
    "quantity": 2.0,
    "unit": "und",
    "price": 0.0,
    "isChecked": false,
    "category": null
  };
  
  print('Sending: ${jsonEncode(item)}');
  var res = await http.post(
    Uri.parse('http://localhost:8090/api/lists/$listId/items'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(item)
  );
  print('Status: ${res.statusCode}');
  print('Response: ${res.body}');
}
