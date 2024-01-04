import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/new_logic/download_info.dart';
import 'package:provider/provider.dart';

class DownloadProgressingWidget extends StatelessWidget {
  DownloadProgressingWidget(this.downloadInfo, {super.key});

  DownloadInfo downloadInfo;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width / 2;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/ic_emotion_sad.png',
          width: 100,
          height: 100,
        ),
        const SizedBox(height: 8),
        //percent

        Text("${downloadInfo.strPercent}%",
            style: const TextStyle(
                color: AppColor.defaultLightPurpleColor,
                fontSize: 17,
                fontWeight: FontWeight.bold)),

        const SizedBox(height: 8),
        //progress bar
        SizedBox(
          width: w,
          child: _buildProgressBar(),
        ),
        const SizedBox(height: 8),
        //part of total
        Text("${downloadInfo.downloadIndex}/${downloadInfo.total}",
            style: const TextStyle(
                color: AppColor.defaultLightPurpleColor,
                fontSize: 17,
                fontWeight: FontWeight.bold)),

        const SizedBox(height: 8),
        Text('${Utils.multiLanguage(StringConstants.downloading)}...',
            style: const TextStyle(
                color: AppColor.defaultLightPurpleColor,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      backgroundColor: AppColor.defaultLightGrayColor,
      minHeight: 10,
      borderRadius: BorderRadius.circular(10),
      valueColor:
          const AlwaysStoppedAnimation<Color>(AppColor.defaultPurpleColor),
      value: downloadInfo.downloadPercent,
    );
  }
}
