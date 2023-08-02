import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/presenters/simulator_test_presenter.dart';

class DownloadAgainWidget extends StatelessWidget {
  const DownloadAgainWidget({super.key, required this.simulatorTestPresenter});

  final SimulatorTestPresenter simulatorTestPresenter;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //Download icon
        Image.asset('assets/images/ic_emotion_sad.png', width: 150, height: 150),
        const SizedBox(height: 10),
        //Message
        const Text(
          "A part of data has not downloaded properly. Please check your internet connection and try again.",
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 10),
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
    ));
  }
}
