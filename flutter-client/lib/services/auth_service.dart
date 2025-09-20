import 'dart:convert';

import 'package:http/http.dart' as http;
import '../utils/api_routes.dart';

class AuthService {
  String baseUrl = ApiRoutes.baseUrlFlutter;

  Future<http.Response> login(
    String email,
    String password, {
    String base = 'flutter',
  }) async {
    baseUrl = ApiRoutes.platformUrl(base);
    final url = Uri.parse(baseUrl + ApiRoutes.login);

    final response = await http.post(
      url,
      body: {'identifier': email, 'password': password},
      headers: {'Accept': 'application/json'},
    );

    return response;
  }

  // "token": "1|EkV9z480KTvjC6jVRwldguDngu1PQa6og7I4Zdbfd2269d8a"

  Future<http.Response> register(
    String name,
    String userName,
    String email,
    String password,
    String passwordConfirmation,
    {String base = 'flutter',}
  ) async {
    baseUrl = ApiRoutes.platformUrl(base);
    final url = Uri.parse(baseUrl + ApiRoutes.register);

    final response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {
        'username': userName,
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    return response;
  }



  Future<http.Response> verifyAddress(
    int userId,
    int code,
    String token,
    {String base = 'flutter',}
  ) async {
    baseUrl = ApiRoutes.platformUrl(base);
    final url = Uri.parse(baseUrl + ApiRoutes.verifyCode);

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'code': code
      }),
    );

    return response;
  }
}
