import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/provider/my_test_provider.dart';
import 'package:icorrect/src/views/screen/auth/ai_response_webview.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/confirm_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/custom_alert_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/tip_question_dialog.dart';
import 'package:icorrect/src/views/screen/test/my_test/download_progressing_widget.dart';
import 'package:icorrect/src/views/screen/test/my_test/test_record_widget.dart';
import 'package:icorrect/src/views/widget/download_again_widget.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

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
    with AutomaticKeepAliveClientMixin<MyTestTab>, WidgetsBindingObserver
    implements MyTestContract, ActionAlertListener {
  MyTestPresenter? _presenter;
  CircleLoading? _loading;

  AudioPlayer? _player;
  final Record _record = Record();
  bool isOffline = false;
  StreamSubscription? connection;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    connection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // when every connection status is changed.
      if (result == ConnectivityResult.none) {
        isOffline = true;
      } else if (result == ConnectivityResult.mobile) {
        isOffline = false;
      } else if (result == ConnectivityResult.wifi) {
        isOffline = false;
      } else if (result == ConnectivityResult.ethernet) {
        isOffline = false;
      } else if (result == ConnectivityResult.bluetooth) {
        isOffline = false;
      }

      if (kDebugMode) {
        print("DEBUG: NO INTERNET === $isOffline");
      }
    });

    _loading = CircleLoading();
    _presenter = MyTestPresenter(this);
    _player = AudioPlayer();
    _loading!.show(context);
    _getMyTest();

    Future.delayed(Duration.zero, () {
      widget.provider.setDownloadingFile(true);
    });
  }

  void _getMyTest() async {
    await _presenter!.initializeData();
    _presenter!
        .getMyTest(widget.homeWorkModel.activityAnswer!.testId.toString());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player!.dispose();
    _presenter!.closeClientRequest();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildMyTest();
  }

  Widget _buildMyTest() {
    return Consumer<MyTestProvider>(
      builder: (context, provider, child) {
        if (provider.isDownloading) {
          return const DownloadProgressingWidget();
        } else {
          return Stack(
            children: [
              Column(
                children: [
                  // Expanded(flex: 5, child: VideoMyTest()),
                  Expanded(
                      flex: 9,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: provider.myAnswerOfQuestions.length,
                          itemBuilder: (context, index) {
                            return _questionItem(
                                provider.myAnswerOfQuestions[index]);
                          })),
                  Stack(
                    children: [
                      (widget.homeWorkModel.activityAnswer!.aiOrder != 0)
                          ? Expanded(
                              child: LayoutBuilder(
                                builder: (_, constraint) {
                                  return InkWell(
                                    onTap: () {
                                      _showAiResponse();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: CustomSize.size_10,
                                      ),
                                      color: Colors.green,
                                      width: constraint.maxWidth,
                                      child: const Center(
                                        child: Text(
                                          'View AI Response',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 19,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(),
                      Expanded(
                        child: Stack(
                          children: [
                            TestRecordWidget(
                              finishAnswer: (currentQuestion) {
                                _onFinishReanswer(currentQuestion);
                              },
                              cancelAnswer: () {
                                _onCancelReAnswer();
                              },
                            ),
                            (provider.reAnswerOfQuestions.isNotEmpty &&
                                    !provider.visibleRecord)
                                ? LayoutBuilder(
                                    builder: (_, constraint) {
                                      return InkWell(
                                        onTap: () {
                                          _showDialogConfirmSaveChange(
                                              provider: provider);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: CustomSize.size_10,
                                          ),
                                          color: AppColor.defaultPurpleColor,
                                          width: constraint.maxWidth,
                                          child: const Center(
                                            child: Text(
                                              'Update Your Answer',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 19,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
              provider.needDownloadAgain
                  ? DownloadAgainWidget(
                      simulatorTestPresenter: null,
                      myTestPresenter: _presenter!,
                    )
                  : const SizedBox(),
            ],
          );
        }
      },
    );
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
            _onClickUpdateReAnswer(provider.reAnswerOfQuestions);
          },
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _onAppActive();
        break;
      case AppLifecycleState.paused:
        if (kDebugMode) {
          print('DEBUG: App paused');
        }
        break;
      case AppLifecycleState.inactive:
        _onAppInBackground();
        break;
      case AppLifecycleState.detached:
        if (kDebugMode) {
          print('DEBUG:App detached');
        }
        break;
    }
  }

  Future _onAppInBackground() async {
    //TODO
    // VideoPlayerController videoController =
    //     _simulatorTestProvider!.videoPlayController!;
    // if (videoController.value.isPlaying) {
    //   videoController.pause();
    //   _simulatorTestProvider!.setPlayController(videoController);
    // }

    if (widget.provider.visibleRecord) {
      _record.stop();
    }

    if (_player!.state == PlayerState.playing) {
      QuestionTopicModel q = widget.provider.currentQuestion;
      widget.provider.setPlayAnswer(false, q.id.toString());
      _stopAudio();
    }
  }

  Future _onAppActive() async {
    //TODO
    // VideoPlayerController videoController =
    //     _simulatorTestProvider!.videoPlayController!;
    // _simulatorTestProvider!.setPlayController(videoController);

    if (widget.provider.visibleRecord) {
      QuestionTopicModel currentQuestion = widget.provider.currentQuestion;

      //TODO
      // _initVideoController(
      //     fileName: currentQuestion.files.first.url,
      //     handleWhenFinishType: HandleWhenFinish.questionVideoType);

      widget.provider.setVisibleRecord(false);
      _record.stop();
      _player!.stop();
    } else {
      //TODO
      // if (_simulatorTestProvider!.doingStatus != DoingStatus.finish) {
      //   videoController.play();
      // }
    }
  }

  void _onClickUpdateReAnswer(List<QuestionTopicModel> requestions) {
    _loading!.show(context);
    ActivitiesModel homework = widget.homeWorkModel;
    _presenter!.updateMyAnswer(
        testId: homework.activityAnswer!.testId.toString(),
        activityId: homework.activityId.toString(),
        reQuestions: requestions);
  }

  void _onFinishReanswer(QuestionTopicModel question) {
    widget.provider.setReAnswerOfQuestions(question);
    int index = widget.provider.myAnswerOfQuestions
        .indexWhere((q) => q.id == question.id);
    widget.provider.myAnswerOfQuestions[index] = question;
    widget.provider.setAnswerOfQuestions(widget.provider.myAnswerOfQuestions);
    _onCancelReAnswer();
  }

  void _onCancelReAnswer() {
    widget.provider.setVisibleRecord(false);
    widget.provider.setTimerCount('00:00');
    widget.provider.countDownTimer!.cancel();
    widget.provider.setCountDownTimer(null);
    _record.stop();
  }

  _showAiResponse() {
    Provider.of<AuthProvider>(context, listen: false)
        .setShowDialogWithGlobalScaffoldKey(
            true, GlobalScaffoldKey.aiResponseScaffoldKey);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      barrierColor: AppColor.defaultGrayColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(CustomSize.size_20),
          topRight: Radius.circular(CustomSize.size_20),
        ),
      ),
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - CustomSize.size_20),
      builder: (_) {
        return FutureBuilder(
          future: aiResponseEP(
              widget.homeWorkModel.activityAnswer!.aiOrder.toString()),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return Scaffold(
                key: GlobalScaffoldKey.aiResponseScaffoldKey,
                body: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: CustomSize.size_10),
                      child: AiResponse(url: snapshot.data.toString()),
                    ),
                    Container(
                      margin: const EdgeInsets.all(CustomSize.size_10),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.cancel_outlined,
                          color: AppColor.defaultBlackColor,
                          size: CustomSize.size_25,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Container(
              height: CustomSize.size_400,
              color: Colors.white,
              child: const Center(
                child: Text(
                  'Nothing in here',
                  style: CustomTextStyle.textGrey_15,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _questionItem(QuestionTopicModel question) {
    return Consumer<MyTestProvider>(
      builder: (context, provider, child) {
        return Card(
          elevation: 2,
          child: LayoutBuilder(
            builder: (_, constraint) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: CustomSize.size_10,
                  vertical: CustomSize.size_10,
                ),
                margin: const EdgeInsets.only(top: CustomSize.size_10),
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
                              width: CustomSize.size_50,
                              height: CustomSize.size_50,
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
                              width: CustomSize.size_50,
                              height: CustomSize.size_50,
                            ),
                          ),
                    Container(
                      margin: const EdgeInsets.only(left: CustomSize.size_20),
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(0),
                            width: MediaQuery.of(context).size.width*0.7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  question.content.toString(),
                                  style: CustomTextStyle.textBlack_15,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: CustomSize.size_10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              (widget.homeWorkModel.canReanswer())
                                  ? InkWell(
                                      onTap: () async {
                                        _onClickReanswer(provider, question);
                                      },
                                      child: const Text(
                                        'Re-answer',
                                        style:
                                            CustomTextStyle.textBoldPurple_14,
                                      ),
                                    )
                                  : Container(),
                              const SizedBox(width: CustomSize.size_20),
                              InkWell(
                                onTap: () {
                                  _showTips(question);
                                },
                                child: (question.tips.isNotEmpty)
                                    ? const Text(
                                        'View Tips',
                                        style:
                                            CustomTextStyle.textBoldPurple_15,
                                      )
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
            },
          ),
        );
      },
    );
  }

  void _onClickReanswer(MyTestProvider provider, QuestionTopicModel question) {
    if (!provider.visibleRecord) {
      widget.provider.setCurrentQuestion(question);
      widget.provider.setVisibleRecord(true);
      _recordReAnswer(provider.visibleRecord, question);
    }
  }

  _showTips(QuestionTopicModel questionTopicModel) {
    Provider.of<AuthProvider>(context, listen: false)
        .setShowDialogWithGlobalScaffoldKey(
            true, GlobalScaffoldKey.showTipScaffoldKey);

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        enableDrag: false,
        barrierColor: AppColor.defaultGrayColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(CustomSize.size_20),
            topRight: Radius.circular(CustomSize.size_20),
          ),
        ),
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height - CustomSize.size_20),
        builder: (_) {
          return TipQuestionDialog.tipQuestionDialog(
              context, questionTopicModel);
        });
  }

  Future _recordReAnswer(
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
          // encoder: AudioEncoder.wav,
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

  @override
  void finishCountDown() {
    _onFinishReanswer(widget.provider.currentQuestion);
  }

  @override
  void onCountDown(String time) {
    widget.provider.setTimerCount(time);
  }

  @override
  void onDownloadSuccess(TestDetailModel testDetail, String nameFile,
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
        textColor: AppColor.defaultBlackColor,
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
        textColor: AppColor.defaultBlackColor,
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
    if (kDebugMode) {
      print("DEBUG: updateAnswerFail ${info.description.toString()}");
    }
    //AlertsDialog.init().showDialog(context, info, this);
    _loading!.hide();
    Fluttertoast.showToast(
        msg: info.description,
        backgroundColor: AppColor.defaultGrayColor,
        textColor: AppColor.defaultBlackColor,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void onReDownload() {
    if (kDebugMode) {
      print("DEBUG: TODO: implement onReDownload");
    }
    widget.provider.setDownloadingFile(false);
    widget.provider.setNeedDownloadAgain(true);
  }

  @override
  void onTryAgainToDownload() {
    //Check internet connection status
    if (isOffline) {
      _showCheckNetworkDialog();
    } else {
      if (null != _presenter!.testDetail && null != _presenter!.filesTopic) {
        updateStatusForReDownload();
        if (null == _presenter!.client) {
          _presenter!.initializeData();
        }
        _presenter!.reDownloadFiles();
      }
    }
  }

  void _showCheckNetworkDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: "Notify",
          description: "An error occur. Please check your connection!",
          okButtonTitle: "OK",
          cancelButtonTitle: null,
          borderRadius: 8,
          hasCloseButton: false,
          okButtonTapped: () {
            Navigator.of(context).pop();
          },
          cancelButtonTapped: null,
        );
      },
    );
  }

  void updateStatusForReDownload() {
    widget.provider.setNeedDownloadAgain(false);
    widget.provider.setDownloadingFile(true);
  }
}