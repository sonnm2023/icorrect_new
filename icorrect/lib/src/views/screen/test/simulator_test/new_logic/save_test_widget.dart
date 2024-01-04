import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/new_logic/button_custom.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/new_logic/simulator_test_provider_new.dart';
import 'package:provider/provider.dart';

class SaveTheTestWidget extends StatelessWidget {
  final Function _onClickSaveTheTest;
  const SaveTheTestWidget(this._onClickSaveTheTest, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SimulatorTestProviderNew>(
      builder: (context, simulatorTestProvider, child) {
        return Visibility(
          visible: simulatorTestProvider.isVisibleSaveTheTest ||
              simulatorTestProvider.reanswersList.isNotEmpty,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(
                  image: AssetImage(_getImage(simulatorTestProvider)),
                  width: 150),
              Text(_getTitle(simulatorTestProvider),
                  style: TextStyle(
                      fontSize: 33,
                      fontWeight: FontWeight.bold,
                      color: simulatorTestProvider.reanswersList.isNotEmpty
                          ? AppColor.defaultPurpleColor
                          : Colors.green)),
              const SizedBox(height: 10),
              Text(
                _getContent(simulatorTestProvider),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColor.defaultGrayColor),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 250,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    _onClickSaveTheTest();
                  },
                  style: ButtonCustom.init().buttonPurple20(),
                  child: Text(
                    _getTitleButton(simulatorTestProvider),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  String _getImage(SimulatorTestProviderNew provider) {
    return provider.reanswersList.isNotEmpty ? "img_QA" : "img_completed";
  }

  String _getTitle(SimulatorTestProviderNew provider) {
    return provider.reanswersList.isNotEmpty
        ? Utils.multiLanguage("reanswer_question")
        : Utils.multiLanguage("congratulations");
  }

  String _getContent(SimulatorTestProviderNew provider) {
    return provider.reanswersList.isNotEmpty
        ? Utils.multiLanguage("reanswer_description")
        : Utils.multiLanguage("finish_test_description");
  }

  String _getTitleButton(SimulatorTestProviderNew provider) {
    return provider.reanswersList.isNotEmpty
        ? Utils.multiLanguage("Update your answer")
        : Utils.multiLanguage(StringConstants.save_button_title);
  }
}
