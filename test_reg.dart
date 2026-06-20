import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  var uniqueEmail = 'test_${DateTime.now().millisecondsSinceEpoch}@test.com';
  
  // Register
  var regRes = await http.post(
    Uri.parse('http://localhost:8090/api/auth/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "name": "Test User",
      "email": uniqueEmail,
      "password": "password"
    })
  );
  print('Reg status: ${regRes.statusCode} ${regRes.body}');
}
