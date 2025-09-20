import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:unichat_flutter/controllers/auth_controller.dart';
import 'package:unichat_flutter/utils/app_textstyles.dart';
import 'package:unichat_flutter/views/widgets/text_field.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add form key

  //LoginScreen({super.key});
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authController = Get.find<AuthController>(); // Get AuthController

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            // Wrap the fields inside a Form widget for validation
            key: _formKey, // Key for form validation
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  "Welcome Back !",
                  style: AppTextStyles.withColor(
                    AppTextStyles.h1,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Log In to chat",
                  style: AppTextStyles.withColor(
                    AppTextStyles.bodyLarge,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
                const SizedBox(height: 40),

                // Email or Username field
                TextFieldWidget(
                  label: "Email or Username",
                  prefixIcon: Iconsax.user,
                  keyboardType: TextInputType.text,
                  controller: _identifierController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Email or Username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFieldWidget(
                  label: "Password",
                  prefixIcon: Iconsax.security,
                  isPassword: true,
                  keyboardType: TextInputType.visiblePassword,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Password';
                    }
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot Password ?',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
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
                            _handleLogin, // Trigger login logic when pressed
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Log In',
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
                    Text(
                      "Don't have an account ?",
                      style: AppTextStyles.withColor(
                        AppTextStyles.bodyMedium,
                        isDark ? Colors.grey[400]! : Colors.grey[600]!,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/register'),
                      child: Text(
                        'Register',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to handle login process
  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate the form before calling login
      final authController =
          Get.find<AuthController>(); // Get AuthController instance
      authController.login(
        _identifierController.text, // Pass the identifier (email or username)
        _passwordController.text, // Pass the password
      );
    }
  }
}
