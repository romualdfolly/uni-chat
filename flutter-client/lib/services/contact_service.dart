import 'dart:convert';

import 'package:http/http.dart' as http;
import '../utils/api_routes.dart';

class ContactService {
  String baseUrl = ApiRoutes.baseUrlFlutter;

  Future<http.Response> checkContact(
    String identifier,
    String token, {
    String base = 'flutter',
  }) async {
    baseUrl = ApiRoutes.platformUrl(base);
    final url = Uri.parse(baseUrl + ApiRoutes.checkContact);

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'identifier': identifier,
      }),
    );

    return response;
  }


  Future<http.Response> getCOntactInfosById(
    int contactId,
    String token, {
    String base = 'flutter',
  }) async {
    baseUrl = ApiRoutes.platformUrl(base);
    final url = Uri.parse("${baseUrl + ApiRoutes.getContactInfosById}/$contactId");

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }
}
