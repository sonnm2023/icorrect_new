import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/views/widget/empty_widget.dart';
import 'package:provider/provider.dart';

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
                      child: const Text(
                        StringConstants.tips_screen_title,
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
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
                              const Text(
                                StringConstants.cue_card,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                question.cueCard.trim(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
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
                            ? const Text(
                                StringConstants.another_tips,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Container(),
                        (question.tips.toString().isNotEmpty)
                            ? Text(
                                question.tips.toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              )
                            : EmptyWidget.init().buildNothingWidget(
                                StringConstants.nothing_tips,
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
