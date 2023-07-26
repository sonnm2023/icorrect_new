import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/provider/my_test_provider.dart';
import 'package:provider/provider.dart';

class TestRecordWidget extends StatelessWidget {
  const TestRecordWidget({super.key, required this.finishAnswer});

  final Function(QuestionTopicModel questionTopicModel) finishAnswer;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return Consumer<MyTestProvider>(builder: (context, testProvider, child) {
      QuestionTopicModel currentQuestion = testProvider.currentQuestion;
      if (kDebugMode) {
        print(currentQuestion.content);
      }

      return Visibility(
        visible: testProvider.visibleRecord,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: w,
              height: 200,
              alignment: Alignment.center,
              color: AppColor.defaultGraySlightColor,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text('You answer is being recorded'),
                  const SizedBox(height: 20),
                  Image.asset(
                    AppAsset.record,
                    width: 25,
                    height: 25,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    testProvider.timerCount,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: _buildFinishButton(currentQuestion),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      );
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
}
