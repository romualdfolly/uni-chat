// utils/http_response_handler.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:unichat_flutter/utils/app_textstyles.dart';

void showCustomSnackbar(
  String title,
  String message, {
  Color? backgroundColor,
  Color? textColor,
  int duration = 5
}) {
  Get.snackbar(
    title,
    message,
    backgroundColor: backgroundColor ?? Colors.white,
    colorText: textColor ?? Colors.black,
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.all(16),
    borderRadius: 0,
    duration: Duration(seconds: duration),
    messageText: Text(
      message,
      style: AppTextStyles.withColor(AppTextStyles.bodyMedium, textColor ?? Colors.black),
    ),
  );
}

void handleResponse(http.Response response, {int duration = 5}) {
  final responseBody = jsonDecode(response.body);

  String message = 'An unknown error occurred+.';

  if (responseBody['message'] != null) {
    message = responseBody['message'];
  } else if (responseBody['errors'] != null &&
      responseBody['errors'] is Map<String, dynamic>) {
    final errors = responseBody['errors'] as Map<String, dynamic>;
    message = errors.values.expand((e) => e as List).join('\n');
  }

  String title = "Error";
  Color backgroundColor = Colors.red;
  Color textColor = Colors.white;

  switch (response.statusCode) {
    case 200:
      // Succès
      title = "Success";
      backgroundColor = Colors.green;
      message = message.isEmpty ? 'Login successful' : message;
      break;

    case 401:
      // Identifiant ou mot de passe invalide
      title = "Error";
      backgroundColor = Colors.red;
      message = message.isEmpty ? 'Invalid username or password' : message;
      break;

    case 409:
      // Conflit (email ou nom d'utilisateur déjà pris)
      title = "Error";
      backgroundColor = Colors.orange;
      message = message.isEmpty ? 'Email or username already exists' : message;
      break;

    case 422:
      // Validation échouée
      title = "Validation Error";
      backgroundColor = Colors.orange;
      message =
          message.isEmpty
              ? 'Validation failed: ${responseBody['errors']}'
              : message;
      break;

    case 500:
      // Erreur serveur
      title = "Error";
      backgroundColor = Colors.red;
      message =
          message.isEmpty
              ? 'Internal server error. Please try again later.'
              : message;
      break;

    default:
      // Autres erreurs
      title = "Error";
      backgroundColor = Colors.red;
      message = message.isEmpty ? 'Something went wrong' : message;
      break;
  }

  // Affichage du snackbar après toute la logique
  showCustomSnackbar(
    title,
    message,
    backgroundColor: backgroundColor,
    textColor: textColor,
    duration: duration
  );
}
