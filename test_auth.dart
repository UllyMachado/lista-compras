import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // Login
  var loginRes = await http.post(
    Uri.parse('http://localhost:8090/api/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "email": "test@test.com",
      "password": "password123"
    })
  );
  var token = jsonDecode(loginRes.body)['accessToken'];
  
  // Create list
  var listRes = await http.post(
    Uri.parse('http://localhost:8090/api/lists'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    body: jsonEncode({"name": "My List", "budget": 100.0})
  );
  print('List status: ${listRes.statusCode}');
  print('List body: ${listRes.body}');
  if (listRes.statusCode != 200 && listRes.statusCode != 201) return;
  var listId = jsonDecode(listRes.body)['id'];
  
  // Add item
  var item = {
    "description": "Banana",
    "quantity": 2.0,
    "unit": "und",
    "price": 0.0,
    "isChecked": false,
    "category": null
  };
  
  var addRes = await http.post(
    Uri.parse('http://localhost:8090/api/lists/$listId/items'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    body: jsonEncode(item)
  );
  print('Add Item Status: ${addRes.statusCode}');
  print('Add Item Response: ${addRes.body}');
}
