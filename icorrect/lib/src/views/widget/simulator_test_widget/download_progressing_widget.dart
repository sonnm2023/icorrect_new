import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/provider/prepare_test_provider.dart';
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
          Image.asset(
            'assets/images/ic_emotion_sad.png',
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 8),
          //percent
          Consumer<PrepareTestProvider>(builder: (context, prepareTestProvider, child) {
            double p = prepareTestProvider.downloadingPercent * 100;
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
          Consumer<PrepareTestProvider>(builder: (context, prepareTestProvider, child) {
            return Text(
                "${prepareTestProvider.downloadingIndex}/${prepareTestProvider.total}");
          }),
          const SizedBox(height: 8),
          const Text('Downloading...', style: TextStyle(fontSize: 15)),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Consumer<PrepareTestProvider>(builder: (context, prepareTestProvider, child) {
      return LinearProgressIndicator(
        backgroundColor: AppColor.defaultLightGrayColor,
        valueColor:
        const AlwaysStoppedAnimation<Color>(AppColor.defaultPurpleColor),
        value: prepareTestProvider.downloadingPercent,
      );
    });
  }
}
