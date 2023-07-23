import 'package:flutter/material.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/provider/prepare_simulator_test_provider.dart';
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
          Consumer<PrepareSimulatorTestProvider>(builder: (context, provider, child) {
            double p = provider.downloadingPercent * 100;
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
          Consumer<PrepareSimulatorTestProvider>(builder: (context, provider, child) {
            return Text(
                "${provider.downloadingIndex}/${provider.total}");
          }),
          const SizedBox(height: 8),
          const Text('Downloading...', style: TextStyle(fontSize: 15)),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Consumer<PrepareSimulatorTestProvider>(builder: (context, provider, child) {
      return LinearProgressIndicator(
        backgroundColor: AppColor.defaultLightGrayColor,
        valueColor:
        const AlwaysStoppedAnimation<Color>(AppColor.defaultPurpleColor),
        value: provider.downloadingPercent,
      );
    });
  }
}
