import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/presenters/test_presenter.dart';
import 'package:icorrect/src/provider/test_provider.dart';
import 'package:provider/provider.dart';

class TestQuestionWidget extends StatelessWidget {
  const TestQuestionWidget({
    super.key,
    required this.testPresenter,
    required this.playAnswerCallBack,
    required this.playReAnswerCallBack,
    required this.showTipCallBack,
  });

  final TestPresenter testPresenter;
  final Function(QuestionTopicModel questionTopicModel) playAnswerCallBack;
  final Function(QuestionTopicModel questionTopicModel) playReAnswerCallBack;
  final Function(QuestionTopicModel questionTopicModel) showTipCallBack;

  @override
  Widget build(BuildContext context) {
    return Consumer<TestProvider>(
      builder: (context, testProvider, child) {
        if (testProvider.questionList.isEmpty) {
          return Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(20),
            height: 300,
            child: const Text(
              "Oops, No answer here, please start your test!",
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemCount: testProvider.questionList.length,
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
                            'Practice Part 1',
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
                        testProvider.questionList.elementAt(index),
                      ),
                    ),
                  ],
                );
              }

              //Header part 2
              if (testProvider.indexOfHeaderPart2 != 0 &&
                  index == testProvider.indexOfHeaderPart2) {
                return Column(
                  children: [
                    Container(
                      color: AppColor.defaultLightGrayColor,
                      height: 44,
                      child: const ListTile(
                        title: Center(
                          child: Text(
                            'Practice Part 2',
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
                        testProvider.questionList.elementAt(index),
                      ),
                    ),
                  ],
                );
              }

              //Header part 3
              if (testProvider.indexOfHeaderPart3 != 0 &&
                  index == testProvider.indexOfHeaderPart3) {
                return Column(
                  children: [
                    Container(
                      color: AppColor.defaultLightGrayColor,
                      height: 44,
                      child: const ListTile(
                        title: Center(
                          child: Text(
                            'Practice Part 3',
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
                        testProvider.questionList.elementAt(index),
                      ),
                    ),
                  ],
                );
              }

              return Container(
                margin: const EdgeInsets.only(top: 15),
                child: _buildTestQuestionItem(
                  context,
                  testProvider.questionList.elementAt(index),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildTestQuestionItem(
      BuildContext context, QuestionTopicModel question) {
    bool hasCueCard = false;
    String questionStr = question.content;
    if (question.cueCard.trim().isNotEmpty) {
      hasCueCard = true;
      questionStr = 'Answer of Part 2';
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: hasCueCard,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
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
            onTap: () {
              playAnswerCallBack(question);
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            leading: const Image(
              image: AssetImage("assets/images/ic_play.png"),
              width: 50,
              height: 50,
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
                        InkWell(
                          onTap: () {
                            playReAnswerCallBack(question);
                          },
                          child: const Text(
                            "Re-answer",
                            style: TextStyle(
                              color: AppColor.defaultPurpleColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
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
                                  "View tips",
                                  style: TextStyle(
                                    color: Colors.amber,
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
          ),
        ],
      ),
    );
  }
}
