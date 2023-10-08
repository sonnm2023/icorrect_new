import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/presenters/test_room_presenter.dart';
import 'package:icorrect/src/provider/play_answer_provider.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:provider/provider.dart';

class TestQuestionWidget extends StatelessWidget {
  const TestQuestionWidget({
    super.key,
    required this.testRoomPresenter,
    required this.playAnswerCallBack,
    required this.reAnswerCallBack,
    required this.showTipCallBack, 
    required this.simulatorTestProvider,
  });

  final TestRoomPresenter testRoomPresenter;
  final SimulatorTestProvider simulatorTestProvider;
  
  final Function(
          QuestionTopicModel questionTopicModel, int selectedQuestionIndex)
      playAnswerCallBack;
  final Function(QuestionTopicModel questionTopicModel) reAnswerCallBack;
  final Function(QuestionTopicModel questionTopicModel) showTipCallBack;

  @override
  Widget build(BuildContext context) {
    return Consumer<SimulatorTestProvider>(
      builder: (context, simulatorTestProvider, child) {
        if (simulatorTestProvider.questionList.isEmpty) {
          return Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(20),
            height: 300,
            child: const Text(
              StringConstants.no_answer_please_start_your_test_message,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        } else {
          return Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: simulatorTestProvider.questionList.length,
                itemBuilder: (BuildContext context, int index) {
                  //Header part 1
                  if (index == 0) {
                    return Column(
                      children: [
                        Container(
                          color: AppColor.defaultLightGrayColor,
                          height: 44,
                          child: const ListTile(
                            title: Center(
                              child: Text(
                                StringConstants.part_1_header,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.defaultPurpleColor,
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
                            simulatorTestProvider.questionList.elementAt(index),
                            index,
                          ),
                        ),
                      ],
                    );
                  }

                  //Header part 2
                  if (simulatorTestProvider.indexOfHeaderPart2 != 0 &&
                      index == simulatorTestProvider.indexOfHeaderPart2) {
                    return Column(
                      children: [
                        Container(
                          color: AppColor.defaultLightGrayColor,
                          height: 44,
                          child: const ListTile(
                            title: Center(
                              child: Text(
                                StringConstants.part_2_header,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.defaultPurpleColor,
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
                            simulatorTestProvider.questionList.elementAt(index),
                            index,
                          ),
                        ),
                      ],
                    );
                  }

                  //Header part 3
                  if (simulatorTestProvider.indexOfHeaderPart3 != 0 &&
                      index == simulatorTestProvider.indexOfHeaderPart3) {
                    return Column(
                      children: [
                        Container(
                          color: AppColor.defaultLightGrayColor,
                          height: 44,
                          child: const ListTile(
                            title: Center(
                              child: Text(
                                StringConstants.part_3_header,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.defaultPurpleColor,
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
                            simulatorTestProvider.questionList.elementAt(index),
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
                      simulatorTestProvider.questionList.elementAt(index),
                      index,
                    ),
                  );
                },
              ),
              const SizedBox(height: 60),
            ],
          );
        }
      },
    );
  }

  Widget _buildTestQuestionItem(
      BuildContext context, QuestionTopicModel question, int index) {
    bool hasCueCard = false;
    String questionStr = question.content;

    if (question.cueCard.trim().isNotEmpty) {
      hasCueCard = true;
      questionStr = StringConstants.answer_of_part_2;
    }

    SimulatorTestProvider prepareSimulatorTestProvider =
        Provider.of<SimulatorTestProvider>(context, listen: false);
    bool hasReAnswer = false;
    if (prepareSimulatorTestProvider.activityType == "homework") {
      hasReAnswer = true;
    }

    bool hasImage = Utils.checkHasImage(question: question);
    String fileName = question.files.last.url;
    String imageUrl = downloadFileEP(fileName);

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
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    question.cueCard.trim(),
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 15,
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
                    playAnswerCallBack(question, index);
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
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
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
                        if (hasReAnswer)
                          InkWell(
                            onTap: () {
                              reAnswerCallBack(question);
                            },
                            child: const Text(
                              StringConstants.re_answer_button_title,
                              style: TextStyle(
                                color: AppColor.defaultPurpleColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
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
                                  showTipCallBack(question);
                                },
                                child: const Text(
                                  StringConstants.view_tips_button_title,
                                  style: TextStyle(
                                    color: AppColor.defaultPurpleColor,
                                    fontSize: 14,
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
                      _showFullImage(imageUrl: imageUrl);
                    },
                    child: CachedNetworkImage(
                      width: 50,
                      height: 50,
                      imageUrl: imageUrl,
                      fit: BoxFit.fill,
                      placeholder: (context, url) => const Image(
                        image: AssetImage("assets/default_photo.png"),
                        width: 50,
                        height: 50,
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error_outline_sharp, weight: 60,),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  void _showFullImage({required String imageUrl}) {
    if (kDebugMode) {
      print("DEBUG: _showFullImage");
    }

    if (simulatorTestProvider.doingStatus == DoingStatus.finish) {
      simulatorTestProvider.setSelectedQuestionImageUrl(imageUrl);
      simulatorTestProvider.setShowFullImage(true);
    } else {
      showToastMsg(
        msg: StringConstants.wait_until_the_exam_finished_message,
        toastState: ToastStatesType.warning,
      );
    }
  }
}
