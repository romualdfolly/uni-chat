import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:unichat_flutter/controllers/auth_controller.dart';
import 'package:unichat_flutter/utils/app_textstyles.dart';
import 'package:unichat_flutter/views/widgets/text_field.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();  // Form key for validation

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authController = Get.find<AuthController>(); // Access AuthController instance

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(  // Wrap the fields inside a Form widget for validation
            key: _formKey,  // Key for form validation
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  "Create Account",
                  style: AppTextStyles.withColor(
                    AppTextStyles.h1,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign Up and start chatting safely",
                  style: AppTextStyles.withColor(
                    AppTextStyles.bodyLarge,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
                const SizedBox(height: 40),

                // Full Name field
                TextFieldWidget(
                  label: "Full Name",
                  prefixIcon: Iconsax.user,
                  keyboardType: TextInputType.text,
                  controller: _nameController,
                  validator: (value) => _handleError(value, 'Full name'),
                ),
                const SizedBox(height: 16),

                // Username field
                TextFieldWidget(
                  label: "Username",
                  prefixIcon: Iconsax.user,
                  keyboardType: TextInputType.text,
                  controller: _userNameController,
                  validator: (value) => _handleError(value, 'Username'),
                ),
                const SizedBox(height: 16),

                // Email field
                TextFieldWidget(
                  label: "Email",
                  prefixIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (value) => _handleError(value, 'Email'),
                ),
                const SizedBox(height: 16),

                // Password field
                TextFieldWidget(
                  label: "Password",
                  prefixIcon: Iconsax.security,
                  isPassword: true,
                  keyboardType: TextInputType.visiblePassword,
                  controller: _passwordController,
                  validator: (value) => _handleError(value, 'Password'),
                ),
                const SizedBox(height: 16),

                // Password Confirmation field
                TextFieldWidget(
                  label: "Confirm your password",
                  prefixIcon: Iconsax.security,
                  isPassword: true,
                  keyboardType: TextInputType.visiblePassword,
                  controller: _passwordConfirmationController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Button or loading spinner based on isLoading state
                Obx(() {
                  if (authController.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleRegister,  // Trigger registration when pressed
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Register',
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

                // Login link for users who already have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account ?",
                      style: AppTextStyles.withColor(
                        AppTextStyles.bodyMedium,
                        isDark ? Colors.grey[400]! : Colors.grey[600]!,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/login'),
                      child: Text(
                        'Login',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to handle registration
  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {  // Validate the form before calling register
      final AuthController authController = Get.find<AuthController>();  // Access AuthController instance
      authController.register(
        _nameController.text,
        _userNameController.text,
        _emailController.text,
        _passwordController.text,
        _passwordConfirmationController.text
      );
    }
  }

  // Method to handle errors for form fields
  String? _handleError(String? value, String field) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $field';
    }
    return null;
  }
}
