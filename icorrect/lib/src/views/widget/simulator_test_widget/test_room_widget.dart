import 'package:flutter/material.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/presenters/test_presenter.dart';
import 'package:icorrect/src/provider/test_provider.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/cue_card_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/save_test_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/test_question_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/test_record_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/video_player_widget.dart';
import 'package:provider/provider.dart';

class TestRoomWidget extends StatefulWidget {
  const TestRoomWidget({
    super.key,
    required this.testPresenter,
    // required this.testProvider,
    required this.playVideoCallBack,
    required this.finishAnswerCallBack,
    required this.repeatQuestionCallBack,
    required this.playAnswerCallBack,
    required this.playReAnswerCallBack,
    required this.showTipCallBack,
  });

  final TestPresenter testPresenter;
  // final TestProvider testProvider;

  final Function playVideoCallBack;
  final Function(QuestionTopicModel questionTopicModel) finishAnswerCallBack;
  final Function(QuestionTopicModel questionTopicModel) repeatQuestionCallBack;

  final Function(
      QuestionTopicModel questionTopicModel, int selectedQuestionIndex)
  playAnswerCallBack;
  final Function(QuestionTopicModel questionTopicModel) playReAnswerCallBack;
  final Function(QuestionTopicModel questionTopicModel) showTipCallBack;

  @override
  State<TestRoomWidget> createState() => _TestRoomWidgetState();
}

class _TestRoomWidgetState extends State<TestRoomWidget> {
  TestProvider? testProvider;

  @override
  void initState() {
    super.initState();
    testProvider = Provider.of<TestProvider>(context, listen: false);
  }

  @override
  void dispose() {
    if (null != testProvider) {
      if (!testProvider!.isDisposed) {
        testProvider!.dispose();
      }
    }

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg_test_room.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: const Text("VIDEO PLAYER"),//VideoPlayerWidget(playVideo: playVideoCallBack), //TODO
        ),
        // Expanded(
        //   child: Stack(
        //     alignment: Alignment.topCenter,
        //     children: [
        //       SingleChildScrollView(
        //         child: TestQuestionWidget(
        //           testPresenter: testPresenter,
        //           playAnswerCallBack: playAnswerCallBack,
        //           playReAnswerCallBack: playReAnswerCallBack,
        //           showTipCallBack: showTipCallBack,
        //         ),
        //       ),
        //       CueCardWidget(question: testProvider.currentQuestion),
        //       Column(
        //         crossAxisAlignment: CrossAxisAlignment.end,
        //         children: [
        //           const Expanded(child: SizedBox()),
        //           SizedBox(
        //             height: 200,
        //             child: Stack(
        //               children: [
        //                 TestRecordWidget(
        //                   finishAnswer: finishAnswerCallBack,
        //                   repeatQuestion: repeatQuestionCallBack,
        //                 ),
        //                 SaveTheTestWidget(testPresenter: testPresenter),
        //               ],
        //             ),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // )
      ],
    );
  }
}
