import 'package:flutter/material.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:provider/provider.dart';

class DownloadProgressingWidget extends StatefulWidget {
  const DownloadProgressingWidget({super.key});

  @override
  State<DownloadProgressingWidget> createState() => _DownloadProgressingWidgetState();
}

class _DownloadProgressingWidgetState extends State<DownloadProgressingWidget> with TickerProviderStateMixin{

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2), vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width / 2;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(animation: _animation, builder:  (context, child) {
            return Transform.rotate(
                    angle: _animation.value,
                    child: Image.asset('assets/images/hourglass.png',
                        width: 50, height: 50));
              }),
          const SizedBox(height: 8),
          //percent
          Consumer<SimulatorTestProvider>(
            builder: (context, provider, child) {
              double p = provider.downloadingPercent * 100;
              return Text("${p.toStringAsFixed(0)}%");
            },
          ),
          const SizedBox(height: 8),
          //progress bar
          SizedBox(
            width: w,
            child: _buildProgressBar(),
          ),
          const SizedBox(height: 8),
          //part of total
          Consumer<SimulatorTestProvider>(builder: (context, provider, child) {
            return Text("${provider.downloadingIndex}/${provider.total}");
          }),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              // Utils.multiLanguage(StringConstants.downloading)!,
              'Đang tải dữ liệu nhiệm vụ vui lòng chờ trong giây lát',
              textAlign: TextAlign.center,
              style: CustomTextStyle.textWithCustomInfo(
                context: context,
                color: AppColor.defaultAppColor,
                fontsSize: FontsSize.fontSize_16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Consumer<SimulatorTestProvider>(
      builder: (context, provider, child) {
        return LinearProgressIndicator(
          backgroundColor: AppColor.defaultLightGrayColor,
          valueColor:
          const AlwaysStoppedAnimation<Color>(AppColor.defaultPurpleColor),
          value: provider.downloadingPercent,
        );
      },
    );
  }
}
