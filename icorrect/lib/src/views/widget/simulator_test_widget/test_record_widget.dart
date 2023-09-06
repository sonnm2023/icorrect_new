import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:icorrect/src/provider/timer_provider.dart';
import 'package:provider/provider.dart';

class TestRecordWidget extends StatelessWidget {
  const TestRecordWidget(
      {super.key, required this.finishAnswer, required this.repeatQuestion});

  final Function(QuestionTopicModel questionTopicModel) finishAnswer;
  final Function(QuestionTopicModel questionTopicModel) repeatQuestion;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    SimulatorTestProvider simulatorTestProvider =
        Provider.of<SimulatorTestProvider>(context, listen: false);

    QuestionTopicModel currentQuestion = simulatorTestProvider.currentQuestion;

    bool isRepeat = false;

    return Consumer<SimulatorTestProvider>(builder: (context, simulatorTestProvider, _) {
      if (simulatorTestProvider.visibleRecord) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: w,
              height: 200,
              alignment: Alignment.center,
              color: AppColor.defaultLightGrayColor,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text('You answer is being recorded'),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/ic_record_2.png',
                    width: 25,
                    height: 25,
                  ),
                  const SizedBox(height: 5),
                  Consumer<TimerProvider>(builder: (context, timerProvider, _) {
                    return Text(
                      timerProvider.strCount,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFinishButton(currentQuestion),
                      Consumer<SimulatorTestProvider>(
                          builder: (context, simulatorTestProvider, _) {
                            if (simulatorTestProvider.topicsQueue.isNotEmpty) {
                              isRepeat = (simulatorTestProvider.topicsQueue.first.numPart ==
                                  PartOfTest.part1.get ||
                                  simulatorTestProvider.topicsQueue.first.numPart ==
                                      PartOfTest.part3.get) && simulatorTestProvider.enableRepeatButton;
                            }

                            return Visibility(
                              visible: isRepeat,
                              child: Row(
                                children: [
                                  const SizedBox(width: 20),
                                  _buildRepeatButton(currentQuestion),
                                ],
                              ),
                            );
                          }),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      } else {
        return const SizedBox();
      }
    });
  }

  Widget _buildFinishButton(QuestionTopicModel questionTopicModel) {
    return InkWell(
      onTap: () {
        finishAnswer(questionTopicModel);
      },
      child: Container(
        width: 100,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.green,
        ),
        alignment: Alignment.center,
        child: const Text(
          'Finish',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRepeatButton(QuestionTopicModel questionTopicModel) {
    return InkWell(
      onTap: () {
        repeatQuestion(questionTopicModel);
      },
      child: Container(
        width: 100,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white,
          border: Border.all(width: 1, color: Colors.grey),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Repeat',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
