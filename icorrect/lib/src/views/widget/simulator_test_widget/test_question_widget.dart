import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/presenters/test_room_presenter.dart';
import 'package:icorrect/src/provider/play_answer_provider.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/load_local_image_widget.dart';
import 'package:provider/provider.dart';

class TestQuestionWidget extends StatefulWidget {
  const TestQuestionWidget({
    super.key,
    required this.testRoomPresenter,
    required this.playAnswerCallBack,
    required this.reAnswerCallBack,
    required this.showTipCallBack,
    required this.simulatorTestProvider,
    required this.isExam,
  });

  final TestRoomPresenter testRoomPresenter;
  final SimulatorTestProvider simulatorTestProvider;

  final Function(
          QuestionTopicModel questionTopicModel, int selectedQuestionIndex)
      playAnswerCallBack;
  final Function(QuestionTopicModel questionTopicModel) reAnswerCallBack;
  final Function(QuestionTopicModel questionTopicModel) showTipCallBack;
  final bool isExam;

  @override
  State<TestQuestionWidget> createState() => _TestQuestionWidgetState();
}

class _TestQuestionWidgetState extends State<TestQuestionWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.simulatorTestProvider.questionList.isEmpty) {
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(20),
        height: 300,
        child: Text(
          Utils.multiLanguage(
            StringConstants.no_answer_please_start_your_test_message,
          ),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultBlackColor,
            fontsSize: FontsSize.fontSize_15,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemCount: widget.simulatorTestProvider.questionList.length,
            itemBuilder: (BuildContext context, int index) {
              //Header part 1
              if (index == 0) {
                return Column(
                  children: [
                    Container(
                      color: AppColor.defaultLightGrayColor,
                      height: 44,
                      child: ListTile(
                        title: Center(
                          child: Text(
                            Utils.multiLanguage(
                              StringConstants.part_1_header,
                            ),
                            textAlign: TextAlign.center,
                            style: CustomTextStyle.textWithCustomInfo(
                              context: context,
                              color: AppColor.defaultPurpleColor,
                              fontsSize: FontsSize.fontSize_16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // The fist list item
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      child: _buildTestQuestionItem(
                        context,
                        widget.simulatorTestProvider.questionList
                            .elementAt(index),
                        index,
                      ),
                    ),
                  ],
                );
              }

              //Header part 2
              if (widget.simulatorTestProvider.indexOfHeaderPart2 != 0 &&
                  index == widget.simulatorTestProvider.indexOfHeaderPart2) {
                return Column(
                  children: [
                    Container(
                      color: AppColor.defaultLightGrayColor,
                      height: 44,
                      child: ListTile(
                        title: Center(
                          child: Text(
                            Utils.multiLanguage(
                              StringConstants.part_2_header,
                            ),
                            textAlign: TextAlign.center,
                            style: CustomTextStyle.textWithCustomInfo(
                              context: context,
                              color: AppColor.defaultPurpleColor,
                              fontsSize: FontsSize.fontSize_16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // The fist list item
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      child: _buildTestQuestionItem(
                        context,
                        widget.simulatorTestProvider.questionList
                            .elementAt(index),
                        index,
                      ),
                    ),
                  ],
                );
              }

              //Header part 3
              if (widget.simulatorTestProvider.indexOfHeaderPart3 != 0 &&
                  index == widget.simulatorTestProvider.indexOfHeaderPart3) {
                return Column(
                  children: [
                    Container(
                      color: AppColor.defaultLightGrayColor,
                      height: 44,
                      child: ListTile(
                        title: Center(
                          child: Text(
                            Utils.multiLanguage(
                              StringConstants.part_3_header,
                            ),
                            textAlign: TextAlign.center,
                            style: CustomTextStyle.textWithCustomInfo(
                              context: context,
                              color: AppColor.defaultPurpleColor,
                              fontsSize: FontsSize.fontSize_16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // The fist list item
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      child: _buildTestQuestionItem(
                        context,
                        widget.simulatorTestProvider.questionList
                            .elementAt(index),
                        index,
                      ),
                    ),
                  ],
                );
              }

              return Container(
                margin: const EdgeInsets.only(top: 15),
                child: _buildTestQuestionItem(
                  context,
                  widget.simulatorTestProvider.questionList.elementAt(index),
                  index,
                ),
              );
            },
          ),
          const SizedBox(height: 60),
        ],
      );
    }
  }

  Widget _buildTestQuestionItem(
      BuildContext context, QuestionTopicModel question, int index) {
    bool hasCueCard = false;
    String questionStr = question.content;

    if (question.cueCard.trim().isNotEmpty) {
      hasCueCard = true;
      questionStr = Utils.multiLanguage(
        StringConstants.answer_of_part_2,
      );
    }

    SimulatorTestProvider prepareSimulatorTestProvider =
        Provider.of<SimulatorTestProvider>(context, listen: false);
    bool hasReAnswer = false;
    if (prepareSimulatorTestProvider.activityType ==
            ActivityType.homework.name ||
        prepareSimulatorTestProvider.activityType ==
            ActivityType.practice.name) {
      hasReAnswer = true;
    }

    bool hasImage = Utils.checkHasImage(question: question);
    String fileName = question.files.last.url;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: hasCueCard,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.content,
                    style: CustomTextStyle.textWithCustomInfo(
                      context: context,
                      color: AppColor.defaultBlackColor,
                      fontsSize: FontsSize.fontSize_14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    question.cueCard.trim(),
                    textAlign: TextAlign.start,
                    style: CustomTextStyle.textWithCustomInfo(
                      context: context,
                      color: AppColor.defaultBlackColor,
                      fontsSize: FontsSize.fontSize_15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Divider(color: AppColor.defaultPurpleColor, height: 1),
                ],
              ),
            ),
          ),
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            leading: Consumer<PlayAnswerProvider>(
              builder: (context, playAnswerProvider, _) {
                String iconPath;
                if (index == playAnswerProvider.selectedQuestionIndex) {
                  iconPath = "assets/images/ic_pause.png";
                } else {
                  iconPath = "assets/images/ic_play.png";
                }

                return InkWell(
                  onTap: () {
                    widget.playAnswerCallBack(question, index);
                  },
                  child: Image(
                    image: AssetImage(iconPath),
                    width: 50,
                    height: 50,
                  ),
                );
              },
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  questionStr,
                  style: CustomTextStyle.textWithCustomInfo(
                    context: context,
                    color: AppColor.defaultBlackColor,
                    fontsSize: FontsSize.fontSize_15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (hasReAnswer && !widget.isExam)
                          InkWell(
                            onTap: () {
                              widget.reAnswerCallBack(question);
                            },
                            child: Text(
                              Utils.multiLanguage(
                                StringConstants.re_answer_button_title,
                              ),
                              style: CustomTextStyle.textWithCustomInfo(
                                context: context,
                                color: AppColor.defaultPurpleColor,
                                fontsSize: FontsSize.fontSize_16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          const SizedBox(),
                        Visibility(
                          visible: question.tips.isNotEmpty,
                          child: Row(
                            children: [
                              const SizedBox(width: 20),
                              InkWell(
                                onTap: () {
                                  widget.showTipCallBack(question);
                                },
                                child: Text(
                                  Utils.multiLanguage(
                                    StringConstants.view_tips_button_title,
                                  ),
                                  style: CustomTextStyle.textWithCustomInfo(
                                    context: context,
                                    color: AppColor.defaultPurpleColor,
                                    fontsSize: FontsSize.fontSize_14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
            trailing: hasImage
                ? InkWell(
                    onTap: () {
                      _showFullImage(fileName: fileName);
                    },
                    child: LoadLocalImageWidget(
                      imageUrl: fileName,
                      isInRow: true,
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  void _showFullImage({required String fileName}) {
    if (kDebugMode) {
      print("DEBUG: _showFullImage");
    }

    if (widget.simulatorTestProvider.doingStatus == DoingStatus.finish) {
      widget.simulatorTestProvider.setSelectedQuestionImageUrl(fileName);
      widget.simulatorTestProvider.setShowFullImage(true);
    } else {
      showToastMsg(
        msg: Utils.multiLanguage(
          StringConstants.wait_until_the_exam_finished_message,
        ),
        toastState: ToastStatesType.warning,
      );
    }
  }
}
