import 'dart:async';
import 'dart:collection';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/homework_model.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/presenters/test_presenter.dart';
import 'package:icorrect/src/provider/play_answer_provider.dart';
import 'package:icorrect/src/provider/prepare_test_provider.dart';
import 'package:icorrect/src/provider/record_provider.dart';
import 'package:icorrect/src/provider/test_provider.dart';
import 'package:icorrect/src/provider/timer_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/alert_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/confirm_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/re_answer_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/tip_question_dialog.dart';
import 'package:icorrect/src/views/screen/test/simulator_test_new/back_button_widget.dart';
import 'package:icorrect/src/views/widget/default_loading_indicator.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/download_progressing_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/start_now_button_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/test_room_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';

class SimulatorTestScreen extends StatefulWidget {
  const SimulatorTestScreen({super.key, required this.homeWorkModel});

  final HomeWorkModel homeWorkModel;

  @override
  State<SimulatorTestScreen> createState() => _SimulatorTestScreenState();
}

class _SimulatorTestScreenState extends State<SimulatorTestScreen>
    with WidgetsBindingObserver
    implements TestViewContract, ActionAlertListener {
  TestPresenter? _testPresenter;

  TestProvider? _testProvider;
  PrepareTestProvider? _prepareTestProvider;
  RecordProvider? _recordProvider;
  TimerProvider? _timerProvider;
  PlayAnswerProvider? _playAnswerProvider;

  Permission? _microPermission;
  PermissionStatus _microPermissionStatus = PermissionStatus.denied;

  VideoPlayerController? _videoPlayerController;
  final AudioPlayer _audioPlayerController = AudioPlayer();
  final Record _recordController = Record();

  Timer? _countDown;
  QuestionTopicModel? _currentQuestion;
  int _countRepeat = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    _testProvider = Provider.of<TestProvider>(context, listen: false);
    _prepareTestProvider =
        Provider.of<PrepareTestProvider>(context, listen: false);
    _recordProvider = Provider.of<RecordProvider>(context, listen: false);
    _timerProvider = Provider.of<TimerProvider>(context, listen: false);
    _playAnswerProvider =
        Provider.of<PlayAnswerProvider>(context, listen: false);

    _testPresenter = TestPresenter(this);
    _getTestDetail();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _recordController.dispose();

    if (_audioPlayerController.state == PlayerState.playing) {
      _audioPlayerController.stop();
    }

    _audioPlayerController.dispose();
    if (null != _videoPlayerController) {
      if (_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.pause();
      }

      _videoPlayerController!.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SafeArea(
            left: true,
            top: true,
            right: true,
            bottom: true,
            child: Stack(
              children: [
                _buildBody(),
                BackButtonWidget(backButtonTapped: _backButtonTapped),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _backButtonTapped() {
    if (_testProvider!.isShowPlayVideoButton) {
      Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmDialogWidget(
            title: "Notification",
            message: "The test is not completed! Are you sure to quit?",
            cancelButtonTitle: "Cancel",
            okButtonTitle: "OK",
            cancelButtonTapped: _cancelButtonTapped,
            okButtonTapped: _okButtonTapped,
          );
        },
      );
    }
  }

  void _cancelButtonTapped() {
    if (kDebugMode) print("_cancelButtonTapped");
  }

  void _okButtonTapped() {
    _recordController.stop();

    if (null != _testProvider!.playController) {
      _testProvider!.playController!.pause();
    }

    _playAnswerProvider!.resetAll();
    _timerProvider!.resetAll();
    _recordProvider!.resetAll();
    _prepareTestProvider!.resetAll();
    _testProvider!.resetAll();

    Navigator.of(context).pop();
  }

  Widget _buildBody() {
    return Consumer<PrepareTestProvider>(
      builder: (context, prepareTestProvider, child) {
        if (prepareTestProvider.isProcessing) {
          return const DefaultLoadingIndicator(
            color: AppColor.defaultPurpleColor,
          );
        }

        if (prepareTestProvider.isDownloading) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const DownloadProgressingWidget(),
              Visibility(
                visible: prepareTestProvider.canStartNow,
                child: StartNowButtonWidget(startNowButtonTapped: () {
                  _checkPermission();
                }),
              ),
            ],
          );
        }

        return TestRoomWidget(
          testPresenter: _testPresenter!,
          testProvider: _testProvider!,
          playVideoCallBack: _playVideo,
          finishAnswerCallBack: _finishAnswerCallBack,
          repeatQuestionCallBack: _repeatQuestionCallBack,
          playAnswerCallBack: _playAnswerCallBack,
          playReAnswerCallBack: _playReAnswerCallBack,
          showTipCallBack: _showTipCallBack,
        );
      },
    );
  }

  void _playAnswerCallBack(
      QuestionTopicModel question, int selectedQuestionIndex) async {
    if (_testProvider!.isShowPlayVideoButton) {
      //Check playing answers status
      if (-1 != _playAnswerProvider!.selectedQuestionIndex) {
        //Stop playing current question
        _audioPlayerController.stop();
        if (selectedQuestionIndex !=
            _playAnswerProvider!.selectedQuestionIndex) {
          //Update UI of play answer button
          _playAnswerProvider!.setSelectedQuestionIndex(selectedQuestionIndex);

          //Play selected question
          String path = await FileStorageHelper.getFilePath(question.answers.first.url, MediaType.audio);
          _playAudio(path, question.id.toString());
        } else {
          _playAnswerProvider!.resetSelectedQuestionIndex();
        }
      } else {
        _playAnswerProvider!.setSelectedQuestionIndex(selectedQuestionIndex);

        String path = await FileStorageHelper.getFilePath(question.answers.first.url, MediaType.audio);
        _playAudio(path, question.id.toString());
      }
    } else {
      showToastMsg(
        msg: "Please wait until the test is finished!",
        toastState: ToastStatesType.warning,
      );
    }
  }

  Future<void> _playAudio(String audioPath, String questionId) async {
    try {
      await _audioPlayerController.play(DeviceFileSource(audioPath));
      await _audioPlayerController.setVolume(2.5);
      _audioPlayerController.onPlayerComplete.listen((event) {
        if (kDebugMode) {
          print("Play audio complete");
        }
        _playAnswerProvider!.resetSelectedQuestionIndex();
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void _showReAnswerDialog(QuestionTopicModel question) {
    Future.delayed(Duration.zero, () async {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ReAnswerDialog(
            context,
            question,
            _testPresenter!,
          );
        },
      );
    });
  }

  void _playReAnswerCallBack(QuestionTopicModel question) {
    if (_testProvider!.isShowPlayVideoButton) {
      //TODO: Check reviewing process
      bool isReviewing = true;
      if (isReviewing) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ConfirmDialogWidget(
              title: "Notification",
              message:
                  "You are going to re-answer this question.The reviewing process will be stopped. Are you sure?",
              cancelButtonTitle: "Cancel",
              okButtonTitle: "OK",
              cancelButtonTapped: _cancelButtonTapped,
              okButtonTapped: () {
                //TODO: Pause reviewing process

                //Show re-answer dialog
                _showReAnswerDialog(question);
              },
            );
          },
        );
      } else {
        if (_audioPlayerController.state == PlayerState.playing) {
          _audioPlayerController.stop();
          _playAnswerProvider!.resetSelectedQuestionIndex();
        }

        _showReAnswerDialog(question);
      }
    } else {
      showToastMsg(
        msg: "Please wait until the test is finished!",
        toastState: ToastStatesType.warning,
      );
    }
  }

  void _showTipCallBack(QuestionTopicModel question) {
    if (_testProvider!.isShowPlayVideoButton) {
      Future.delayed(
        Duration.zero,
        () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return TipQuestionDialog.tipQuestionDialog(
                context,
                question,
              );
            },
          );
        },
      );
    } else {
      showToastMsg(
        msg: "Please wait until the test is finished!",
        toastState: ToastStatesType.warning,
      );
    }
  }

  void _finishAnswerCallBack(QuestionTopicModel questionTopicModel) {
    bool isPart2 =
        _testProvider!.topicsQueue.first.numPart == PartOfTest.part2.get;
    onFinishAnswer(isPart2);
  }

  void _repeatQuestionCallBack(QuestionTopicModel questionTopicModel) async {
    _countRepeat++;

    //Add question into List Question & show it
    _testProvider!.addCurrentQuestionIntoList(questionTopic: _currentQuestion!, repeatIndex: _countRepeat);

    TopicModel? topicModel = _getCurrentPart();
    if (null != topicModel) {
      if (topicModel.numPart == PartOfTest.part3.get) {
        bool finishFollowUp = _testProvider!.finishPlayFollowUp;
        if (finishFollowUp == true) {
          if (_countRepeat > 0 && _countRepeat <= 2) {
            _repeatPlayCurrentQuestion();
          } else {
            _playNextQuestion();
          }
        } else {
          if (_countRepeat > 0 && _countRepeat <= 2) {
            _repeatPlayCurrentFollowup();
          } else {
            _playNextFollowup();
          }
        }
      } else {
        if (_countRepeat > 0 && _countRepeat <= 2) {
          _repeatPlayCurrentQuestion();
        } else {
          _playNextQuestion();
        }
      }
    } else {
      if (kDebugMode) print("onFinishAnswer: ERROR-Current Part is NULL!");
    }
  }

  void _playVideo() {
    if (null != _testProvider!.playController) {
      _testProvider!.playController!.play();
    }
  }

  void _checkPermission() async {
    if (_microPermission == null) {
      await _initializePermission();
    }

    if (mounted) {
      _requestPermission(_microPermission!, context);
    }
  }

  Future<void> _requestPermission(
      Permission permission, BuildContext context) async {
    _testProvider!.setPermissionDeniedTime();
    // ignore: unused_local_variable
    final status = await permission.request();
    _listenForPermissionStatus(context);
  }

  Future<void> _initializePermission() async {
    _microPermission = Permission.microphone;
  }

  void _listenForPermissionStatus(BuildContext context) async {
    if (_microPermission != null) {
      _microPermissionStatus = await _microPermission!.status;

      if (_microPermissionStatus == PermissionStatus.denied) {
        if (_testProvider!.permissionDeniedTime > 2) {
          _showConfirmDialog();
        }
      } else if (_microPermissionStatus == PermissionStatus.permanentlyDenied) {
        openAppSettings();
      } else {
        _startToDoTest();
      }
    }
  }

  void _showConfirmDialog() {
    if (false == _testProvider!.dialogShowing) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertsDialog.init().showDialog(
              context,
              AlertClass.microPermissionAlert,
              this,
              keyInfo: StringClass.permissionDenied,
            );
          });
      _testProvider!.setDialogShowing(true);
    }
  }

  void _getTestDetail() {
    _testPresenter!.getTestDetail(widget.homeWorkModel.id.toString());

    Future.delayed(Duration.zero, () {
      _prepareTestProvider!.updateProcessingStatus();
    });
  }

  void _videoFileEmpty() {
    if (!_testProvider!.dialogShowing) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertsDialog.init().showDialog(
              context,
              AlertClass.videoPathIncorrectAlert,
              this,
              keyInfo: StringClass.videoPathError,
            );
          });
      _testProvider!.setDialogShowing(true);
    }
  }

  Future<void> _startToPlayFollowup({required bool needResetAnswerList}) async {
    if (needResetAnswerList) {
      // _answers.clear();//TODO
    }

    //Reset countdown
    _countDown!.cancel();

    TopicModel? topicModel = _getCurrentPart();

    if (null == topicModel) {
      if (kDebugMode) {
        print("Hasn't any part to playing");
      }
      return;
    }

    List<QuestionTopicModel> followUpList = topicModel.followUp;

    if (followUpList.isEmpty) {
      if (kDebugMode) {
        print("This part hasn't any followup to playing");
      }
      _testProvider!.setFinishPlayFollowUp(true);
      _startToPlayQuestion(needResetAnswerList: true);
    } else {
      _testProvider!.resetIndexOfCurrentQuestion();

      int index = _testProvider!.indexOfCurrentFollowUp;
      if (index >= followUpList.length) {
        _testProvider!.setFinishPlayFollowUp(true);
        _startToPlayQuestion(needResetAnswerList: true);
      } else {
        QuestionTopicModel question = followUpList.elementAt(index);
        question.numPart = topicModel.numPart;
        _currentQuestion = question;

        if (question.files!.isEmpty) {
          if (kDebugMode) {
            print("This is DATA ERROR");
          }
        } else {
          FileTopicModel file = question.files!.first;

          //Start initialize video
          _initVideoController(
            fileName: file.url,
            handleWhenFinishType: HandleWhenFinish.followupVideoType,
          );
        }
      }
    }
  }

  TopicModel? _getCurrentPart() {
    Queue<TopicModel> topicsQueue = _testProvider!.topicsQueue;

    if (topicsQueue.isEmpty) {
      return null;
    }

    //Get current part:
    //introduce / part 1 / part 2 / part 3 is testing
    TopicModel topicModel = topicsQueue.first;
    return topicModel;
  }

  Future<void> _startToPlayQuestion({required bool needResetAnswerList}) async {
    if (needResetAnswerList) {
      // _answers.clear();//TODO
    }

    TopicModel? topicModel = _getCurrentPart();

    if (null == topicModel) {
      if (kDebugMode) {
        print("Hasn't any part to playing");
      }
      return;
    }

    List<QuestionTopicModel> questionList = topicModel.questionList;
    if (questionList.isEmpty) {
      if (kDebugMode) {
        print("This part hasn't any question to playing");
      }
      //TODO: part introduce and part 1
      //_gotoNextPart()

      //TODO: part 2
      //_playEndOfTakeNote()

      //TODO: part 3
      _testPresenter!.playEndOfTestFile(topicModel);
    } else {
      int index = _testProvider!.indexOfCurrentQuestion;
      if (index >= questionList.length) {
        //TODO: We played all questions of current part
        //TODO: _playNextPart
        //If current part is part 3 ==> to play end_of_test
        if (topicModel.numPart == PartOfTest.part3.get) {
          _testPresenter!.playEndOfTestFile(topicModel);
        } else {
          _playNextPart();
        }
      } else {
        QuestionTopicModel question = questionList.elementAt(index);
        question.numPart = topicModel.numPart;
        _currentQuestion = question;

        if (question.files.isEmpty) {
          if (kDebugMode) {
            print("This is DATA ERROR");
          }
        } else {
          FileTopicModel file = question.files.first;

          //Start initialize video
          _initVideoController(
            fileName: file.url,
            handleWhenFinishType: HandleWhenFinish.questionVideoType,
          );
        }
      }
    }
  }

  void _playNextPart() {
    //Remove part which played
    _testProvider!.removeTopicsQueueFirst();
    _testProvider!.resetIndexOfCurrentQuestion();

    //TODO: No part for next play
    //Finish the test
    if (_testProvider!.topicsQueue.isEmpty) {
      if (kDebugMode) {
        print("_playNextPart: No part for next play");
      }
    }

    _testPresenter!.startPart(_testProvider!.topicsQueue);
  }

  void _setIndexOfNextQuestion() {
    int i = _testProvider!.indexOfCurrentQuestion;
    _testProvider!.setIndexOfCurrentQuestion(i + 1);
  }

  void _setIndexOfNextFollowUp() {
    int i = _testProvider!.indexOfCurrentFollowUp;
    _testProvider!.setIndexOfCurrentFollowUp(i + 1);
  }

  void _playNextFollowup() {
    //Reset countdown
    _countDown!.cancel();

    _setIndexOfNextFollowUp();
    _startToPlayFollowup(needResetAnswerList: true);
  }

  void _repeatPlayCurrentFollowup() {
    if (_countRepeat == 2) {
      //Disable repeat button
      _recordProvider!.setEnableRepeatButton(false);
    }
    //Reset countdown
    _countDown!.cancel();

    _startToPlayFollowup(needResetAnswerList: false);
  }

  void _repeatPlayCurrentQuestion() {
    if (_countRepeat == 2) {
      //Disable repeat button
      _recordProvider!.setEnableRepeatButton(false);
    }
    //Reset countdown
    _countDown!.cancel();

    _startToPlayQuestion(needResetAnswerList: false);
  }

  void _playNextQuestion() {
    //Reset countdown
    _countDown!.cancel();

    _setIndexOfNextQuestion();
    _startToPlayQuestion(needResetAnswerList: true);
  }

  Future<void> _initVideoController({
    required String fileName,
    required HandleWhenFinish handleWhenFinishType,
  }) async {
    _setVisibleRecord(false, null, null);
    _testProvider!.setIsLoadingVideo(true);

    Utils.prepareVideoFile(fileName).then((value) {
      //Deallocate player memory
      if (null != _videoPlayerController) {
        _videoPlayerController!.dispose();
        _testProvider!.setPlayController(null);
      }

      //Initialize new player for new video
      _videoPlayerController = VideoPlayerController.file(value)
        ..addListener(() => _checkVideo(fileName, handleWhenFinishType))
        ..initialize().then((value) {
          _testProvider!.setIsLoadingVideo(false);
          _videoPlayerController!.setLooping(false);
          if (_countRepeat != 0) {
            _videoPlayerController!.setPlaybackSpeed(0.9);
          }
          _videoPlayerController!.play();

          if (null != _videoPlayerController) {
            _testProvider!.setPlayController(_videoPlayerController!);
          }

          if (true == _testProvider!.isShowPlayVideoButton) {
            Future.delayed(const Duration(milliseconds: 1), () {
              _videoPlayerController!.pause();
            });
          }
        });
    });
  }

  void _calculateIndexOfHeader() {
    TopicModel? topicModel = _getCurrentPart();
    if (null != topicModel) {
      //Header of Part 2
      if (topicModel.numPart == PartOfTest.part2.get) {
        if (_testProvider!.indexOfCurrentQuestion == 0) {
          _testProvider!
              .setIndexOfHeaderPart2(_testProvider!.questionList.length);
        }
      }

      //Header of Part 3
      if (topicModel.numPart == PartOfTest.part3.get) {
        if (topicModel.followUp.isNotEmpty) {
          if (_testProvider!.indexOfCurrentFollowUp == 0) {
            _testProvider!
                .setIndexOfHeaderPart3(_testProvider!.questionList.length);
          }
        } else {
          if (_testProvider!.indexOfCurrentQuestion == 0) {
            _testProvider!
                .setIndexOfHeaderPart3(_testProvider!.questionList.length);
          }
        }
      }
    }
  }

  void _startRecordAnswer(
      {required String fileName, required bool isPart2}) async {
    TopicModel? topicModel = _getCurrentPart();

    if (null == topicModel) {
      if (kDebugMode) {
        print("_startRecordAnswer: ERROR");
      }
      return;
    }

    Queue<TopicModel> queue = _testProvider!.topicsQueue;
    int timeRecord = Utils.getRecordTime(queue.first.numPart);

    String timeString = Utils.getTimeRecordString(timeRecord);

    //Record the answer
    _timerProvider!.setCountDown(timeString);

    _countDown = _testPresenter!.startCountDown(context, timeRecord, isPart2);
    _setVisibleRecord(true, _countDown, fileName);
  }

  void _setVisibleRecord(bool visible, Timer? count, String? fileName) {
    _recordProvider!.setVisibleRecord(visible);

    if (_recordProvider!.visibleRecord) {
      _recordAnswer(fileName!);
    } else {
      _recordController.stop();
    }
    _testProvider!.setCountDownTimer(count);
  }

  Future<void> _recordAnswer(String fileName) async {
    if (kDebugMode) {
      print("RECORD AS FILE PATH: $fileName");
    }

    String newFileName = await _createLocalAudioFileName(fileName);
    String folderPath = await FileStorageHelper.getFolderPath(MediaType.audio);
    String path = "$folderPath\\$newFileName";

    if (await _recordController.hasPermission()) {
      await _recordController.start(
        path: path,
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        samplingRate: 44100,
      );
    }

    List<FileTopicModel> temp = _currentQuestion!.answers;
    temp.add(FileTopicModel.fromJson({'id': 0, 'url': newFileName, 'type': 0}));
    _currentQuestion!.answers = temp;
    _testProvider!.setCurrentQuestion(_currentQuestion!);
    if (kDebugMode) print("Save audio path: $path");
  }

  Future<String> _createLocalAudioFileName(String origin) async {
    String fileName = "";
    if (_countRepeat > 0) {
      fileName = 'repeat_${_countRepeat.toString()}_$origin';
    } else {
      fileName = 'answer_$origin';
    }
    return fileName;
  }

  //TODO
  void _setSaveTheTest() {
    _countDown != null ? _countDown!.cancel() : '';
    _setVisibleSaveTest(true);
    _setVisibleCueCard(false, null);
    _setVisibleRecord(false, null, null);
  }

  void _setVisibleSaveTest(bool isVisible) {
    _testProvider!.setVisibleSaveTheTest(isVisible);
  }

  void _setVisibleCueCard(bool visible, Timer? count) {
    _testProvider!.setVisibleCueCard(visible, timer: count);
  }

  void _startToDoTest() {
    //Hide StartNow button
    _prepareTestProvider!.setStartNowButtonStatus(false);

    //Hide Loading view
    _prepareTestProvider!.setDownloadingStatus(false);

    //Reset Play Video Button status
    _testProvider!.setIsShowPlayVideoButton(true);

    _testPresenter!.startPart(_testProvider!.topicsQueue);
  }

  void _checkVideo(String fileName, HandleWhenFinish handleWhenFinishType) {
    if (null != _testProvider!.playController) {
      if (_testProvider!.playController!.value.position ==
          _testProvider!.playController!.value.duration) {
        switch (handleWhenFinishType) {
          case HandleWhenFinish.questionVideoType:
            {
              // if (_testProvider!.currentQuestion.cueCard.isNotEmpty &&
              if (_currentQuestion!.cueCard.trim().isNotEmpty &&
                  (false == _testProvider!.isVisibleCueCard)) {
                //Has Cue Card case
                _recordProvider!.setVisibleRecord(false);
                _setVisibleCueCard(true, null);
                _countDown = _testPresenter!.startCountDown(context, 10, false); //For test 10, product 60
              } else {
                //Normal case
                if (false == _recordProvider!.visibleRecord &&
                    false == _testProvider!.isVisibleCueCard) {
                  _startRecordAnswer(fileName: fileName, isPart2: false);
                }
              }

              _calculateIndexOfHeader();

              break;
            }
          case HandleWhenFinish.introVideoType:
            {
              TopicModel? topicModel = _getCurrentPart();
              if (null != topicModel) {
                if (topicModel.numPart == PartOfTest.part3.get) {
                  _startToPlayFollowup(needResetAnswerList: true);
                } else {
                  _startToPlayQuestion(needResetAnswerList: true);
                }
              }
              break;
            }
          case HandleWhenFinish.cueCardVideoType:
            {
              //Start count down & record answer for part 2 - 120 seconds
              _recordProvider!.setVisibleRecord(true);
              _startRecordAnswer(fileName: fileName, isPart2: true);
              break;
            }
          case HandleWhenFinish.followupVideoType:
            {
              _startRecordAnswer(fileName: fileName, isPart2: false);
              _calculateIndexOfHeader();
              break;
            }
          case HandleWhenFinish.endOfTestVideoType:
            {
              //TODO: Finish doing test
              _testProvider!.setIsShowPlayVideoButton(true);

              //TODO: Submit test automatically
              if (kDebugMode) print("Finish play end of test video!");
              break;
            }
        }
      }
    }
  }

  @override
  void onAlertExit(String keyInfo) {
    _testProvider!.setDialogShowing(false);
  }

  @override
  void onAlertNextStep(String keyInfo) {
    _testProvider!.setDialogShowing(false);
    openAppSettings();
  }

  @override
  void onCountDown(String countDownString) {
    if (mounted) {
      _timerProvider!.setCountDown(countDownString);
    }
  }

  @override
  void onDownloadFailure(AlertInfo info) {
    if (mounted) {
      if (!_testProvider!.dialogShowing) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertsDialog.init().showDialog(
                context,
                info,
                this,
                keyInfo: StringClass.failDownloadVideo,
              );
            });
        _testProvider!.setDialogShowing(true);
      }
    }
  }

  @override
  void onDownloadSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total) {
    _prepareTestProvider!.setTotal(total);
    _prepareTestProvider!.updateDownloadingIndex(index);
    _prepareTestProvider!.updateDownloadingPercent(percent);

    //Enable Start Testing Button
    if (index >= 5) {
      _prepareTestProvider!.setStartNowButtonStatus(true);
    }

    if (index == total) {
      //Auto start to do test
      _checkPermission();
    }
  }

  @override
  void onGetTestDetailComplete(TestDetailModel testDetailModel, int total) {
    _prepareTestProvider!.updateProcessingStatus();
    _prepareTestProvider!.setDownloadingStatus(true);
    _prepareTestProvider!.setTotal(total);
  }

  @override
  void onGetTestDetailError(String message) {
    //Show error message
    showToastMsg(
      msg: message,
      toastState: ToastStatesType.error,
    );
  }

  @override
  void onNothingEndOfTest() {
    //TODO
    if (kDebugMode) print("onNothingEndOfTest");
  }

  @override
  void onNothingFileEndOfTest() {
    _videoFileEmpty();
  }

  @override
  void onNothingFileIntroduce() {
    _videoFileEmpty();
  }

  @override
  void onNothingFileQuestion() {
    _videoFileEmpty();
  }

  @override
  void onNothingIntroduce() {
    //TODO
    if (kDebugMode) print("onNothingIntroduce");
  }

  @override
  void onNothingQuestion() {
    //TODO
    if (kDebugMode) print("onNothingQuestion");
  }

  @override
  void onPlayEndOfTest(String fileName) {
    _initVideoController(
      fileName: fileName,
      handleWhenFinishType: HandleWhenFinish.endOfTestVideoType,
    );
  }

  @override
  void onPlayIntroduceFile(String fileName) {
    _initVideoController(
      fileName: fileName,
      handleWhenFinishType: HandleWhenFinish.introVideoType,
    );
  }

  @override
  void onSaveTopicListIntoProvider(List<TopicModel> list) {
    list.sort((a, b) => a.numPart.compareTo(b.numPart));
    _testProvider!.setTopicsList(list);
    Queue<TopicModel> queue = Queue<TopicModel>();
    queue.addAll(list);
    _testProvider!.setTopicsQueue(queue);
  }

  @override
  void onFinishAnswer(bool isPart2) {
    //Reset countdown
    _countDown!.cancel();

    //Reset count repeat
    _countRepeat = 0;

    //Enable repeat button
    _recordProvider!.setEnableRepeatButton(true);

    if (_testProvider!.isVisibleCueCard) {
      //Has cue card case
      if (isPart2) {
        //Finish record answer for part2
        _setVisibleCueCard(false, null);
        _recordProvider!.setVisibleRecord(false);

        //Add question into List Question & show it
        _testProvider!.addCurrentQuestionIntoList(questionTopic: _currentQuestion!, repeatIndex: _countRepeat);

        _playNextQuestion();
      } else {
        //Start to play end_of_take_note video
        Queue<TopicModel> topicQueue = _testProvider!.topicsQueue;
        TopicModel topic = topicQueue.first;

        _testPresenter!.playEndOfTakeNoteFile(topic);
      }
    } else {
      //Add question or followup into List Question & show it
      _testProvider!.addCurrentQuestionIntoList(questionTopic: _currentQuestion!, repeatIndex: _countRepeat);

      TopicModel? topicModel = _getCurrentPart();
      if (null != topicModel) {
        if (topicModel.numPart == PartOfTest.part3.get) {
          bool finishFollowUp = _testProvider!.finishPlayFollowUp;
          if (finishFollowUp == true) {
            _playNextQuestion();
          } else {
            _playNextFollowup();
          }
        } else {
          _playNextQuestion();
        }
      } else {
        if (kDebugMode) print("onFinishAnswer: ERROR-Current Part is NULL!");
      }
    }
  }

  @override
  void onNothingEndOfTakeNote() {
    //TODO
    if (kDebugMode) {
      print("onNothingEndOfTakeNote");
    }
  }

  @override
  void onNothingFileEndOfTakeNote() {
    //TODO
    if (kDebugMode) {
      print("onNothingFileEndOfTakeNote");
    }
  }

  @override
  void onPlayEndOfTakeNoteFile(String fileName) {
    _initVideoController(
      fileName: fileName,
      handleWhenFinishType: HandleWhenFinish.cueCardVideoType,
    );
  }
}
