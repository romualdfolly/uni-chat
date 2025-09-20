import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:unichat_flutter/controllers/auth_controller.dart';
import 'package:unichat_flutter/controllers/secure_pin_controller.dart';
import 'package:unichat_flutter/utils/app_textstyles.dart';
import 'package:unichat_flutter/utils/app_themes.dart';
import 'package:unichat_flutter/utils/http_response_handler.dart';

// ignore: must_be_immutable
class SecurityPinCodeScreen extends StatelessWidget {
  RxBool isPinVisible = false.obs;
  final authController = Get.find<AuthController>();
  final securePinController = Get.find<SecurePinController>();

  // will be used for buttons
  Widget numButton(int number) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextButton(
        onPressed: () {
          if (securePinController.pinCode.value.length < 6) {
            securePinController.pinCode.value += number.toString();
          }
        },
        child: Text(
          number.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  SecurityPinCodeScreen({super.key}) {
    securePinController.pinCode.value = '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        securePinController.isPinConfirmation.value
                            ? 'Confirm Your PIN'
                            : 'Enter Your PIN',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400]! : Colors.grey[600]!,
                        ),
                      ),
                    ),

                    if (securePinController.isPinConfirmation.value)
                      Column(
                        children: [
                          SizedBox(height: 10),
                          Center(
                            child: Text(
                              'Keep your PIN safe. losing it will result in the loss of all your messages',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, color: Colors.red),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 50),

                    // PIN code area
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        return Container(
                          margin: const EdgeInsets.all(6.0),
                          width: isPinVisible.value ? 40 : 16,
                          height: isPinVisible.value ? 40 : 16,

                          decoration:
                              isPinVisible.value
                                  ? BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          index <
                                                  securePinController
                                                      .pinCode
                                                      .value
                                                      .length
                                              ? AppThemes
                                                  .dark
                                                  .scaffoldBackgroundColor
                                              : Theme.of(context).primaryColor
                                                  .withValues(alpha: 0.3),
                                      width: 1, // thickness of the border
                                    ),
                                  )
                                  : BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color:
                                        index <
                                                securePinController
                                                    .pinCode
                                                    .value
                                                    .length
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).primaryColor
                                                .withValues(alpha: 0.3),
                                  ),

                          //
                          child:
                              isPinVisible.value &&
                                      index <
                                          securePinController
                                              .pinCode
                                              .value
                                              .length
                                  ? Center(
                                    child: Text(
                                      securePinController.pinCode.value[index],
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )
                                  : null,
                        );
                      }),
                    ),

                    SizedBox(height: isPinVisible.value ? 16.0 : 40.0),

                    // key board
                    for (var i = 0; i < 3; i++)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            3,
                            (index) => numButton(1 + 3 * i + index),
                          ),
                        ),
                      ),

                    // last row of keybord
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // visble toggle button
                          TextButton(
                            onPressed: () {
                              isPinVisible.value = !isPinVisible.value;
                            },
                            child: Icon(
                              isPinVisible.value
                                  ? Iconsax.eye_slash
                                  : Iconsax.eye,
                              color: Colors.white,
                            ),
                          ),

                          numButton(0),

                          // Deletion Button
                          TextButton(
                            onPressed: () {
                              securePinController.pinCode.value =
                                  securePinController.pinCode.value.isNotEmpty
                                      ? securePinController.pinCode.value
                                          .substring(
                                            0,
                                            securePinController
                                                    .pinCode
                                                    .value
                                                    .length -
                                                1,
                                          )
                                      : '';
                            },
                            child: Icon(Icons.backspace, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30.0),

                    // reset & validat/confirm buttons
                    Obx(() {
                      return securePinController.isLoading.value
                        ? Center(child: CircularProgressIndicator())
                        : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // reset button
                          TextButton(
                            onPressed: () {
                              securePinController.pinCode.value = '';
                            },
                            style: TextButton.styleFrom(
                              side: BorderSide(
                                color:
                                    isDark
                                        ? Colors.grey[400]!
                                        : Colors.grey[600]!,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  50,
                                ), // optional for rounded corners
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ), // optional for spacing
                            ),
                            child: Text(
                              "Reset",
                              style: AppTextStyles.withColor(
                                AppTextStyles.bodyLarge,
                                isDark ? Colors.grey[400]! : Colors.grey[600]!,
                              ),
                            ),
                          ),

                          // validate/confirm button
                          TextButton(
                            onPressed: () {
                              if (securePinController.pinCode.value.length <
                                  6) {
                                showCustomSnackbar(
                                  'PIN Length Error',
                                  'The PIN must be 6 digits long.',
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  duration: 3,
                                );
                              } else {
                                _handlePIN();
                              }
                            },

                            style: TextButton.styleFrom(
                              backgroundColor:
                                  securePinController.isPinConfirmation.value
                                      ? Colors.red
                                      : Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text(
                              "${securePinController.isPinConfirmation.value ? "Confirm" : "Set"} PIN",
                              style: AppTextStyles.withColor(
                                AppTextStyles.bodyLarge,
                                Colors.white,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    //
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _handlePIN() {
    securePinController.pinCodeManager();
  }
}
