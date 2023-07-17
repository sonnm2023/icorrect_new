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
import 'package:icorrect/src/provider/test_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/alert_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/confirm_dialog.dart';
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

class SimulatorTestNewScreen extends StatefulWidget {
  const SimulatorTestNewScreen({super.key, required this.homeWorkModel});

  final HomeWorkModel homeWorkModel;

  @override
  State<SimulatorTestNewScreen> createState() => _SimulatorTestNewScreenState();
}

class _SimulatorTestNewScreenState extends State<SimulatorTestNewScreen>
    with WidgetsBindingObserver
    implements TestViewContract, ActionAlertListener {
  TestPresenter? _testPresenter;
  TestProvider? _testProvider;

  Permission? _microPermission;
  PermissionStatus _microPermissionStatus = PermissionStatus.denied;

  VideoPlayerController? _playerController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Record _record = Record();

  // final int _countRepeat = 0; //TODO
  Timer? _countDown;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    _testProvider = Provider.of<TestProvider>(context, listen: false);
    _testPresenter = TestPresenter(this);
    _getTestDetail();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _record.dispose();

    if (_audioPlayer.state == PlayerState.playing) {
      _audioPlayer.stop();
    }

    _audioPlayer.dispose();
    if (null != _playerController) {
      if (_playerController!.value.isPlaying) {
        _playerController!.pause();
      }

      _playerController!.dispose();
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
    if (kDebugMode) print("_okButtonTapped");

    _record.stop();
    if(null != _testProvider!.playController) {
      _testProvider!.playController!.pause();
    }

    _testProvider!.resetAll();
    Navigator.of(context).pop();
  }

  Widget _buildBody() {
    return Consumer<TestProvider>(
      builder: (context, testProvider, child) {
        if (testProvider.isProcessing) {
          return const DefaultLoadingIndicator(
            color: AppColor.defaultPurpleColor,
          );
        }

        if (testProvider.isDownloading) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const DownloadProgressingWidget(),
              Visibility(
                visible: testProvider.canStartNow,
                child: StartNowButtonWidget(startNowButtonTapped: () {
                  _checkPermission();
                }),
              ),
            ],
          );
        }

        if (testProvider.isDoingTest) {
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
        }

        return Container(color: Colors.white);
      },
    );
  }

  void _playAnswerCallBack(QuestionTopicModel question) async {
    // if (_testProvider!.isShowPlayVideoButton) {
    //   //TODO: Play answer audio
    // } else {
    //   showToastMsg(
    //     msg: "Please wait until the test is finished!",
    //     toastState: ToastStatesType.warning,
    //   );
    // }

    String path = await FileStorageHelper.getFilePath(question.answers.first.url, MediaType.audio);
    _playAudio(path, question.id.toString());
  }

  Future<void> _playAudio(String audioPath, String questionId) async {
    try {
      await _audioPlayer.play(DeviceFileSource(audioPath));
      await _audioPlayer.setVolume(2.5);
      _audioPlayer.onPlayerComplete.listen((event) {
        //TODO: Update play answer button status
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }

  void _playReAnswerCallBack(QuestionTopicModel question) {
    if (_testProvider!.isShowPlayVideoButton) {
      //TODO: re-answer the question which be selected
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

  void _repeatQuestionCallBack(QuestionTopicModel questionTopicModel) {
    if (kDebugMode) print("repeatQuestion");
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

    _requestPermission(_microPermission!, context);
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
      _testProvider!.updateProcessingStatus();
      _testProvider!.setDoingTestStatus(false);
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

  Future<void> _startToPlayFollowup() async {
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
      _startToPlayQuestion();
    } else {
      _testProvider!.resetIndexOfCurrentQuestion();

      int index = _testProvider!.indexOfCurrentFollowUp;
      if (index >= followUpList.length) {
        _testProvider!.setFinishPlayFollowUp(true);
        _startToPlayQuestion();
      } else {
        QuestionTopicModel question = followUpList.elementAt(index);
        //Set current question into Provider
        _testProvider!.setCurrentQuestion(question);

        if (question.files.isEmpty) {
          if (kDebugMode) {
            print("This is DATA ERROR");
          }
        } else {
          FileTopicModel file = question.files.first;

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

  Future<void> _startToPlayQuestion() async {
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
        //Set current question into Provider
        _testProvider!.setCurrentQuestion(question);

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
    _setIndexOfNextFollowUp();
    _startToPlayFollowup();
  }

  void _playNextQuestion() {
    _setIndexOfNextQuestion();
    _startToPlayQuestion();
  }

  Future<void> _initVideoController({
    required String fileName,
    required HandleWhenFinish handleWhenFinishType,
  }) async {
    _setVisibleRecord(false, null, null);
    _testProvider!.setIsLoadingVideo(true);

    Utils.prepareVideoFile(fileName).then((value) {
      //Deallocate player memory
      if (null != _playerController) {
        _playerController!.dispose();
        _testProvider!.setPlayController(null);
      }

      //Initialize new player for new video
      _playerController = VideoPlayerController.file(value)
        ..addListener(() => _checkVideo(fileName, handleWhenFinishType))
        ..initialize().then((value) {
          _testProvider!.setIsLoadingVideo(false);
          _playerController!.setLooping(false);
          _playerController!.play();

          if (null != _playerController) {
            _testProvider!.setPlayController(_playerController!);
          }

          if (true == _testProvider!.isShowPlayVideoButton) {
            Future.delayed(const Duration(milliseconds: 1), () {
              _playerController!.pause();
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

  void _startRecordAnswer({required String fileName, required bool isPart2}) async {
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
    _testProvider!.setCountDown(timeString);

    String path =
        await FileStorageHelper.getFilePath(fileName, MediaType.audio);
    _testProvider!.setFilePath(path);

    _countDown = _testPresenter!.startCountDown(context, timeRecord, isPart2);
    _setVisibleRecord(true, _countDown, path);
  }

  void _setVisibleRecord(bool visible, Timer? count, String? filePath) {
    _testProvider!.setVisibleRecord(visible);

    if (_testProvider!.visibleRecord) {
      _recordAnswer(filePath!);
    } else {
      _record.stop();
    }
    _testProvider!.setCountDownTimer(count);
  }

  Future<void> _recordAnswer(String filePath) async {
    if (await _record.hasPermission()) {
      await _record.start(
        path: filePath,
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        samplingRate: 44100,
      );
    }

    //TODO
    _testProvider!.addAnswer(
        FileTopicModel.fromJson({'id': 0, 'url': filePath, 'type': 0}));
    _testProvider!.currentQuestion.answers.clear();
    _testProvider!.currentQuestion.answers.addAll(_testProvider!.answers);
  }

  //TODO
  void _setSaveTheTest() {
    _countDown != null ? _countDown!.cancel() : '';
    _setVisibleSaveTest(true);
    _setVisibleCueCard(false, null);
    _setVisibleRecord(false, null, null);
    _setVisibleReAnswer(true);
  }

  void _setVisibleSaveTest(bool isVisible) {
    _testProvider!.setVisibleSaveTheTest(isVisible);
  }

  void _setVisibleReAnswer(bool visible) {
    _testProvider!.setVisibleReAnswer(visible);
  }

  void _setVisibleCueCard(bool visible, Timer? count) {
    _testProvider!.setVisibleCueCard(visible, timer: count);
  }

  void _startToDoTest() {
    //Hide StartNow button
    _testProvider!.setStartNowButtonStatus(false);

    //Hide Loading view
    _testProvider!.setDownloadingStatus(false);

    //Update doing test status = true => show Doing test view
    _testProvider!.setDoingTestStatus(true);

    //Reset Play Video Button status
    _testProvider!.setIsShowPlayVideoButton(true);

    //TODO: New following
    _testPresenter!.startPart(_testProvider!.topicsQueue);
  }

  void _checkVideo(String fileName, HandleWhenFinish handleWhenFinishType) {
    if (null != _testProvider!.playController) {
      if (_testProvider!.playController!.value.position ==
          _testProvider!.playController!.value.duration) {
        switch (handleWhenFinishType) {
          case HandleWhenFinish.questionVideoType:
            {
              if (_testProvider!.currentQuestion.cueCard.isNotEmpty &&
                  (false == _testProvider!.isVisibleCueCard)) {
                //Has Cue Card case
                _testProvider!.setVisibleRecord(false);
                _setVisibleCueCard(true, null);
                _countDown = _testPresenter!.startCountDown(context, 5,
                    false); // TODO: 5 for testing, 60 for product
              } else {
                //Normal case
                if (false == _testProvider!.visibleRecord &&
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
                  _startToPlayFollowup();
                } else {
                  _startToPlayQuestion();
                }
              }
              break;
            }
          case HandleWhenFinish.cueCardVideoType:
            {
              //Start count down & record answer for part 2 - 120 seconds
              _testProvider!.setVisibleRecord(true);
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
  void onClickEndReAnswer(QuestionTopicModel question, String filePath) {
    for (QuestionTopicModel q in _testProvider!.questionList) {
      if (q.id == question.id) {
        q.answers.last.url = filePath;
        q.reAnswerCount++;
        break;
      }
    }
  }

  @override
  void onCountDown(String countDownString) {
    if (mounted) {
      _testProvider!.setCountDown(countDownString);
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
    _testProvider!.setTotal(total);
    _testProvider!.updateDownloadingIndex(index);
    _testProvider!.updateDownloadingPercent(percent);

    //Enable Start Testing Button
    if (index >= 5) {
      if (!_testProvider!.isDoingTest) {
        _testProvider!.setStartNowButtonStatus(true);
      }
    }

    if (index == total && _testProvider!.isDoingTest == false) {
      //Auto start to do test
      _checkPermission();
    }
  }

  @override
  void onGetTestDetailComplete(TestDetailModel testDetailModel, int total) {
    _testProvider!.updateProcessingStatus();
    _testProvider!.setDownloadingStatus(true);
    _testProvider!.setTotal(total);
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

    if (_testProvider!.isVisibleCueCard) {
      //Has cue card case
      if (isPart2) {
        //Finish record answer for part2
        _setVisibleCueCard(false, null);
        _testProvider!.setVisibleRecord(false);

        //Add question into List Question & show it
        _testProvider!
            .addCurrentQuestionIntoList(_testProvider!.currentQuestion);

        _playNextQuestion();
      } else {
        //Start to play end_of_take_note video
        Queue<TopicModel> topicQueue = _testProvider!.topicsQueue;
        TopicModel topic = topicQueue.first;

        //TODO: New
        _testPresenter!.playEndOfTakeNoteFile(topic);
      }
    } else {
      //Add question or followup into List Question & show it
      _testProvider!.addCurrentQuestionIntoList(_testProvider!.currentQuestion);

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
