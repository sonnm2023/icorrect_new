import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/views/widget/auth_form_field.dart';

class EmailInputWidget extends StatelessWidget {
  const EmailInputWidget({super.key, required this.emailController});

  final TextEditingController emailController;

  final String regexEmail =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#\$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

  @override
  Widget build(BuildContext context) {
    return AuthFormField(
      prefixIcon: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Image.asset('assets/images/ic_email.png', width: 1, height: 1),
      ),
      autofocus: false,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (emailController.text.isEmpty) {
          return StringConstants.empty_email_error_message;
        }

        if (!RegExp(regexEmail).hasMatch(emailController.text)) {
          return StringConstants.invalid_email_error_message;
        }

        return null;
      },
      controller: emailController,
      keyboardType: TextInputType.text,
      hintText: StringConstants.email,
      upHintText: StringConstants.email,
      maxLines: 1,
    );
  }
}
