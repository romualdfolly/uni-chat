
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:unichat_flutter/controllers/auth_controller.dart';
import 'package:unichat_flutter/controllers/chat_controller.dart';
import 'package:unichat_flutter/controllers/database_controller.dart';
import 'package:unichat_flutter/controllers/keys_controller.dart';
import 'package:unichat_flutter/controllers/secure_keys_controller.dart';
import 'package:unichat_flutter/controllers/secure_pin_controller.dart';
import 'package:unichat_flutter/controllers/theme_controller.dart';
import 'package:unichat_flutter/utils/app_themes.dart';
import 'package:unichat_flutter/views/pages/chat/chat_screen.dart';
import 'package:unichat_flutter/views/widgets/auth/login_screen.dart';
import 'package:unichat_flutter/views/widgets/auth/register_screen.dart';
import 'package:unichat_flutter/views/widgets/auth/secure_pin_code_screen.dart';
import 'package:unichat_flutter/views/widgets/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Access DatabaseController via its singleton instance
  await Get.putAsync<DatabaseController>(() async {
    final controller = DatabaseController();
    await controller.init();
    print('[+] >>> DatabaseController initialisé avec succès');
    return controller;
  });

  // Register other services
  Get.put(SecurePinController());
  Get.put(KeysController());
  Get.put(SecureKeysController());
  Get.put(ThemeController());
  Get.put(AuthController());
  Get.put(ChatController());
  //
  runApp(AppMainScreen());
}

class AppMainScreen extends StatelessWidget {
  const AppMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      title: 'Test title',
      theme: AppThemes.dark,
      darkTheme: AppThemes.dark,
      themeMode: themeController.theme,
      defaultTransition: Transition.fade,
      routes: {
        '/': (_) => SplashScreen(),
        '/login': (_) => LoginScreen(),
        '/register': (_) => RegisterScreen(),
        //'/forgot-password': (_) => ForgotPasswordScreen(),
        '/pincode': (_) => SecurityPinCodeScreen(),
        '/chats': (_) => ChatScreen(),
      },

      //initialRoute: '/secure-code-screen',
      debugShowCheckedModeBanner: false,
    );
  }
}
