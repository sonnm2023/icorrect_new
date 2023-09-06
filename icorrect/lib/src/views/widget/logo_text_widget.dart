import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';

class LogoTextWidget extends StatelessWidget {
  const LogoTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'REACH YOUR DREAM TARGET',
        style: TextStyle(
          color: AppColor.defaultPurpleColor,
          fontSize: 13,
        ),
      ),
    );
  }
}
