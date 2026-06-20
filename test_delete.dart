import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

void main() async {
  var uniqueEmail = 'test_${DateTime.now().millisecondsSinceEpoch}@test.com';
  
  // Login
  var loginRes = await http.post(
    Uri.parse('http://localhost:8090/api/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "email": "admin@gmail.com",
      "password": "123456"
    })
  );
  if (loginRes.statusCode != 200) {
    print('Login failed: ${loginRes.statusCode} ${loginRes.body}');
    return;
  }
  var token = jsonDecode(loginRes.body)['accessToken'];
  
  // Create list
  var listRes = await http.post(
    Uri.parse('http://localhost:8090/api/lists'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    body: jsonEncode({"name": "Test Delete List", "budget": 100.0})
  );
  if (listRes.statusCode != 200 && listRes.statusCode != 201) {
    print('Create list failed: ${listRes.statusCode} ${listRes.body}');
    return;
  }
  var listId = jsonDecode(listRes.body)['id'];

  // Test Dio delete
  var dio = Dio();
  dio.options.headers['Authorization'] = 'Bearer $token';
  try {
    print('Deleting with Dio...');
    var res = await dio.delete('http://localhost:8090/api/lists/$listId');
    print('Dio Delete Status: ${res.statusCode}');
    print('Dio Delete Data: ${res.data}');
  } on DioException catch (e) {
    print('DioException: ${e.message}');
    print('Dio error: ${e.error}');
    print('Dio response data: ${e.response?.data}');
  }
}
