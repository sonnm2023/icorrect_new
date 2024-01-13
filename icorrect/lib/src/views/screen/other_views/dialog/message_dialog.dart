import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';

class MessageDialog {
  static Widget alertDialog(BuildContext context, String message) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Wrap(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  Utils.multiLanguage(StringConstants.dialog_title)!,
                  style: CustomTextStyle.textWithCustomInfo(
                    context: context,
                    color: AppColor.defaultBlackColor,
                    fontsSize: FontsSize.fontSize_17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Text(
                      textAlign: TextAlign.center,
                      message,
                      style: CustomTextStyle.textWithCustomInfo(
                        context: context,
                        color: AppColor.defaultBlackColor,
                        fontsSize: FontsSize.fontSize_15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const Divider(
                    color: AppColor.defaultLightGrayColor,
                    height: 1,
                  ),
                  SizedBox(
                    width: 150,
                    height: 44,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.center,
                      ),
                      child: Text(
                        Utils.multiLanguage(StringConstants.ok_button_title)!,
                        style: CustomTextStyle.textWithCustomInfo(
                          context: context,
                          color: AppColor.defaultPurpleColor,
                          fontsSize: FontsSize.fontSize_16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
