import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';

class LogoTextWidget extends StatelessWidget {
  const LogoTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        StringConstants.logo_text,
        style: TextStyle(
          color: AppColor.defaultPurpleColor,
          fontSize: 13,
        ),
      ),
    );
  }
}
