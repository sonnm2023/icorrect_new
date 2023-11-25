import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:provider/provider.dart';

import '../../../data_sources/utils.dart';

class CueCardWidget extends StatefulWidget {
  const CueCardWidget({super.key});

  @override
  State<CueCardWidget> createState() => _CueCardWidgetState();
}

class _CueCardWidgetState extends State<CueCardWidget> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Consumer<SimulatorTestProvider>(
      builder: (context, simulatorTestProvider, child) {
        if (simulatorTestProvider.visibleCueCard &&
            simulatorTestProvider.currentQuestion.cueCard.isNotEmpty) {
          return Container(
            width: w,
            height: h,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      Utils.multiLanguage(StringConstants.cue_card),
                      style: CustomTextStyle.textWithCustomInfo(
                        context: context,
                        color: AppColor.defaultBlackColor,
                        fontsSize: FontsSize.fontSize_22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      simulatorTestProvider.strCountCueCard,
                      style: CustomTextStyle.textWithCustomInfo(
                        context: context,
                        color: Colors.red,
                        fontsSize: FontsSize.fontSize_22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    simulatorTestProvider.currentQuestion.content,
                    style: CustomTextStyle.textWithCustomInfo(
                      context: context,
                      color: AppColor.defaultBlackColor,
                      fontsSize: FontsSize.fontSize_18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(
                        simulatorTestProvider.currentQuestion.cueCard.trim(),
                        textAlign: TextAlign.left,
                        style: CustomTextStyle.textWithCustomInfo(
                          context: context,
                          color: AppColor.defaultBlackColor,
                          fontsSize: FontsSize.fontSize_16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
