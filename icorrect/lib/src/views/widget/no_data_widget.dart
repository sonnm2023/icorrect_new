import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({
    super.key,
    required this.msg,
    required this.reloadCallBack,
  });

  final String msg;
  final Function() reloadCallBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.asset(
            'assets/images/ic_emotion_sad.png',
            width: 150,
            height: 150,
          ),
          Text(
            msg,
            style: CustomTextStyle.textWithCustomInfo(
              context: context,
              color: AppColor.defaultBlackColor,
              fontsSize: FontsSize.fontSize_15,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              if (kDebugMode) {
                print("DEBUG: reload button tapped!");
              }
              Utils.checkInternetConnection().then((isConnected) {
                if (isConnected) {
                  reloadCallBack();
                } else {
                  Utils.showConnectionErrorDialog(context);

                  Utils.addConnectionErrorLog(context);
                }
              });
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(AppColor.defaultPurpleColor),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            child: SizedBox(
              width: 100,
              height: 50,
              child: Center(
                child: Text(
                  Utils.multiLanguage(StringConstants.reload_button_title),
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
