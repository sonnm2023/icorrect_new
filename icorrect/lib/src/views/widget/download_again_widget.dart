import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/presenters/simulator_test_presenter.dart';

class DownloadAgainWidget extends StatelessWidget {
  const DownloadAgainWidget({super.key, required this.simulatorTestPresenter});

  final SimulatorTestPresenter simulatorTestPresenter;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: AppColor.defaultLightGrayColor,
          child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
          //Download icon
          Image.asset('assets/images/ic_emotion_sad.png', width: 100, height: 100),
          //Message
          const Padding(
            padding: EdgeInsets.only(left: 40, top: 10, right: 40, bottom: 10),
            child: Center(
              child: Text(
                "A part of data has not downloaded properly. Please check your internet connection and try again.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
          //Try Again button
          InkWell(
            onTap: () {
              simulatorTestPresenter.tryAgainToDownload();
            },
            child: const SizedBox(
              width: 100,
              height: 60,
              child: Center(
                child: Text(
                  'Try Again',
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
        ));
  }
}
