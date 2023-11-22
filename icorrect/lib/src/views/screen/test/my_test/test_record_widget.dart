import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/provider/my_test_provider.dart';
import 'package:provider/provider.dart';

class TestRecordWidget extends StatelessWidget {
  const TestRecordWidget(
      {super.key, required this.finishAnswer, required this.cancelAnswer});

  final Function(QuestionTopicModel questionTopicModel) finishAnswer;
  final Function() cancelAnswer;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Consumer<MyTestProvider>(
      builder: (context, testProvider, child) {
        QuestionTopicModel currentQuestion = testProvider.currentQuestion;
        if (kDebugMode) {
          print("DEBUG: TestRecordWidget ${currentQuestion.content}");
        }

        return Visibility(
          visible: testProvider.visibleRecord,
          child: Container(
            width: w,
            height: h / 4,
            alignment: Alignment.center,
            color: AppColor.defaultGraySlightColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: w * 0.8,
                  height: CustomSize.size_200,
                  alignment: Alignment.center,
                  color: AppColor.defaultGraySlightColor,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: CustomSize.size_20,
                      ),
                      Text(Utils.multiLanguage(StringConstants.answer_being_recorded)),
                      const SizedBox(
                        height: CustomSize.size_20,
                      ),
                      Image.asset(
                        AppAsset.record,
                        width: CustomSize.size_25,
                        height: CustomSize.size_25,
                      ),
                      const SizedBox(
                        height: CustomSize.size_5,
                      ),
                      Text(
                        testProvider.timerCount,
                        style: CustomTextStyle.textWithCustomInfo(
                          context: context,
                          color: AppColor.defaultBlackColor,
                          fontsSize: FontsSize.fontSize_20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: CustomSize.size_20),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: CustomSize.size_40,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildCancelButton(context),
                            _buildFinishButton(
                                context: context,
                                questionTopicModel: currentQuestion,
                                isLess2Second: testProvider.isLessThan2Second),
                          ],
                        ),
                      ),
                      const SizedBox(height: CustomSize.size_20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFinishButton(
      {required BuildContext context,
      required QuestionTopicModel questionTopicModel,
      required bool isLess2Second}) {
    return InkWell(
      onTap: () {
        finishAnswer(questionTopicModel);
      },
      child: Container(
        width: CustomSize.size_100,
        height: CustomSize.size_40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(CustomSize.size_20),
          color: isLess2Second
              ? const Color.fromARGB(255, 153, 201, 154)
              : Colors.green,
        ),
        alignment: Alignment.center,
        child: Text(
          Utils.multiLanguage(StringConstants.finish_button_title),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultAppColor,
            fontsSize: FontsSize.fontSize_15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return InkWell(
      onTap: () {
        cancelAnswer();
      },
      child: Container(
        width: CustomSize.size_100,
        height: CustomSize.size_40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(CustomSize.size_20),
          color: AppColor.defaultLightGrayColor,
        ),
        alignment: Alignment.center,
        child: Text(
          Utils.multiLanguage(StringConstants.cancel_button_title),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultAppColor,
            fontsSize: FontsSize.fontSize_15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
