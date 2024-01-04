import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/new_logic/playlist_model.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/new_logic/simulator_test_provider_new.dart';
import 'package:provider/provider.dart';

class TestRecordWidget extends StatelessWidget {
  const TestRecordWidget(
      {super.key,
      required this.finishAnswer,
      required this.repeatQuestion,
      required this.simulatorTestProvider});

  final Function(QuestionTopicModel questionTopicModel) finishAnswer;
  final Function(QuestionTopicModel questionTopicModel) repeatQuestion;
  final SimulatorTestProviderNew simulatorTestProvider;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    QuestionTopicModel currentQuestion = simulatorTestProvider.currentQuestion;

    return Consumer<SimulatorTestProviderNew>(builder: (context, provider, _) {
      PlayListModel playListModel = provider.currentPlay;
      bool enableRepeat = ((playListModel.numPart == PartOfTest.part1.get ||
              playListModel.numPart == PartOfTest.part3.get) &&
          provider.repeatTimes <= 1);
      if (provider.visibleRecord) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: w,
              alignment: Alignment.center,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    Utils.multiLanguage(StringConstants.answer_being_recorded),
                    style: const TextStyle(fontSize: 23),
                  ),
                  const SizedBox(height: 20),
                  const Icon(
                    Icons.mic,
                    size: 30,
                  ),
                  const SizedBox(height: 5),
                  Consumer<SimulatorTestProviderNew>(
                      builder: (context, provider, _) {
                    return Text(
                      provider.strCountDown,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFinishButton(simulatorTestProvider, playListModel,
                          currentQuestion),
                      Visibility(
                        visible: enableRepeat,
                        child: Row(
                          children: [
                            const SizedBox(width: 20),
                            _buildRepeatButton(simulatorTestProvider,
                                playListModel, currentQuestion),
                          ],
                        ),
                      )
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

  Widget _buildFinishButton(SimulatorTestProviderNew simulatorTestProvider,
      PlayListModel playListModel, QuestionTopicModel questionTopicModel) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () {
        if (!_lessThan2s(simulatorTestProvider, playListModel)) {
          finishAnswer(questionTopicModel);
        }
      },
      child: Wrap(
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: _lessThan2s(simulatorTestProvider, playListModel)
                  ? const Color.fromARGB(255, 199, 221, 200)
                  : const Color.fromARGB(255, 11, 180, 16),
            ),
            alignment: Alignment.center,
            child: Text(
              Utils.multiLanguage(StringConstants.finish_button_title),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRepeatButton(SimulatorTestProviderNew simulatorTestProvider,
      PlayListModel playListModel, QuestionTopicModel questionTopicModel) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () {
        if (!_lessThan2s(simulatorTestProvider, playListModel)) {
          repeatQuestion(questionTopicModel);
        }
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
        child: Text(
          Utils.multiLanguage(StringConstants.repeat_button_title),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  bool _lessThan2s(SimulatorTestProviderNew simulatorTestProvider,
      PlayListModel playListModel) {
    int countTime = playListModel.part1Time;
    switch (playListModel.numPart) {
      case 2:
        countTime = playListModel.part2Time;
        break;
      case 3:
        countTime = playListModel.part3Time;
        break;
    }

    if (kDebugMode) {
      print(
          'counttime : $countTime, currentCount :${simulatorTestProvider.currentCount}');
    }
    return countTime - simulatorTestProvider.currentCount < 2;
  }
}
