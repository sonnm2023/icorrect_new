import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/presenters/other_student_test_presenter.dart';
import 'package:icorrect/src/presenters/simulator_test_presenter.dart';

class DownloadAgainWidget extends StatelessWidget {
  const DownloadAgainWidget(
      {super.key,
      required this.simulatorTestPresenter,
      required this.otherStudentTestPresenter});

  final SimulatorTestPresenter? simulatorTestPresenter;
  final OtherStudentTestPresenter? otherStudentTestPresenter;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: AppColor.defaultWhiteColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Download icon
            Image.asset(
              'assets/images/ic_emotion_sad.png',
              width: 100,
              height: 100,
            ),
            //Message
            Padding(
              padding: const EdgeInsets.only(
                  left: 40, top: 10, right: 40, bottom: 10),
              child: Center(
                child: Text(
                  Utils.multiLanguage(
                      StringConstants.data_downloaded_error_message),
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.textWithCustomInfo(
                    context: context,
                    color: AppColor.defaultBlackColor,
                    fontsSize: FontsSize.fontSize_15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            //Try Again button
            InkWell(
              onTap: () {
                if (simulatorTestPresenter != null) {
                  simulatorTestPresenter!.tryAgainToDownload();
                } else if (otherStudentTestPresenter != null) {
                  otherStudentTestPresenter!.tryAgainToDownload();
                }
              },
              child: SizedBox(
                width: 100,
                height: 60,
                child: Center(
                  child: Text(
                    Utils.multiLanguage(StringConstants.try_again_button_title),
                    style: CustomTextStyle.textWithCustomInfo(
                      context: context,
                      color: AppColor.defaultPurpleColor,
                      fontsSize: FontsSize.fontSize_15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
