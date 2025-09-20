import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:unichat_flutter/controllers/auth_controller.dart';
import 'package:unichat_flutter/utils/app_textstyles.dart';
import 'package:unichat_flutter/views/widgets/text_field.dart';

class VerifyCodeScreen extends StatelessWidget {
  final int code;
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add form key

  VerifyCodeScreen({super.key, required this.code}) {
    // code sent
    _codeController.text = code.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authController = Get.find<AuthController>(); // Get AuthController

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              // Wrap the fields inside a Form widget for validation
              key: _formKey, // Key for form validation
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Icon(
                      Iconsax.verify,
                      size: 100,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      "Confirm Your Email Address",
                      style: AppTextStyles.withColor(
                        AppTextStyles.bodyLarge,
                        isDark ? Colors.grey[400]! : Colors.grey[600]!,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email or Username field
                  TextFieldWidget(
                    label: "Enter verification Code",
                    prefixIcon: Iconsax.lock,
                    keyboardType: TextInputType.number,
                    controller: _codeController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the verification Code';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Button or loading state depending on isLoading
                  Obx(() {
                    if (authController.isLoading.value) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _handleCode, // Trigger login logic when pressed
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Confirm',
                            style: AppTextStyles.withColor(
                              AppTextStyles.buttomMedium,
                              Colors.white,
                            ),
                          ),
                        ),
                      );
                    }
                  }),

                  const SizedBox(height: 24),

                  // Signup option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Get.toNamed('/'),
                        child: Text(
                          'Return to Home Page',
                          style: AppTextStyles.withColor(
                            AppTextStyles.bodyMedium,
                            isDark ? Colors.grey[400]! : Colors.grey[600]!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method to handle login process
  void _handleCode() {
    if (_formKey.currentState?.validate() ?? false) {
      final authController = Get.find<AuthController>();  // Get AuthController instance
      authController.verifyAddress(
        int.parse(_codeController.text)
      );
    }
  }
}
