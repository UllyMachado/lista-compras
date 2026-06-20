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
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer \$token'},
    body: jsonEncode({"name": "My List", "budget": 100.0, "items": []})
  );
  print('List status: \${listRes.statusCode}');
  print('List body: \${listRes.body}');
}
