import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/provider/student_test_detail_provider.dart';
import 'package:provider/provider.dart';

class DownloadProgressingWidget extends StatelessWidget {
  const DownloadProgressingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width / 2;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppAsset.empty, width: 100, height: 100),
          const SizedBox(height: 8),
          //percent
          Consumer<StudentTestProvider>(
              builder: (context, testProvider, child) {
            double p = testProvider.downloadingPercent * 100;
            return Text("${p.toStringAsFixed(0)}%");
          }),
          const SizedBox(height: 8),
          //progress bar
          SizedBox(
            width: w,
            child: _buildProgressBar(),
          ),
          const SizedBox(height: 8),
          //part of total
          Consumer<StudentTestProvider>(
              builder: (context, testProvider, child) {
            return Text(
                "${testProvider.downloadingIndex}/${testProvider.total}");
          }),
          const SizedBox(height: 8),
          Text(
            Utils.multiLanguage(StringConstants.downloading),
            style: CustomTextStyle.textWithCustomInfo(
              context: context,
              color: AppColor.defaultBlackColor,
              fontsSize: FontsSize.fontSize_15,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Consumer<StudentTestProvider>(
        builder: (context, testProvider, child) {
      return LinearProgressIndicator(
        backgroundColor: AppColor.defaultLightGrayColor,
        valueColor:
            const AlwaysStoppedAnimation<Color>(AppColor.defaultPurpleColor),
        value: testProvider.downloadingPercent,
      );
    });
  }
}
