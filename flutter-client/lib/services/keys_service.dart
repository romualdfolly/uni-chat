import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:unichat_flutter/models/key_pair.dart';
import '../utils/api_routes.dart';

class KeysService {

  String baseUrl = ApiRoutes.baseUrlFlutter;

  Future<http.Response> storeKeys({
    required int userId,
    required KeyPairEntity keyPairEntity,
    required String token,
    String base = 'flutter',
  }) async {
    baseUrl = ApiRoutes.platformUrl(base);
    final url = Uri.parse(baseUrl + ApiRoutes.storeKeys);

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'key_id': keyPairEntity.id,
        'e_key': keyPairEntity.edPubKey,
        'x_key': keyPairEntity.xPubKey,
        'is_active': keyPairEntity.isActive,
        'created_at': keyPairEntity.createdAt.toIso8601String(),
        'valid_until': keyPairEntity.validUntil.toIso8601String(),
      }),
    );

    return response;
  }

  Future<http.Response> deactivateKey({
    required int userId,
    required KeyPairEntity keyPairEntity,
    required String token,
    String base = 'flutter',
  }) async {
    baseUrl = ApiRoutes.platformUrl(base);
    final url = Uri.parse(baseUrl + ApiRoutes.storeKeys);

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: {
        'user_id': userId,
        'key_id': keyPairEntity.id,
        'created_at': keyPairEntity.createdAt
      },
    );

    return response;
  }
}
