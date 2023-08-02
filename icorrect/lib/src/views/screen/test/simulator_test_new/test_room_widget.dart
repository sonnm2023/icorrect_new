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
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect/src/presenters/simulator_test_presenter.dart';
import 'package:icorrect/src/presenters/test_room_presenter.dart';
import 'package:icorrect/src/provider/play_answer_provider.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:icorrect/src/provider/test_room_provider.dart';
import 'package:icorrect/src/provider/timer_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/confirm_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/custom_alert_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/re_answer_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/tip_question_dialog.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/cue_card_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/save_test_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/test_question_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/test_record_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/video_player_widget.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:record/record.dart';

class TestRoomWidget extends StatefulWidget {
  const TestRoomWidget(
      {super.key,
      required this.homeWorkModel,
      required this.simulatorTestPresenter});

  final ActivitiesModel homeWorkModel;
  final SimulatorTestPresenter simulatorTestPresenter;

  @override
  State<TestRoomWidget> createState() => _TestRoomWidgetState();
}

class _TestRoomWidgetState extends State<TestRoomWidget>
    with WidgetsBindingObserver
    implements TestRoomViewContract {
  TestRoomPresenter? _testRoomPresenter;
  TestRoomProvider? _testRoomProvider;
  SimulatorTestProvider? _simulatorTestProvider;

  TimerProvider? _timerProvider;
  PlayAnswerProvider? _playAnswerProvider;
  VideoPlayerController? _videoPlayerController;
  AudioPlayer? _audioPlayerController;
  Record? _recordController;

  Timer? _countDown;
  Timer? _countDownCueCard;
  QuestionTopicModel? _currentQuestion;
  int _countRepeat = 0;
  final List<dynamic> _reviewingList = [];
  List<dynamic> _reviewingQuestionList = [];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _audioPlayerController = AudioPlayer();
    _recordController = Record();

    _simulatorTestProvider =
        Provider.of<SimulatorTestProvider>(context, listen: false);
    _testRoomProvider = Provider.of<TestRoomProvider>(context, listen: false);
    _timerProvider = Provider.of<TimerProvider>(context, listen: false);
    _playAnswerProvider =
        Provider.of<PlayAnswerProvider>(context, listen: false);

    _testRoomPresenter = TestRoomPresenter(this);

    _startToDoTest();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _deallocateMemory();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("DEBUG: TestRoomWidget --- build");
    }

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
          child: VideoPlayerWidget(
            startToPlayVideo: _startToPlayVideo,
            pauseToPlayVideo: _pauseToPlayVideo,
            restartToPlayVideo: _restartToPlayVideo,
            continueToPlayVideo: _continueToPlayVideo,
          ),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              SingleChildScrollView(
                child: TestQuestionWidget(
                  testRoomPresenter: _testRoomPresenter!,
                  playAnswerCallBack: _playAnswerCallBack,
                  playReAnswerCallBack: _playReAnswerCallBack,
                  showTipCallBack: _showTipCallBack,
                ),
              ),
              const CueCardWidget(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(child: SizedBox()),
                  SizedBox(
                    height: 200,
                    child: Stack(
                      children: [
                        TestRecordWidget(
                          finishAnswer: _finishAnswerCallBack,
                          repeatQuestion: _repeatQuestionCallBack,
                        ),
                        _simulatorTestProvider!.activityType == "homework"
                            ? SaveTheTestWidget(
                                testRoomPresenter: _testRoomPresenter!)
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  void _startToDoTest() {
    if (_simulatorTestProvider!.topicsQueue.isNotEmpty) {
      _testRoomProvider!.setTopicsQueue(_simulatorTestProvider!.topicsQueue);
      _testRoomPresenter!.startPart(_simulatorTestProvider!.topicsQueue);
    }
  }

  void _deallocateMemory() async {
    //Stop count down timer
    if (null != _countDownCueCard) {
      _countDownCueCard!.cancel();
    }

    if (null != _countDown) {
      _countDown!.cancel();
    }

    await _stopRecord();
    await _recordController!.dispose();

    if (_audioPlayerController!.state == PlayerState.playing) {
      _audioPlayerController!.stop();
    }

    if (null != _videoPlayerController) {
      if (_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.pause();
      }

      await _videoPlayerController!.dispose();
      _testRoomProvider!.setPlayController(null);
    }

    _testRoomProvider!.resetAll();
    if (null != _testRoomProvider) {
      if (!_testRoomProvider!.isDisposed) {
        _testRoomProvider!.dispose();
      }
    }
  }

  void _playAnswerCallBack(
      QuestionTopicModel question, int selectedQuestionIndex) async {
    // if (_testRoomProvider!.reviewingStatus == ReviewingStatus.none) { //Comment for spin 1
    if (_simulatorTestProvider!.doingStatus == DoingStatus.finish) {
      //Stop playing current question
      if (_audioPlayerController!.state == PlayerState.playing) {
        await _audioPlayerController!.stop().then((_) {
          //Check playing answers status
          if (-1 != _playAnswerProvider!.selectedQuestionIndex) {
            if (selectedQuestionIndex !=
                _playAnswerProvider!.selectedQuestionIndex) {
              _startPlayAudio(
                  question: question,
                  selectedQuestionIndex: selectedQuestionIndex);
            } else {
              _playAnswerProvider!.resetSelectedQuestionIndex();
            }
          } else {
            _startPlayAudio(
                question: question,
                selectedQuestionIndex: selectedQuestionIndex);
          }
        });
      } else {
        //Check playing answers status
        if (-1 != _playAnswerProvider!.selectedQuestionIndex) {
          if (selectedQuestionIndex !=
              _playAnswerProvider!.selectedQuestionIndex) {
            _startPlayAudio(
                question: question,
                selectedQuestionIndex: selectedQuestionIndex);
          } else {
            _playAnswerProvider!.resetSelectedQuestionIndex();
          }
        } else {
          _startPlayAudio(
              question: question, selectedQuestionIndex: selectedQuestionIndex);
        }
      }
    } else {
      showToastMsg(
        msg: "Please wait until the test is finished!",
        toastState: ToastStatesType.warning,
      );
    }
  }

  void _startPlayAudio({
    required QuestionTopicModel question,
    required int selectedQuestionIndex,
  }) async {
    _playAnswerProvider!.setSelectedQuestionIndex(selectedQuestionIndex);

    String path = await Utils.getAudioPathToPlay(
        question, _simulatorTestProvider!.currentTestDetail.testId.toString());
    _playAudio(path);
  }

  Future<void> _playAnswerAudio(
      String audioPath, QuestionTopicModel question) async {
    if (kDebugMode) {
      print(
          "DEBUG: Reviewing current index = ${_testRoomProvider!.reviewingCurrentIndex} -- play answer");
    }

    await _audioPlayerController!.play(DeviceFileSource(audioPath));
    await _audioPlayerController!.setVolume(2.5);
    _audioPlayerController!.onPlayerComplete.listen((event) {
      _reviewingProcess();
    });
  }

  Future<void> _playAudio(String audioPath) async {
    try {
      await _audioPlayerController!.play(DeviceFileSource(audioPath));
      await _audioPlayerController!.setVolume(2.5);
      _audioPlayerController!.onPlayerComplete.listen((event) {
        _playAnswerProvider!.resetSelectedQuestionIndex();
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("DEBUG: $e");
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
            _testRoomPresenter!,
            _simulatorTestProvider!.currentTestDetail.testId.toString(),
          );
        },
      );
    });
  }

  void _playReAnswerCallBack(QuestionTopicModel question) {
    // if (_testRoomProvider!.reviewingStatus == ReviewingStatus.none) { //Comment for spin 1
    if (_simulatorTestProvider!.doingStatus == DoingStatus.finish) {
      bool isReviewing =
          _testRoomProvider!.reviewingStatus == ReviewingStatus.playing;

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
        if (_audioPlayerController!.state == PlayerState.playing) {
          _audioPlayerController!.stop();
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

  void _cancelButtonTapped() {
    if (kDebugMode) {
      print("DEBUG: _cancelButtonTapped");
    }
  }

  void _showTipCallBack(QuestionTopicModel question) {
    // if (_testRoomProvider!.reviewingStatus == ReviewingStatus.none) { //Comment for spin 1
    if (_simulatorTestProvider!.doingStatus == DoingStatus.finish) {
      _showTip(question);
    } else {
      showToastMsg(
        msg: "Please wait until the test is finished!",
        toastState: ToastStatesType.warning,
      );
    }
  }

  void _showTip(QuestionTopicModel questionTopicModel) {
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
        return TipQuestionDialog.tipQuestionDialog(context, questionTopicModel);
      },
    );
  }

  void _finishAnswerCallBack(QuestionTopicModel questionTopicModel) {
    bool isPart2 =
        _testRoomProvider!.topicsQueue.first.numPart == PartOfTest.part2.get;
    onFinishAnswer(isPart2);
  }

  void _repeatQuestionCallBack(QuestionTopicModel questionTopicModel) async {
    //Stop record
    _setVisibleRecord(false, null, null);

    _countRepeat++;

    //Add question into List Question & show it
    _testRoomProvider!.addCurrentQuestionIntoList(
        questionTopic: _currentQuestion!, repeatIndex: _countRepeat);

    TopicModel? topicModel = _getCurrentPart();
    if (null != topicModel) {
      if (topicModel.numPart == PartOfTest.part3.get) {
        bool finishFollowUp = _testRoomProvider!.finishPlayFollowUp;
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
      if (kDebugMode) {
        print("DEBUG: onFinishAnswer: ERROR-Current Part is NULL!");
      }
    }
  }

  void _startReviewing() async {
    //Reset current question
    _currentQuestion = null;

    _reviewingQuestionList = _prepareQuestionListForReviewing();
    dynamic item =
        _reviewingQuestionList[_testRoomProvider!.reviewingCurrentIndex];
    if (item is String) {
      _testRoomProvider!.setIsReviewingPlayAnswer(false);
      _initVideoController(
          fileName: item,
          handleWhenFinishType: HandleWhenFinish.reviewingVideoType);
    }
  }

  void _playReviewingQuestionAndAnswer(QuestionTopicModel question) async {
    String fileName = question.files.first.url;
    _playTheQuestionBeforePlayTheAnswer(fileName);
  }

  void _playTheQuestionBeforePlayTheAnswer(String fileName) {
    _initVideoController(
        fileName: fileName,
        handleWhenFinishType: HandleWhenFinish.reviewingPlayTheQuestionType);
  }

  void _playTheAnswerOfQuestion(QuestionTopicModel question) async {
    _testRoomProvider!.setIsReviewingPlayAnswer(true);

    String path = await Utils.getReviewingAudioPathToPlay(
      question,
      _simulatorTestProvider!.currentTestDetail.testId.toString(),
    );
    _playAnswerAudio(path, question);
  }

  void _continueReviewing() {
    int index = _testRoomProvider!.reviewingCurrentIndex + 1;
    _testRoomProvider!.updateReviewingCurrentIndex(index);
    dynamic item =
        _reviewingQuestionList[_testRoomProvider!.reviewingCurrentIndex];
    if (item is String) {
      _testRoomProvider!.setIsReviewingPlayAnswer(false);
      _initVideoController(
          fileName: item,
          handleWhenFinishType: HandleWhenFinish.reviewingVideoType);
    } else if (item is QuestionTopicModel) {
      _playReviewingQuestionAndAnswer(item);
    }
  }

  void _startToPlayVideo() {
    if (_simulatorTestProvider!.doingStatus == DoingStatus.finish) {
      //Start to review the test

      //Comment for spin 1
      // _startReviewing();
      showToastMsg(
        msg: "This feature is not available!",
        toastState: ToastStatesType.warning,
      );
    } else {
      //Start to do the test
      if (null != _testRoomProvider!.videoPlayController) {
        _testRoomProvider!.videoPlayController!.play();
      }
    }
  }

  void _pauseToPlayVideo() {
    if (kDebugMode) {
      print("DEBUG: _pauseToPlayVideo");
    }
  }

  void _restartToPlayVideo() {
    if (kDebugMode) {
      print("DEBUG: _restartToPlayVideo");
    }
  }

  void _continueToPlayVideo() {
    if (kDebugMode) {
      print("DEBUG: _continueToPlayVideo");
    }
  }

  void _playNextQuestion() {
    _setIndexOfNextQuestion();
    _startToPlayQuestion();
  }

  void _setIndexOfNextQuestion() {
    int i = _testRoomProvider!.indexOfCurrentQuestion;
    _testRoomProvider!.setIndexOfCurrentQuestion(i + 1);
  }

  void _setIndexOfNextFollowUp() {
    int i = _testRoomProvider!.indexOfCurrentFollowUp;
    _testRoomProvider!.setIndexOfCurrentFollowUp(i + 1);
  }

  TopicModel? _getCurrentPart() {
    Queue<TopicModel> topicsQueue = _testRoomProvider!.topicsQueue;

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
        print("DEBUG: Hasn't any part to playing");
      }
      return;
    }

    List<QuestionTopicModel> questionList = topicModel.questionList;
    if (questionList.isEmpty) {
      if (kDebugMode) {
        print("DEBUG: This part hasn't any question to playing");
      }
      switch (topicModel.numPart) {
        case 0:
          {
            //For introduce part
            _playNextPart();
            break;
          }
        case 1:
          {
            //For part 1
            _playNextQuestion();
            break;
          }
        case 2:
          {
            //For part 2
            if (kDebugMode) {
              print("DEBUG: onPlayEndOfTakeNoteFile(fileName)");
            }
            break;
          }
        case 3:
          {
            //For part 3
            _testRoomPresenter!.playEndOfTestFile(topicModel);
            break;
          }
      }
    } else {
      int index = _testRoomProvider!.indexOfCurrentQuestion;
      if (index >= questionList.length) {
        /*
        We played all questions of current part
        _playNextPart
        If current part is part 3 ==> to play end_of_test
        */
        if (topicModel.numPart == PartOfTest.part3.get) {
          _testRoomPresenter!.playEndOfTestFile(topicModel);
        } else {
          _playNextPart();
        }
      } else {
        QuestionTopicModel question = questionList.elementAt(index);
        question.numPart = topicModel.numPart;
        _currentQuestion = question;

        if (question.files.isEmpty) {
          if (kDebugMode) {
            print("DEBUG: This is DATA ERROR");
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
    _testRoomProvider!.removeTopicsQueueFirst();
    _testRoomProvider!.resetIndexOfCurrentQuestion();

    //No part for next play
    //Finish the test
    if (_testRoomProvider!.topicsQueue.isEmpty) {
      //TODO: Finish the test
      _prepareToEndTheTest();
    } else {
      _testRoomPresenter!.startPart(_testRoomProvider!.topicsQueue);
    }
  }

  void _playNextFollowup() {
    _setIndexOfNextFollowUp();
    _startToPlayFollowup();
  }

  void _repeatPlayCurrentFollowup() {
    if (_countRepeat == 2) {
      //Disable repeat button
      _testRoomProvider!.setEnableRepeatButton(false);
    }

    _startToPlayFollowup();
  }

  Future<void> _startToPlayFollowup() async {
    TopicModel? topicModel = _getCurrentPart();

    if (null == topicModel) {
      if (kDebugMode) {
        print("DEBUG: Hasn't any part to playing");
      }
      return;
    }

    List<QuestionTopicModel> followUpList = topicModel.followUp;

    if (followUpList.isEmpty) {
      if (kDebugMode) {
        print("DEBUG: This part hasn't any followup to playing");
      }
      _testRoomProvider!.setFinishPlayFollowUp(true);
      _startToPlayQuestion();
    } else {
      _testRoomProvider!.resetIndexOfCurrentQuestion();

      int index = _testRoomProvider!.indexOfCurrentFollowUp;
      if (index >= followUpList.length) {
        _testRoomProvider!.setFinishPlayFollowUp(true);
        _startToPlayQuestion();
      } else {
        QuestionTopicModel question = followUpList.elementAt(index);
        question.numPart = topicModel.numPart;
        _currentQuestion = question;

        if (question.files.isEmpty) {
          if (kDebugMode) {
            print("DEBUG: This is DATA ERROR");
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

  void _repeatPlayCurrentQuestion() {
    if (_countRepeat == 2) {
      //Disable repeat button
      _testRoomProvider!.setEnableRepeatButton(false);
    }

    _startToPlayQuestion();
  }

  bool _checkExist(QuestionTopicModel question) {
    if (_reviewingList.isEmpty) return false;

    for (int i = 0; i < _reviewingList.length; i++) {
      dynamic item = _reviewingList[i];
      if (item is QuestionTopicModel) {
        if (item.id == question.id) {
          return true;
        }
      }
    }

    return false;
  }

  Future<void> _initVideoController({
    required String fileName,
    required HandleWhenFinish handleWhenFinishType,
  }) async {
    _simulatorTestProvider!.setIsLoadingVideo(true);

    if (handleWhenFinishType == HandleWhenFinish.introVideoType ||
        handleWhenFinishType == HandleWhenFinish.endOfTestVideoType ||
        handleWhenFinishType == HandleWhenFinish.cueCardVideoType) {
      _reviewingList.add(fileName);
    } else {
      if (null != _currentQuestion) {
        if (!_checkExist(_currentQuestion!)) {
          _reviewingList.add(_currentQuestion!); //Add file
        }
      }
    }

    //Dispose old video play controller before create new one
    if (null != _testRoomProvider!.videoPlayController) {
      _testRoomProvider!.videoPlayController!.dispose();
      _testRoomProvider!.setPlayController(null);
    }

    Utils.prepareVideoFile(fileName).then((value) {
      if (kDebugMode) {
        print("DEBUG: Playing ---- $fileName");
      }

      //Initialize new player for new video
      _videoPlayerController = VideoPlayerController.file(value)
        ..initialize().then((value) {
          _simulatorTestProvider!.setIsLoadingVideo(false);
          if (_countRepeat != 0) {
            _videoPlayerController!.setPlaybackSpeed(0.9);
          }
          _videoPlayerController!.play();

          if (ReviewingStatus.none == _testRoomProvider!.reviewingStatus) {
            Future.delayed(const Duration(milliseconds: 1), () {
              _videoPlayerController!.pause();
            });
          }

          if (null != _videoPlayerController) {
            _testRoomProvider!.setPlayController(_videoPlayerController!);
          }

          _videoPlayerController!
              .addListener((() => _checkVideo(fileName, handleWhenFinishType)));
        })
        ..setLooping(false);
    });
  }

  Future<void> _stopRecord() async {
    await _recordController!.stop();
  }

  void _setVisibleRecord(bool visible, Timer? count, String? fileName) async {
    if (false == visible) {
      await _stopRecord();
    }

    _testRoomProvider!.setVisibleRecord(visible);
    _testRoomProvider!.setCountDownTimer(count);
  }

  Future<void> _recordAnswer(String fileName) async {
    String newFileName = "${await _createLocalAudioFileName(fileName)}.wav";
    String path = await FileStorageHelper.getFilePath(
        newFileName,
        MediaType.audio,
        _simulatorTestProvider!.currentTestDetail.testId.toString());

    if (kDebugMode) {
      print("DEBUG: RECORD AS FILE PATH: $path");
    }

    if (await _recordController!.hasPermission()) {
      await _recordController!.start(
        path: path,
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        samplingRate: 44100,
      );

      List<FileTopicModel> temp = _currentQuestion!.answers;
      if (!_checkAnswerFileExist(newFileName, temp)) {
        temp.add(
            FileTopicModel.fromJson({'id': 0, 'url': newFileName, 'type': 0}));
        _currentQuestion!.answers = temp;
        _testRoomProvider!.setCurrentQuestion(_currentQuestion!);
      }
    }
  }

  bool _checkAnswerFileExist(String url, List<FileTopicModel> list) {
    if (list.isEmpty) return false;

    for (int i = 0; i < list.length; i++) {
      FileTopicModel item = list[i];
      if (item.url == url) {
        return true;
      }
    }

    return false;
  }

  Future<String> _createLocalAudioFileName(String origin) async {
    String fileName = "";
    final split = origin.split('.');
    if (_countRepeat > 0) {
      fileName = 'repeat_${_countRepeat.toString()}_${split[0]}';
    } else {
      fileName = 'answer_${split[0]}';
    }
    return fileName;
  }

  void _checkVideo(
      String fileName, HandleWhenFinish handleWhenFinishType) async {
    if (null != _testRoomProvider!.videoPlayController) {
      if (_testRoomProvider!.videoPlayController!.value.position ==
          _testRoomProvider!.videoPlayController!.value.duration) {
        _testRoomProvider!.videoPlayController!.pause();

        switch (handleWhenFinishType) {
          case HandleWhenFinish.questionVideoType:
            {
              if (_currentQuestion!.cueCard.isNotEmpty &&
                  (false == _testRoomProvider!.isVisibleCueCard)) {
                //Has Cue Card case
                _testRoomProvider!.setVisibleRecord(false);
                _testRoomProvider!.setCurrentQuestion(_currentQuestion!);

                int time = 3; //3 for test, 60 for product
                String timeString = Utils.getTimeRecordString(time);
                _testRoomProvider!.setCountDownCueCard(timeString);

                _countDownCueCard =
                    _testRoomPresenter!.startCountDownForCueCard(
                  context: context,
                  count: time,
                  isPart2: false,
                );
                _testRoomProvider!.setVisibleCueCard(true);
              } else {
                //Normal case
                if (false == _testRoomProvider!.visibleRecord &&
                    false == _testRoomProvider!.isVisibleCueCard) {
                  _startRecordAnswer(fileName: fileName, isPart2: false);
                }
              }

              if (_countRepeat == 0) {
                _calculateIndexOfHeader();
              }

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
              _startRecordAnswer(fileName: fileName, isPart2: true);
              break;
            }
          case HandleWhenFinish.followupVideoType:
            {
              _startRecordAnswer(fileName: fileName, isPart2: false);
              if (_countRepeat == 0) {
                _calculateIndexOfHeader();
              }
              break;
            }
          case HandleWhenFinish.endOfTestVideoType:
            {
              _prepareToEndTheTest();
              break;
            }
          case HandleWhenFinish.reviewingVideoType:
            {
              _reviewingProcess();
              break;
            }
          case HandleWhenFinish.reviewingPlayTheQuestionType:
            {
              QuestionTopicModel question =
                  _reviewingList[_testRoomProvider!.reviewingCurrentIndex];
              _playTheAnswerOfQuestion(question);
              break;
            }
        }
      }
    }
  }

  void _reviewingProcess() {
    if (_testRoomProvider!.reviewingCurrentIndex <
        _reviewingQuestionList.length) {
      _continueReviewing();
    } else {
      //Finish reviewing
      if (kDebugMode) print("DEBUG: Finish reviewing");
    }
  }

  void _prepareToEndTheTest() {
    //Finish doing test
    _testRoomProvider!.updateReviewingStatus(ReviewingStatus.none);
    _simulatorTestProvider!.updateDoingStatus(DoingStatus.finish);

    //Save answer list into prepare_simulator_test_provider
    List<String> temp = _prepareAnswerListForDelete();
    _simulatorTestProvider!.setAnswerList(temp);
    List<QuestionTopicModel> questions = _prepareQuestionListForSubmit();
    _simulatorTestProvider!.setQuestionList(questions);

    //Auto submit test for activity type = test
    if (_simulatorTestProvider!.activityType == "test") {
      _startSubmitTest();
    } else {
      //Activity Type = "homework"
      _setVisibleSaveTest(true);
    }
  }

  void _startSubmitTest() {
    // _simulatorTestProvider!.setIsSubmitting(true);
    _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.submitting);

    List<QuestionTopicModel> questions = _prepareQuestionListForSubmit();

    _testRoomPresenter!.submitTest(
      testId: _simulatorTestProvider!.currentTestDetail.testId.toString(),
      activityId: widget.homeWorkModel.activityId.toString(),
      questions: questions,
    );
  }

  List<QuestionTopicModel> _prepareQuestionListForSubmit() {
    if (_reviewingList.isEmpty) return [];
    List<QuestionTopicModel> temp = [];

    for (int i = 0; i < _reviewingList.length; i++) {
      dynamic item = _reviewingList[i];
      if (item is QuestionTopicModel) {
        temp.add(item);
      }
    }

    return temp;
  }

  List<dynamic> _prepareQuestionListForReviewing() {
    if (_reviewingList.isEmpty) return [];
    List<dynamic> temp = [];

    for (int i = 0; i < _reviewingList.length; i++) {
      dynamic item = _reviewingList[i];
      if (item is QuestionTopicModel) {
        for (int j = 0; j < item.answers.length; j++) {
          FileTopicModel answer = item.answers.elementAt(j);
          QuestionTopicModel q = QuestionTopicModel().copyWith(
            id: item.id,
            content: item.content,
            type: item.type,
            topicId: item.topicId,
            tips: item.tips,
            tipType: item.tipType,
            isFollowUp: item.isFollowUp,
            cueCard: item.cueCard,
            reAnswerCount: item.reAnswerCount,
            answers: [answer],
            numPart: item.numPart,
            repeatIndex: item.repeatIndex,
            files: item.files,
          );
          temp.add(q);
        }
      } else {
        temp.add(item);
      }
    }

    return temp;
  }

  void _calculateIndexOfHeader() {
    TopicModel? topicModel = _getCurrentPart();
    if (null != topicModel) {
      switch (topicModel.numPart) {
        case 2:
          {
            //PART 2
            if (_testRoomProvider!.indexOfCurrentQuestion == 0) {
              _testRoomProvider!.setIndexOfHeaderPart2(
                  _testRoomProvider!.questionList.length);
            }
            break;
          }
        case 3:
          {
            //PART 3
            if (topicModel.followUp.isNotEmpty) {
              if (_testRoomProvider!.indexOfCurrentFollowUp == 0) {
                _testRoomProvider!.setIndexOfHeaderPart3(
                    _testRoomProvider!.questionList.length);
              }
            } else {
              if (_testRoomProvider!.indexOfCurrentQuestion == 0) {
                _testRoomProvider!.setIndexOfHeaderPart3(
                    _testRoomProvider!.questionList.length);
              }
            }
            break;
          }
      }
    }
  }

  void _startRecordAnswer({
    required String fileName,
    required bool isPart2,
  }) async {
    //Stop old record
    await _stopRecord();

    TopicModel? topicModel = _getCurrentPart();

    if (null == topicModel) {
      return;
    }

    Queue<TopicModel> queue = _testRoomProvider!.topicsQueue;
    int timeRecord = Utils.getRecordTime(queue.first.numPart);
    String timeString = Utils.getTimeRecordString(timeRecord);

    //Record the answer
    _timerProvider!.setCountDown(timeString);

    if (null != _countDown) {
      _countDown!.cancel();
    }
    _countDown = _testRoomPresenter!
        .startCountDown(context: context, count: timeRecord, isPart2: isPart2);

    _setVisibleRecord(true, _countDown, fileName);

    _recordAnswer(fileName);
  }

  void _setVisibleSaveTest(bool isVisible) {
    _testRoomProvider!.setVisibleSaveTheTest(isVisible);
  }

  void _gotoMyTestScreen() {
    widget.simulatorTestPresenter.gotoMyTestScreen();
  }

  //For test: Delete All Answer file
  List<String> _prepareAnswerListForDelete() {
    if (_reviewingList.isEmpty) return [];
    List<String> temp = [];

    for (int i = 0; i < _reviewingList.length; i++) {
      dynamic item = _reviewingList[i];
      if (item is QuestionTopicModel) {
        for (int j = 0; j < item.answers.length; j++) {
          String answerFileName = item.answers[j].url;
          temp.add(answerFileName);
        }
      }
    }

    return temp;
  }

  @override
  void onCountDown(String countDownString) {
    if (mounted) {
      _timerProvider!.setCountDown(countDownString);
    }
  }

  @override
  void onFinishAnswer(bool isPart2) {
    //Reset countdown
    if (null != _countDown) {
      _countDown!.cancel();
    }

    //Reset count repeat
    _countRepeat = 0;

    //Enable repeat button
    _testRoomProvider!.setEnableRepeatButton(true);

    //Stop record
    _setVisibleRecord(false, null, null);

    if (_testRoomProvider!.isVisibleCueCard) {
      //Has cue card case
      if (isPart2) {
        _testRoomProvider!.setVisibleCueCard(false);

        //Add question into List Question & show it
        _testRoomProvider!.addCurrentQuestionIntoList(
            questionTopic: _currentQuestion!, repeatIndex: _countRepeat);

        _playNextQuestion();
      } else {
        //Start to play end_of_take_note video
        Queue<TopicModel> topicQueue = _testRoomProvider!.topicsQueue;
        TopicModel topic = topicQueue.first;

        _testRoomPresenter!.playEndOfTakeNoteFile(topic);
      }
    } else {
      //Add question or followup into List Question & show it
      _testRoomProvider!.addCurrentQuestionIntoList(
          questionTopic: _currentQuestion!, repeatIndex: _countRepeat);

      TopicModel? topicModel = _getCurrentPart();
      if (null != topicModel) {
        if (topicModel.numPart == PartOfTest.part3.get) {
          bool finishFollowUp = _testRoomProvider!.finishPlayFollowUp;
          if (finishFollowUp == true) {
            _playNextQuestion();
          } else {
            _playNextFollowup();
          }
        } else {
          _playNextQuestion();
        }
      } else {
        if (kDebugMode) {
          print("DEBUG: onFinishAnswer: ERROR-Current Part is NULL!");
        }
      }
    }
  }

  @override
  void onNothingEndOfTakeNote() {
    // TODO: implement onNothingEndOfTakeNote
  }

  @override
  void onNothingEndOfTest() {
    // TODO: implement onNothingEndOfTest
  }

  @override
  void onNothingFileEndOfTakeNote() {
    // TODO: implement onNothingFileEndOfTakeNote
  }

  @override
  void onNothingFileEndOfTest() {
    // TODO: implement onNothingFileEndOfTest
  }

  @override
  void onNothingFileIntroduce() {
    // TODO: implement onNothingFileIntroduce
  }

  @override
  void onNothingFileQuestion() {
    // TODO: implement onNothingFileQuestion
  }

  @override
  void onNothingIntroduce() {
    // TODO: implement onNothingIntroduce
  }

  @override
  void onNothingQuestion() {
    // TODO: implement onNothingQuestion
  }

  @override
  void onPlayEndOfTakeNoteFile(String fileName) {
    if (false == _simulatorTestProvider!.isLoadingVideo) {
      _initVideoController(
        fileName: fileName,
        handleWhenFinishType: HandleWhenFinish.cueCardVideoType,
      );
    }
  }

  @override
  void onPlayEndOfTest(String fileName) {
    if (false == _simulatorTestProvider!.isLoadingVideo) {
      _initVideoController(
        fileName: fileName,
        handleWhenFinishType: HandleWhenFinish.endOfTestVideoType,
      );
    }
  }

  @override
  void onPlayIntroduceFile(String fileName) {
    if (false == _simulatorTestProvider!.isLoadingVideo) {
      _initVideoController(
        fileName: fileName,
        handleWhenFinishType: HandleWhenFinish.introVideoType,
      );
    }
  }

  @override
  void onCountDownForCueCard(String countDownString) {
    if (mounted) {
      _testRoomProvider!.setCountDownCueCard(countDownString);
    }
  }

  @override
  void onSubmitTestFail(String msg) async {
    //Update indicator process status
    _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.fail);

    //Show submit error popup
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CustomAlertDialog(title: "Notify", description: "An error occur, please try again later!");
      },
    );
  }

  @override
  void onSubmitTestSuccess(String msg) {
    _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.success);

    showToastMsg(
      msg: msg,
      toastState: ToastStatesType.success,
    );

    _gotoMyTestScreen();
  }

  @override
  void onClickSaveTheTest() async {
    if (SubmitStatus.none == _simulatorTestProvider!.submitStatus ||
        SubmitStatus.fail == _simulatorTestProvider!.submitStatus) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmDialogWidget(
            title: "Notify",
            message: "Do you want to save this test?",
            cancelButtonTitle: "Don't Save",
            okButtonTitle: "Save",
            cancelButtonTapped: () {
              if (kDebugMode) print("_cancelButtonTapped");
            },
            okButtonTapped: () {
              _startSubmitTest();
            },
          );
        },
      );
    }
  }

  @override
  void onFinishTheTest() {
    _prepareToEndTheTest();
  }
}
