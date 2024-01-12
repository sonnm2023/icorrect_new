import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';

import '../../data_sources/utils.dart';

class LogoTextWidget extends StatelessWidget {
  const LogoTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        Utils.multiLanguage(StringConstants.logo_text)!,
        style: CustomTextStyle.textWithCustomInfo(
          context: context,
          color: AppColor.defaultPurpleColor,
          fontsSize: FontsSize.fontSize_13,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
