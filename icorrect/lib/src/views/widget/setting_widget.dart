import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:provider/provider.dart';

class SettingWidget extends StatefulWidget {
  const SettingWidget({super.key});

  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {
  bool isOpitimize = false;
  late SimulatorTestProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<SimulatorTestProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Utils.multiLanguage(StringConstants.setting_screen_title),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultPurpleColor,
            fontsSize: FontsSize.fontSize_18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(color: AppColor.defaultPurpleColor),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Divider(
            color: AppColor.defaultPurpleColor,
            thickness: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      Utils.multiLanguage(StringConstants.optimize_video_play)),
                  Switch(
                    value: isOpitimize,
                    onChanged: (value) {
                      setState(() {
                        isOpitimize = value;
                        _provider.setOptimizeVideoPlayer(value);
                      });
                    },
                    activeColor: AppColor.defaultPurpleColor,
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
