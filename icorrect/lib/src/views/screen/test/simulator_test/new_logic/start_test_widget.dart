import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/new_logic/simulator_test_provider_new.dart';
import 'package:provider/provider.dart';

class StartTestWidget extends StatelessWidget {
  Function onClickStartTest;
  StartTestWidget({super.key, required this.onClickStartTest});

  @override
  Widget build(BuildContext context) {
    return Consumer<SimulatorTestProviderNew>(
      builder: (context, provider, child) {
        return Visibility(
          visible: !provider.isStartTest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset(
              //   AppAssets.img_start,
              //   width: 150,
              // ),
              const Icon(Icons.play_arrow, size: 60),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  provider.setStartTest(true);
                  onClickStartTest();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      AppColor.defaultPurpleColor),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    Utils.multiLanguage("start_test_title"),
                    style: const TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
