import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/presenters/test_room_presenter.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:provider/provider.dart';

import '../../../data_sources/utils.dart';

class SaveTheTestWidget extends StatelessWidget {
  const SaveTheTestWidget({super.key, required this.testRoomPresenter});

  final TestRoomPresenter testRoomPresenter;

  @override
  Widget build(BuildContext context) {
    return Consumer<SimulatorTestProvider>(
      builder: (context, simulatorTestProvider, child) {
        return Visibility(
          visible: simulatorTestProvider.isVisibleSaveTheTest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(child: SizedBox()),
              Container(
                width: double.infinity,
                height: 44,
                color: AppColor.defaultPurpleColor,
                child: InkWell(
                  onTap: () {
                    testRoomPresenter.clickSaveTheTest();
                  },
                  child: Center(
                    child: Text(
                      Utils.multiLanguage(
                        StringConstants.save_the_exam_button_title
                      ),
                      style: CustomTextStyle.textWithCustomInfo(
                        context: context,
                        color: AppColor.defaultAppColor,
                        fontsSize: FontsSize.fontSize_16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
