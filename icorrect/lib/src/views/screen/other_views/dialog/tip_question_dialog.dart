import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/views/widget/empty_widget.dart';
import 'package:provider/provider.dart';

import '../../../../data_sources/utils.dart';

class TipQuestionDialog {
  static Widget tipQuestionDialog(
      BuildContext context, QuestionTopicModel question) {
    return LayoutBuilder(
      builder: (_, constraint) {
        return Scaffold(
          key: GlobalScaffoldKey.showTipScaffoldKey,
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 20, right: 10),
                      child: Text(
                        Utils.multiLanguage(StringConstants.tips_screen_title),
                        style: CustomTextStyle.textWithCustomInfo(
                          context: context,
                          color: Colors.orange,
                          fontsSize: FontsSize.fontSize_20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () {
                          Provider.of<AuthProvider>(context, listen: false)
                              .setShowDialogWithGlobalScaffoldKey(
                                  false, GlobalScaffoldKey.showTipScaffoldKey);
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  question.content.toString(),
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.textWithCustomInfo(
                    context: context,
                    color: AppColor.defaultBlackColor,
                    fontsSize: FontsSize.fontSize_18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Divider(
                    thickness: 1,
                    color: AppColor.defaultGrayColor,
                  ),
                ),
                const SizedBox(height: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    question.numPart == PartOfTest.part2.get
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                Utils.multiLanguage(StringConstants.cue_card),
                                style: CustomTextStyle.textWithCustomInfo(
                                  context: context,
                                  color: AppColor.defaultBlackColor,
                                  fontsSize: FontsSize.fontSize_16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                question.cueCard.trim(),
                                style: CustomTextStyle.textWithCustomInfo(
                                  context: context,
                                  color: AppColor.defaultBlackColor,
                                  fontsSize: FontsSize.fontSize_16,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          )
                        : Container(),
                    const SizedBox(height: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        question.numPart == PartOfTest.part2.get
                            ? Text(
                                Utils.multiLanguage(StringConstants.another_tips),
                                style: CustomTextStyle.textWithCustomInfo(
                                  context: context,
                                  color: AppColor.defaultBlackColor,
                                  fontsSize: FontsSize.fontSize_16,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : Container(),
                        (question.tips.toString().isNotEmpty)
                            ? Text(
                                question.tips.toString(),
                                style: CustomTextStyle.textWithCustomInfo(
                                  context: context,
                                  color: AppColor.defaultBlackColor,
                                  fontsSize: FontsSize.fontSize_16,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            : EmptyWidget.init().buildNothingWidget(
                                context,
                                Utils.multiLanguage(StringConstants.no_data_message),
                                widthSize: 100,
                                heightSize: 100,
                              )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
