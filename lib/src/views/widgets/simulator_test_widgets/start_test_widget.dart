import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_assets.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../providers/simulator_test_provider.dart';

class StartTestWidget extends StatelessWidget {
  Function onClickStartTest;
  StartTestWidget({super.key, required this.onClickStartTest});

  @override 
  Widget build(BuildContext context) {
    return Consumer<SimulatorTestProvider>(builder: (context, provider, child) {
      return (provider.doingStatus == DoingStatus.none)
          ? Visibility(
              visible: !provider.isStartTest,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppAssets.img_start,
                    width: 150,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // provider.setStartTest(true);
                      onClickStartTest();
                    },
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            AppColors.purpleBlue),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13)))),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                            Utils.instance().multiLanguage(
                                StringConstants.start_test_title),
                            style: const TextStyle(
                                fontSize: 17, color: Colors.white))),
                  )
                ],
              ))
          : const SizedBox(width: 0);
    });
  }
}
