import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/my_test_models/student_result_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/presenters/other_student_test_presenter.dart';
import 'package:icorrect/src/provider/student_test_detail_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/app_asset.dart';
import '../../../../../../core/app_color.dart';
import '../../../../../data_sources/utils.dart';
import '../../../../../models/simulator_test_models/question_topic_model.dart';
import '../../../../../presenters/my_test_presenter.dart';
import '../../../../../provider/my_test_provider.dart';
import '../../../../widget/default_text.dart';
import '../../../other_views/dialog/circle_loading.dart';
import '../../../other_views/dialog/tip_question_dialog.dart';
import 'download_progressing_widget.dart';

class TestDetailScreen extends StatefulWidget {
  StudentTestProvider provider;
  StudentResultModel studentResultModel;
  TestDetailScreen(
      {super.key, required this.provider, required this.studentResultModel});

  @override
  State<TestDetailScreen> createState() => _TestDetailScreenState();
}

class _TestDetailScreenState extends State<TestDetailScreen>
    with AutomaticKeepAliveClientMixin<TestDetailScreen>
    implements OtherStudentTestContract {
  CircleLoading? _loading;
  OtherStudentTestPresenter? _presenter;
  AudioPlayer? _player;

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _presenter = OtherStudentTestPresenter(this);
    _player = AudioPlayer();
    _loading!.show(context);

    print("tetst: ${widget.studentResultModel.testId.toString()}");
    _presenter!.getMyTest(widget.studentResultModel.testId.toString());

    Future.delayed(Duration.zero, () {
      widget.provider.setDownloadingFile(true);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _player!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildMyTest();
  }

  Widget _buildMyTest() {
    return Consumer<StudentTestProvider>(builder: (context, provider, child) {
      if (provider.isDownloading) {
        return const DownloadProgressingWidget();
      } else {
        return Column(
          children: [
            // Expanded(flex: 5, child: VideoMyTest()),
            Expanded(
                flex: 9,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.myAnswerOfQuestions.length,
                    itemBuilder: (context, index) {
                      return _questionItem(provider.myAnswerOfQuestions[index]);
                    })),
          ],
        );
      }
    });
  }

  Widget _questionItem(QuestionTopicModel question) {
    return Consumer<StudentTestProvider>(builder: (context, provider, child) {
      return Card(
        elevation: 2,
        child: LayoutBuilder(builder: (_, constraint) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: const EdgeInsets.only(top: 10),
            width: constraint.maxWidth,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                (provider.playAnswer &&
                        question.id.toString() == provider.questionId)
                    ? InkWell(
                        onTap: () async {
                          widget.provider
                              .setPlayAnswer(false, question.id.toString());
                          _stopAudio();
                        },
                        child: const Image(
                          image: AssetImage(AppAsset.play),
                          width: 50,
                          height: 50,
                        ),
                      )
                    : InkWell(
                        onTap: () async {
                          _onClickPlayAnswer(question);
                        },
                        child: const Image(
                          image: AssetImage(AppAsset.stop),
                          width: 50,
                          height: 50,
                        ),
                      ),
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: 280,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question.content.toString(),
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          _showTips(question);
                        },
                        child: (question.tips.isNotEmpty)
                            ? const DefaultText(
                                text: 'View Tips',
                                color: AppColor.defaultPurpleColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)
                            : Container(),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
      );
    });
  }

  Future _onClickPlayAnswer(QuestionTopicModel question) async {
    if (question.answers.isNotEmpty) {
      widget.provider.setPlayAnswer(true, question.id.toString());
      _preparePlayAudio(
          fileName: Utils.convertFileName(question.answers.last.url.toString()),
          questionId: question.id.toString());
    } else {
      Fluttertoast.showToast(
          msg: 'No answer in here !',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    }
  }

  Future _preparePlayAudio(
      {required String fileName, required String questionId}) async {
    Utils.prepareAudioFile(fileName, null).then((value) {
      //TODO
      if (kDebugMode) {
        print('DEBUG: _playAudio:${value.path.toString()}');
      }
      _playAudio(value.path.toString(), questionId);
    });
  }

  Future<void> _playAudio(String audioPath, String questionId) async {
    try {
       await _player!.play(DeviceFileSource(audioPath));
      await _player!.setVolume(2.5);
      _player!.onPlayerComplete.listen((event) {
        widget.provider.setPlayAnswer(false, questionId);
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("DEBUG:  _playAudio $e");
      }
    }
  }

  Future<void> _stopAudio() async {
    await _player!.stop();
  }

  _showTips(QuestionTopicModel questionTopicModel) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        enableDrag: false,
        barrierColor: AppColor.defaultGrayColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 20),
        builder: (_) {
          return TipQuestionDialog.tipQuestionDialog(
              context, questionTopicModel);
        });
  }

  @override
  void downloadFilesFail(AlertInfo alertInfo) {
    _loading!.hide();
    Fluttertoast.showToast(
        msg: alertInfo.description,
        backgroundColor: AppColor.defaultGrayColor,
        textColor: Colors.black,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM);
  }

  @override
  void downloadFilesSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total) {
    widget.provider.setTotal(total);
    widget.provider.updateDownloadingPercent(percent);
    widget.provider.updateDownloadingIndex(index);
    if (index == total) {
      widget.provider.setDownloadingFile(false);
      widget.provider.setTotal(0);
      widget.provider.updateDownloadingPercent(0.0);
      widget.provider.updateDownloadingIndex(0);
    }
  }

  @override
  void getMyTestFail(AlertInfo alertInfo) {
    _loading!.hide();

    Fluttertoast.showToast(
        msg: alertInfo.description,
        backgroundColor: AppColor.defaultGrayColor,
        textColor: Colors.black,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM);
    if (kDebugMode) {
      print('DEBUG: getMyTestFail: ${alertInfo.description.toString()}');
    }
  }

  @override
  void getMyTestSuccess(List<QuestionTopicModel> questions) {
    _loading!.hide();
    widget.provider.setAnswerOfQuestions(questions);
  }

  @override
  bool get wantKeepAlive => true;
}