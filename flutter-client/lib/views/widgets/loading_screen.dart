import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:unichat_flutter/controllers/secure_pin_controller.dart';
import 'package:unichat_flutter/utils/app_textstyles.dart';
import 'package:get/get.dart';

class LoadingScreen extends StatefulWidget {
  final Future<void> Function(String pin, String salt)
  checkKeysTask; // function to launch when loading screen is displayed

  const LoadingScreen({super.key, required this.checkKeysTask});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  //
  Future<void> _runTask() async {
    try {
      // PIN & Salt Getting
      final String pin = Get.find<SecurePinController>().pinCode.value;
      final String? salt = await const FlutterSecureStorage().read(
        key: 'pinSalt',
      );

      // Task launch
      await widget.checkKeysTask(pin, salt!);
      //
      if (mounted) {
        Get.offAllNamed('/chats');
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar("Error", "Failure : $e");
        //print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _runTask();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingAnimationWidget.threeRotatingDots(
                color: Theme.of(context).primaryColor,
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                "Generating and securing keys...",
                textAlign: TextAlign.center,
                style: AppTextStyles.withColor(
                  AppTextStyles.bodyLarge,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
