import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:unichat_flutter/models/online_message_format.dart';
import 'package:unichat_flutter/utils/api_routes.dart';

class MessageService {
  //
  String baseUrl = ApiRoutes.baseUrlFlutter;

  Future<http.Response> sendMessage({
    required OnlineMessageFormat message,
    required String token,
    String base = 'flutter',
  }) async {
    baseUrl = ApiRoutes.platformUrl(base);
    final url = Uri.parse(baseUrl + ApiRoutes.sendMessage);

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(message.toJson()),
    );

    return response;
  }

  //
  Future<http.Response> fetchMessagesFromServer({
    required String token,
    String base = 'flutter',
  }) async {
    baseUrl = ApiRoutes.platformUrl(base);
    final url = Uri.parse(baseUrl + ApiRoutes.fetchMessages);

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response;
  }

  //
  Future<http.Response> updateMessagesReadingStateOnServer({
    required List<int> messagesIdsList,
    required String token,
    String base = 'flutter',
  }) async {
    baseUrl = ApiRoutes.platformUrl(base);
    final url = Uri.parse(baseUrl + ApiRoutes.updateMessagesReadingState);

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'message_ids': messagesIdsList}),
    );

    return response;
  }

  //
  //
  Future<http.Response> sendLocalUnsentMessages({
    required List<OnlineMessageFormat> messagesList,
    required String token,
    String base = 'flutter',
  }) async {
    baseUrl = ApiRoutes.platformUrl(base);
    final url = Uri.parse(baseUrl + ApiRoutes.sendLocalUnsentMessages);

    // convert messages toJson object
    final messagesJson =
        messagesList.map((message) => message.toJson()).toList();

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'messages': messagesJson}),
    );

    return response;
  }
}
