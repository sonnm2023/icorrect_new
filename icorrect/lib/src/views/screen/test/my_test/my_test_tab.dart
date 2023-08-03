import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/provider/my_test_provider.dart';
import 'package:icorrect/src/views/screen/auth/ai_response_webview.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/confirm_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/tip_question_dialog.dart';
import 'package:icorrect/src/views/screen/test/my_test/download_progressing_widget.dart';
import 'package:icorrect/src/views/screen/test/my_test/test_record_widget.dart';
import 'package:icorrect/src/views/screen/test/my_test/video_my_test.dart';
import 'package:icorrect/src/views/widget/default_text.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';

import '../../../../presenters/my_test_presenter.dart';
import '../../other_views/dialog/alert_dialog.dart';
import '../../other_views/dialog/circle_loading.dart';

class MyTestTab extends StatefulWidget {
  final ActivitiesModel homeWorkModel;
  final MyTestProvider provider;
  const MyTestTab(
      {super.key, required this.homeWorkModel, required this.provider});

  @override
  State<MyTestTab> createState() => _MyTestTabState();
}

class _MyTestTabState extends State<MyTestTab>
    with AutomaticKeepAliveClientMixin<MyTestTab>
    implements MyTestConstract, ActionAlertListener {
  MyTestPresenter? _presenter;
  CircleLoading? _loading;

  AudioPlayer? _player;
  final Record _record = Record();

  @override
  void initState() {
    super.initState();

    _loading = CircleLoading();
    _presenter = MyTestPresenter(this);
    _player = AudioPlayer();
    _loading!.show(context);
    _presenter!
        .getMyTest(widget.homeWorkModel.activityAnswer.testId.toString());

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
    return Consumer<MyTestProvider>(builder: (context, provider, child) {
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
            Stack(
              children: [
                (widget.homeWorkModel.activityAnswer.aiOrder != 0)
                    ? Expanded(child: LayoutBuilder(builder: (_, constraint) {
                        return InkWell(
                          onTap: () {
                            _showAiResponse();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            color: Colors.green,
                            width: constraint.maxWidth,
                            child: const Center(
                              child: Text(
                                'View AI Response',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 19),
                              ),
                            ),
                          ),
                        );
                      }))
                    : Container(),
                Expanded(
                    child: Stack(children: [
                  TestRecordWidget(
                    finishAnswer: (currentQuestion) {
                      _onFinishReanswer(currentQuestion);
                    },
                    cancelAnswer: () {
                      _onCancelReanswer();
                    },
                  ),
                  (provider.reAnswerOfQuestions.isNotEmpty &&
                          !provider.visibleRecord)
                      ? LayoutBuilder(builder: (_, constraint) {
                          return InkWell(
                            onTap: () {
                              _showDialogConfirmSaveChange(provider: provider);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              color: AppColor.defaultPurpleColor,
                              width: constraint.maxWidth,
                              child: const Center(
                                child: Text(
                                  'Update Your Answer',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 19),
                                ),
                              ),
                            ),
                          );
                        })
                      : Container()
                ])),
              ],
            )
          ],
        );
      }
    });
  }

  void _showDialogConfirmSaveChange({required MyTestProvider provider}) {
    showDialog(
        context: context,
        builder: (builder) {
          return ConfirmDialogWidget(
              title: "Confirm",
              message: "Are you sure to save change your answers?",
              cancelButtonTitle: "Cancel",
              okButtonTitle: "Save",
              cancelButtonTapped: () {},
              okButtonTapped: () {
                _onClickUpdateReanswer(provider.reAnswerOfQuestions);
              });
        });
  }

  void _onClickUpdateReanswer(List<QuestionTopicModel> requestions) {
    _loading!.show(context);
    ActivitiesModel homework = widget.homeWorkModel;
    _presenter!.updateMyAnswer(
        testId: homework.activityAnswer.testId.toString(),
        activityId: homework.activityId.toString(),
        reQuestions: requestions);
  }

  void _onFinishReanswer(QuestionTopicModel question) {
    widget.provider.setReAnswerOfQuestions(question);
    int index = widget.provider.myAnswerOfQuestions
        .indexWhere((q) => q.id == question.id);
    widget.provider.myAnswerOfQuestions[index] = question;
    widget.provider.setAnswerOfQuestions(widget.provider.myAnswerOfQuestions);
    _onCancelReanswer();
  }

  void _onCancelReanswer() {
    widget.provider.setVisibleRecord(false);
    widget.provider.setTimerCount('00:00');
    widget.provider.countDownTimer!.cancel();
    widget.provider.setCountDownTimer(null);
    _record.stop();
  }

  _showAiResponse() {
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
          return FutureBuilder(
              future: AiResponseEP(
                  widget.homeWorkModel.activityAnswer.aiOrder.toString()),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: AIResponse(url: snapshot.data.toString()),
                      ),
                      Container(
                        margin: const EdgeInsets.all(10),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.cancel_outlined,
                            color: Colors.black,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Container(
                  height: 400,
                  color: Colors.white,
                  child: const Center(
                    child: Text('Nothing in here',
                        style: TextStyle(
                            color: AppColor.defaultGrayColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w400)),
                  ),
                );
              });
        });
  }

  Widget _questionItem(QuestionTopicModel question) {
    return Consumer<MyTestProvider>(builder: (context, provider, child) {
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
                          widget.provider
                              .setPlayAnswer(true, question.id.toString());

                          if (question.answers.isNotEmpty) {
                            _preparePlayAudio(
                                fileName: Utils.convertFileName(
                                    question.answers.last.url.toString()),
                                questionId: question.id.toString());
                          }
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          (widget.homeWorkModel.canReanswer())
                              ? InkWell(
                                  onTap: () async {
                                    _onClickReanswer(provider, question);
                                  },
                                  child: const DefaultText(
                                      text: 'Reanswer',
                                      color: AppColor.defaultPurpleColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                )
                              : Container(),
                          const SizedBox(width: 20),
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
                      )
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

  void _onClickReanswer(MyTestProvider provider, QuestionTopicModel question) {
    if (!provider.visibleRecord) {
      widget.provider.setCurrentQuestion(question);
      widget.provider.setVisibleRecord(true);
      _recordReanswer(provider.visibleRecord, question);
    }
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

  Future _recordReanswer(
      bool visibleRecord, QuestionTopicModel question) async {
    if (visibleRecord) {
      String audioFile = '${await Utils.generateAudioFileName()}.wav';
      if (await _record.hasPermission()) {
        Timer timer = _presenter!.startCountDown(context, 30);
        widget.provider.setCountDownTimer(timer);
        await _record.start(
          path:
              '${await FileStorageHelper.getFolderPath(MediaType.audio, null)}'
              '\\$audioFile',
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          samplingRate: 44100,
        );
        if (question.answers.isNotEmpty) {
          question.answers.last.url = audioFile;
        } else {
          FileTopicModel fileTopicModel = FileTopicModel();
          fileTopicModel.url = audioFile;
          question.answers.add(fileTopicModel);
        }
        question.reAnswerCount++;
        widget.provider.setCurrentQuestion(question);
      }
    } else {
      _record.stop();
    }
  }

  Future _preparePlayAudio(
      {required String fileName, required String questionId}) async {
    Utils.prepareAudioFile(fileName, null).then((value) {
      //TODO
      print('_playAudio:${value.path.toString()}');
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

  @override
  void finishCountDown() {
    _onFinishReanswer(widget.provider.currentQuestion);
  }

  @override
  void onCountDown(String time) {
    widget.provider.setTimerCount(time);
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
  void getMyTestSuccess(List<QuestionTopicModel> questions) {
    _loading!.hide();
    widget.provider.setAnswerOfQuestions(questions);
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
    if (kDebugMode) {
      print('DEBUG: downloadFilesFail: ${alertInfo.description.toString()}');
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
  void onAlertExit(String keyInfo) {
    // TODO: implement onAlertExit
  }

  @override
  void onAlertNextStep(String keyInfo) {
    // TODO: implement onAlertNextStep
  }

  @override
  void updateAnswersSuccess(String message) {
    widget.provider.setAnswerOfQuestions(widget.provider.myAnswerOfQuestions);
    widget.provider.setVisibleRecord(false);
    widget.provider.setTimerCount('00:00');
    widget.provider.clearReAnswerOfQuestions();

    Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        fontSize: 18,
        toastLength: Toast.LENGTH_LONG);

    _loading!.hide();
  }

  @override
  void updateAnswerFail(AlertInfo info) {
    print(info.description.toString());
    //AlertsDialog.init().showDialog(context, info, this);
    _loading!.hide();
    Fluttertoast.showToast(
        msg: info.description,
        backgroundColor: AppColor.defaultGrayColor,
        textColor: Colors.black,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM);
  }

  @override
  bool get wantKeepAlive => true;
}
