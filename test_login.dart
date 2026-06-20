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
  print('Login status: ${loginRes.statusCode}');
  print('Login body: ${loginRes.body}');
}
