import 'dart:convert';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:unichat_flutter/models/online_message_format.dart';
import 'package:unichat_flutter/utils/app_env.dart';
import '../utils/api_routes.dart';

class PusherService {
  //
  String baseUrl = ApiRoutes.baseUrlFlutter;
  PusherChannelsFlutter pusher = PusherChannelsFlutter();
  final String apiKey = AppEnv.pusherKey;
  final String cluster = AppEnv.pusherCluster;

  Future<void> initPusher({
    required int userId,
    required String token,
    required Function(OnlineMessageFormat) onNewMessage,
    String base = 'flutter',
  }) async {
    baseUrl = ApiRoutes.platformUrl(base);
    final url = Uri.parse(baseUrl + ApiRoutes.pusherAuth);

    try {
      // channel name here : private-chat-{user1}-{user2}
      String channelName = 'private-chat-$userId';
      print('[+] Initializing Pusher for channel: $channelName');

      await pusher.init(
        apiKey: apiKey,
        cluster: cluster,
        onEvent: (event) async {
          print('<+> Event received: ${event.eventName}');
          //
          if (event.eventName == 'new_message') {
            print('<+> New message received');
            final OnlineMessageFormat message = OnlineMessageFormat.fromJson(jsonDecode(event.data));
            print(">>> Message: $message");
            onNewMessage(message);
          }
        },
        onAuthorizer: (
          String channelName,
          String socketId,
          dynamic options,
        ) async {
          // call to API to authenticate message
          print('[+] Authenticating Pusher...');
          print(
            '[+] Authenticating Pusher: channel=$channelName, socketId=$socketId, userId=$userId',
          );
          //
          final response = await http.post(
            url, // API Route
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'socket_id': socketId,
              'channel_name': channelName,
              'user_id': userId.toString(),
            }),
          );
          print(
            '[+] Pusher auth response: ${response.statusCode} - ${response.body}',
          );
          if (response.statusCode != 200) {
            print('[!] Authentication failed: ${response.body}');
            throw Exception('Authentication failed');
          }
          final decoded = jsonDecode(response.body);
          print('[+] Decoded auth response: $decoded');
          return decoded;
        },
      );

      await pusher.subscribe(channelName: channelName);
      print('[+] Subscribing to channel: $channelName');
      await pusher.connect();
      print('[+] Connected to Pusher');
    } catch (e, stackTrace) {
      print('[!] Pusher error: $e\nStackTrace: $stackTrace');
    }
  }

  // Deconnection
  Future<void> disconnect() async {
    await pusher.disconnect();
    print('[+] Disconnected from Pusher');
  }
}
