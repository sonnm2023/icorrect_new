import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/core/connectivity_service.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/presenters/my_test_presenter.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/provider/my_test_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/alert_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/confirm_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/custom_alert_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/tip_question_dialog.dart';
import 'package:icorrect/src/views/screen/test/my_test/download_progressing_widget.dart';
import 'package:icorrect/src/views/screen/test/my_test/test_record_widget.dart';
import 'package:icorrect/src/views/widget/download_again_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';

class MyTestTab extends StatefulWidget {
  final ActivitiesModel? homeWorkModel;
  final String? practiceTestId;
  final MyTestProvider provider;

  const MyTestTab(
      {super.key,
      this.homeWorkModel,
      this.practiceTestId,
      required this.provider});

  @override
  State<MyTestTab> createState() => _MyTestTabState();
}

class _MyTestTabState extends State<MyTestTab>
    with AutomaticKeepAliveClientMixin<MyTestTab>, WidgetsBindingObserver
    implements MyTestContract, ActionAlertListener {
  double w = 0, h = 0;
  MyTestPresenter? _presenter;
  CircleLoading? _loading;

  AudioPlayer? _player;
  final Record _record = Record();
  bool isOffline = false;
  StreamSubscription? connection;
  String audioFile = "";
  Timer? timer;
  final connectivityService = ConnectivityService();

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
    _loading!.show(context: context, isViewAIResponse: true);

    _prepareDataForMyTestDetail();
  }

  void _prepareDataForMyTestDetail() async {
    final status = await Permission.microphone.status;
    await _presenter!.initializeData();

    String activityId = "";
    String testId = widget.practiceTestId ?? "";
    if (widget.homeWorkModel != null) {
      activityId = widget.homeWorkModel!.activityId.toString();
      testId = widget.homeWorkModel!.activityAnswer!.testId.toString();
    }

    _presenter!.getMyTest(
      context: context,
      activityId: activityId,
      testId: testId,
    );

    Future.delayed(Duration.zero, () {
      widget.provider.clearData();
      widget.provider.setPermissionRecord(status);
      widget.provider.setDownloadingFile(true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player!.dispose();
    _record.dispose();
    _presenter!.closeClientRequest();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildMyTest();
  }

  Widget _buildMyTest() {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Consumer<MyTestProvider>(
      builder: (context, provider, child) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            (provider.isDownloading)
                ? const DownloadProgressingWidget()
                : Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        color: AppColor.defaultGraySlightColor,
                        height: h,
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(top: 10, bottom: 70),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: provider.myAnswerOfQuestions.length,
                          itemBuilder: (context, index) {
                            return _questionItem(
                                provider.myAnswerOfQuestions[index]);
                          },
                        ),
                      ),
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
                          ? LayoutBuilder(
                              builder: (_, constraint) {
                                return InkWell(
                                  onTap: () {
                                    _showDialogConfirmSaveChange(
                                        provider: provider);
                                  },
                                  child: Container(
                                    height: 50,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: CustomSize.size_10,
                                    ),
                                    color: AppColor.defaultPurpleColor,
                                    width: constraint.maxWidth,
                                    child: Center(
                                      child: Text(
                                        Utils.multiLanguage(StringConstants
                                            .update_answer_button_title),
                                        style:
                                            CustomTextStyle.textWithCustomInfo(
                                          context: context,
                                          color: AppColor.defaultAppColor,
                                          fontsSize: FontsSize.fontSize_16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(),
                      provider.needDownloadAgain
                          ? const DownloadAgainWidget(
                              simulatorTestPresenter: null,
                              myTestPresenter: null,
                            )
                          : const SizedBox(),
                    ],
                  ),
            (widget.homeWorkModel != null) ? _aiResponseButton() : Container()
          ],
        );
      },
    );
  }

  Widget _aiResponseButton() {
    return (Utils.haveAiResponse(widget.homeWorkModel!).isNotEmpty)
        ? LayoutBuilder(
            builder: (_, constraint) {
              return InkWell(
                onTap: () async {
                  String aiResponseLink = await aiResponseEP(
                      widget.homeWorkModel!.activityAnswer!.aiOrder.toString());
                  Uri toLaunch = Uri.parse(aiResponseLink);

                  await launchUrl(toLaunch);
                },
                child: Container(
                  height: 51,
                  padding: const EdgeInsets.symmetric(
                    vertical: CustomSize.size_10,
                  ),
                  color: Colors.green,
                  width: constraint.maxWidth,
                  child: Center(
                    child: Text(
                      Utils.multiLanguage(
                          StringConstants.view_ai_response_button_title),
                      style: CustomTextStyle.textWithCustomInfo(
                        context: context,
                        color: AppColor.defaultAppColor,
                        fontsSize: FontsSize.fontSize_16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        : Container();
  }

  void _showDialogConfirmSaveChange({required MyTestProvider provider}) {
    showDialog(
      context: context,
      builder: (builder) {
        return ConfirmDialogWidget(
          title: Utils.multiLanguage(StringConstants.confirm_title),
          message: Utils.multiLanguage(
              StringConstants.confirm_save_change_answers_message),
          cancelButtonTitle:
              Utils.multiLanguage(StringConstants.cancel_button_title),
          okButtonTitle: Utils.multiLanguage(StringConstants.save_button_title),
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
      case AppLifecycleState.hidden:
        if (kDebugMode) {
          print('DEBUG:App hidden');
        }
        break;
    }
  }

  Future _onAppInBackground() async {
    if (widget.provider.visibleRecord) {
      _record.stop();
      _stopCountTimer();

      String path =
          '${await FileStorageHelper.getFolderPath(MediaType.audio, null)}'
          '\\$audioFile';
      if (File(path).existsSync()) {
        await File(path).delete();
        if (kDebugMode) {
          print("DEBUG: File Record is delete: ${File(path).existsSync()}");
        }
      }
    }

    if (_player!.state == PlayerState.playing) {
      QuestionTopicModel q = widget.provider.currentQuestion;
      widget.provider.setPlayAnswer(Status.playOff.get, q.id);
      _stopAudio();
    }
  }

  Future _onAppActive() async {
    if (widget.provider.visibleRecord) {
      _recordReAnswer();
    }
  }

  void _onClickUpdateReAnswer(List<QuestionTopicModel> requestions) {
    _loading!.show(context: context, isViewAIResponse: false);

    String activityId = "";
    String testId = widget.practiceTestId ?? "";
    if (widget.homeWorkModel != null) {
      activityId = widget.homeWorkModel!.activityId.toString();
      testId = widget.homeWorkModel!.activityAnswer!.testId.toString();
    }

    _presenter!.updateMyAnswer(
      context: context,
      testId: testId,
      activityId: activityId,
      reQuestions: requestions,
    );
  }

  void _onFinishReanswer(QuestionTopicModel question) {
    //Check answer of user must be greater than 2 seconds
    if (_checkAnswerDuration()) {
      return;
    }

    widget.provider.setReAnswerOfQuestions(question);
    int index = widget.provider.myAnswerOfQuestions.indexWhere(
        (q) => q.id == question.id && q.repeatIndex == question.repeatIndex);
    widget.provider.myAnswerOfQuestions[index] = question;
    widget.provider.setAnswerOfQuestions(widget.provider.myAnswerOfQuestions);
    if (audioFile.isNotEmpty) {
      if (question.answers.isNotEmpty) {
        question.answers[question.repeatIndex].url = audioFile;
      } else {
        FileTopicModel fileTopicModel = FileTopicModel();
        fileTopicModel.url = audioFile;
        question.answers.add(fileTopicModel);
      }
      if (_isLastAnswer(question)) {
        question.reAnswerCount++;
      }
      widget.provider.setCurrentQuestion(question);
    }
    _resetReanswerData();
  }

  Future<void> _onCancelReanswer() async {
    String path =
        '${await FileStorageHelper.getFolderPath(MediaType.audio, null)}'
        '\\$audioFile';
    if (File(path).existsSync()) {
      await File(path).delete();
      if (kDebugMode) {
        print("DEBUG: File Record is delete: ${File(path).existsSync()}");
      }
    }
    _resetReanswerData();
  }

  void _resetReanswerData() {
    widget.provider.setVisibleRecord(false);
    widget.provider.setTimerCount('00:00');
    _stopCountTimer();
    widget.provider.setCountDownTimer(null);
    _record.stop();
  }

  Widget _questionItem(QuestionTopicModel question) {
    return Consumer<MyTestProvider>(
      builder: (context, provider, child) {
        return Container(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: LayoutBuilder(
            builder: (_, constraint) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: CustomSize.size_10,
                  vertical: CustomSize.size_10,
                ),
                margin: const EdgeInsets.only(
                  top: CustomSize.size_10,
                ),
                width: constraint.maxWidth,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    (_isAudioPlay(question.repeatIndex, question.id))
                        ? InkWell(
                            onTap: () async {
                              widget.provider.setPlayAnswer(
                                  Status.playOff.get, question.id);
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
                              widget.provider.setPlayAnswer(
                                  question.repeatIndex, question.id);

                              if (question.answers.isNotEmpty) {
                                _prepareToPlayAudio(
                                    fileName: Utils.convertFileName(question
                                        .answers[question.repeatIndex].url
                                        .toString()),
                                    questionId: question.id);
                              }
                            },
                            child: const Image(
                              image: AssetImage(AppAsset.stop),
                              width: CustomSize.size_50,
                              height: CustomSize.size_50,
                            ),
                          ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                          left: CustomSize.size_20,
                        ),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question.content.toString(),
                              style: CustomTextStyle.textWithCustomInfo(
                                context: context,
                                color: AppColor.defaultBlackColor,
                                fontsSize: FontsSize.fontSize_15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            (question.cueCard.isNotEmpty)
                                ? Text(
                                    question.cueCard.toString(),
                                    style: CustomTextStyle.textWithCustomInfo(
                                      context: context,
                                      color: AppColor.defaultBlackColor,
                                      fontsSize: FontsSize.fontSize_15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )
                                : Container(),
                            const SizedBox(
                              height: CustomSize.size_10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _canReanswerQuestion()
                                    ? InkWell(
                                        onTap: () async {
                                          _onClickReanswer(provider, question);
                                        },
                                        child: Text(
                                          Utils.multiLanguage(StringConstants
                                              .re_answer_button_title),
                                          style: CustomTextStyle
                                              .textWithCustomInfo(
                                            context: context,
                                            color: AppColor.defaultPurpleColor,
                                            fontsSize: FontsSize.fontSize_14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    : Container(),
                                const SizedBox(
                                  width: CustomSize.size_20,
                                ),
                                InkWell(
                                  onTap: () {
                                    _showTips(question);
                                  },
                                  child: (question.tips.isNotEmpty)
                                      ? Text(
                                          Utils.multiLanguage(StringConstants
                                              .view_tips_button_title),
                                          style: CustomTextStyle
                                              .textWithCustomInfo(
                                            context: context,
                                            color: AppColor.defaultPurpleColor,
                                            fontsSize: FontsSize.fontSize_14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      : Container(),
                                ),
                              ],
                            )
                          ],
                        ),
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

  bool _canReanswerQuestion() {
    if (widget.practiceTestId != null) {
      return true;
    }
    if (widget.homeWorkModel != null) {
      return widget.homeWorkModel!.canReanswer();
    }
    return false;
  }

  bool _isAudioPlay(int repeatIndex, int questionId) {
    return widget.provider.indexAudio == repeatIndex &&
        questionId == widget.provider.questionId;
  }

  void _onClickReanswer(MyTestProvider provider, QuestionTopicModel question) {
    widget.provider.setPlayAnswer(Status.playOff.get, question.id);
    _stopAudio();
    if (!provider.visibleRecord) {
      widget.provider.setCurrentQuestion(question);
      _recordReAnswer();
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

  Future _recordReAnswer() async {
    if (widget.provider.recordPermission.isGranted) {
      _stopCountTimer();
      widget.provider.setVisibleRecord(true);
      widget.provider.setIsLessThan2Second(true);
      if (widget.provider.visibleRecord) {
        audioFile = '${await Utils.generateAudioFileName()}.wav';

        timer = _presenter!.startCountDown(
            context: context, count: 30, isLessThan2Seconds: true);
        widget.provider.setCountDownTimer(timer);
        await _record.start(
          path:
              '${await FileStorageHelper.getFolderPath(MediaType.audio, null)}'
              '\\$audioFile',
          encoder:
              Platform.isAndroid ? AudioEncoder.wav : AudioEncoder.pcm16bit,
          bitRate: 128000,
          samplingRate: 44100,
        );
      }
    } else {
      final status = await Permission.microphone.request();
      widget.provider.setPermissionRecord(status);
      _record.stop();
    }
  }

  void _stopCountTimer() {
    widget.provider.setTimerCount("00:30");
    if (timer != null) {
      timer!.cancel();
    }
    if (widget.provider.countDownTimer != null) {
      widget.provider.countDownTimer!.cancel();
    }
  }

  bool _isLastAnswer(QuestionTopicModel question) {
    return question.answers[question.repeatIndex].url ==
        question.answers.last.url;
  }

  Future _prepareToPlayAudio(
      {required String fileName, required int questionId}) async {
    Utils.prepareAudioFile(fileName, null).then((value) {
      if (kDebugMode) {
        print('DEBUG: _playAudio:${value.path.toString()}');
      }
      _playAudio(value.path.toString(), questionId);
    });
  }

  Future<void> _playAudio(String audioPath, int questionId) async {
    try {
      await _player!.play(DeviceFileSource(audioPath));
      await _player!.setVolume(2.5);
      _player!.onPlayerComplete.listen((event) {
        widget.provider.setPlayAnswer(Status.playOff.get, questionId);
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

  void _showCheckNetworkDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: Utils.multiLanguage(StringConstants.dialog_title),
          description:
              Utils.multiLanguage(StringConstants.network_error_message),
          okButtonTitle: Utils.multiLanguage(StringConstants.ok_button_title),
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

  bool _checkAnswerDuration() {
    if (widget.provider.isLessThan2Second) {
      Fluttertoast.showToast(
        msg: Utils.multiLanguage(
            StringConstants.answer_must_be_greater_than_2_seconds_message),
        backgroundColor: Colors.blueGrey,
        textColor: Colors.white,
        gravity: ToastGravity.CENTER,
        fontSize: 15,
        toastLength: Toast.LENGTH_LONG,
      );
      return true;
    }
    return false;
  }

  @override
  void finishCountDown() {
    _onFinishReanswer(widget.provider.currentQuestion);
  }

  @override
  void onCountDown(String time, bool isLessThan2Second) {
    widget.provider.setTimerCount(time);
    widget.provider.setIsLessThan2Second(isLessThan2Second);
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
      gravity: ToastGravity.CENTER,
    );
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
        gravity: ToastGravity.CENTER);
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
        gravity: ToastGravity.CENTER,
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
      gravity: ToastGravity.CENTER,
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void onReDownload() {
    if (kDebugMode) {
      print("DEBUG: TODO: implement onReDownload");
    }
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
        if (null == _presenter!.dio) {
          _presenter!.initializeData();
        }

        String activityId = "";
        if (widget.homeWorkModel != null) {
          activityId = widget.homeWorkModel!.activityId.toString();
        }
        _presenter!.reDownloadFiles(context, activityId);
      }
    }
  }

  void updateStatusForReDownload() {
    widget.provider.setNeedDownloadAgain(false);
  }
}
