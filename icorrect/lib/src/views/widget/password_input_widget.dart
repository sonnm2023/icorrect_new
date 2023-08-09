import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/views/widget/auth_form_field.dart';

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
        text = 'Password';
      case PasswordType.confirmPassword:
        text = 'Retype Password';
      case PasswordType.currentPassword:
        text = 'Current password';
      case PasswordType.newPassword:
        text = 'New password';
      case PasswordType.confirmNewPassword:
        text = 'Confirm new password';

    }

    return AuthFormField(
      validator: (value) {
        if (passwordController.text.isEmpty) {
          return "Password can't be empty";
        } else if (passwordController.text.length < 6) {
          return 'Your password must be longer than 6 characters';
        } else if (passwordController.text.length > 32) {
          return 'Your password must be shorter than 32 characters';
        }
        return null;
      },
      prefixIcon: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Image.asset('assets/images/ic_password.png',
            width: 1, height: 1),
      ),
      obscureText: true,
      maxLines: 1,
      controller: passwordController,
      keyboardType: TextInputType.text,
      hintText: text,
      upHintText: text,
    );
  }
}
