import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/views/widget/auth_form_field.dart';

import '../../data_sources/utils.dart';

class PasswordInputWidget extends StatelessWidget {
  const PasswordInputWidget(
      {super.key, required this.passwordController, required this.type});

  final TextEditingController passwordController;
  final PasswordType type;

  @override
  Widget build(BuildContext context) {
    String text = '';
    switch (type) {
      case PasswordType.password:
        text = StringConstants.password;
      case PasswordType.confirmPassword:
        text = StringConstants.retype_password;
      case PasswordType.currentPassword:
        text = StringConstants.current_password;
      case PasswordType.newPassword:
        text = StringConstants.new_password;
      case PasswordType.confirmNewPassword:
        text = StringConstants.confirm_new_password;
    }

    return AuthFormField(
      validator: (value) {
        if (passwordController.text.isEmpty) {
          return Utils.multiLanguage(
              StringConstants.empty_password_error_message);
        } else if (passwordController.text.length < 6) {
          return Utils.multiLanguage(
              StringConstants.password_min_lenght_message);
        } else if (passwordController.text.length > 32) {
          return Utils.multiLanguage(
              StringConstants.password_max_lenght_message);
        }
        return null;
      },
      prefixIcon: Padding(
        padding: const EdgeInsets.all(5.0),
        child:
            Image.asset('assets/images/ic_password.png', width: 1, height: 1),
      ),
      obscureText: true,
      maxLines: 1,
      controller: passwordController,
      keyboardType: TextInputType.text,
      hintText: Utils.multiLanguage(text),
      upHintText: Utils.multiLanguage(text),
    );
  }
}
