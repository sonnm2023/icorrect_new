import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/presenters/simulator_test_presenter.dart';

import '../../presenters/my_test_presenter_dio.dart';

class DownloadAgainWidget extends StatelessWidget {
  const DownloadAgainWidget(
      {super.key,
      required this.simulatorTestPresenter,
      required this.myTestPresenter});

  final SimulatorTestPresenter? simulatorTestPresenter;
  final MyTestPresenterDio? myTestPresenter;

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
            const Padding(
              padding:
                  EdgeInsets.only(left: 40, top: 10, right: 40, bottom: 10),
              child: Center(
                child: Text(
                  StringConstants.data_downloaded_error_message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
            //Try Again button
            InkWell(
              onTap: () {
                if (simulatorTestPresenter != null) {
                  simulatorTestPresenter!.tryAgainToDownload();
                } else if (myTestPresenter != null) {
                  myTestPresenter!.tryAgainToDownload();
                }
              },
              child: const SizedBox(
                width: 100,
                height: 60,
                child: Center(
                  child: Text(
                    StringConstants.try_again_button_title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColor.defaultPurpleColor,
                      fontSize: 15,
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
