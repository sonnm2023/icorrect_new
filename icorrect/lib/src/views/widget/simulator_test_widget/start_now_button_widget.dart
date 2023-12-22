import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';

import '../../../data_sources/utils.dart';

class StartNowButtonWidget extends StatelessWidget {
  const StartNowButtonWidget({super.key, required this.startNowButtonTapped});

  final Function startNowButtonTapped;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Text(
            Utils.multiLanguage(
              StringConstants.start_now_description,
            ),
            style: CustomTextStyle.textWithCustomInfo(
              context: context,
              color: AppColor.defaultBlackColor,
              fontsSize: FontsSize.fontSize_15,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            startNowButtonTapped();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 300,
            height: 60,
            alignment: Alignment.center,
            child: Center(
              child: Text(
                Utils.multiLanguage(
                  StringConstants.start_now_button_title
                ),
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColor.defaultBlackColor,
                  fontsSize: FontsSize.fontSize_15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
