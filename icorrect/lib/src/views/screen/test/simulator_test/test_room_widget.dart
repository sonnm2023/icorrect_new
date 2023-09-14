import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activity_answer_model.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect/src/presenters/simulator_test_presenter.dart';
import 'package:icorrect/src/presenters/test_room_presenter.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/provider/play_answer_provider.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:icorrect/src/provider/timer_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/confirm_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/custom_alert_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/re_answer_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/tip_question_dialog.dart';
import 'package:icorrect/src/views/widget/default_loading_indicator.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/cue_card_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/save_test_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/test_question_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/test_record_widget.dart';
import 'package:native_video_player/native_video_player.dart';
import 'package:provider/provider.dart';
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
  SimulatorTestProvider? _simulatorTestProvider;

  TimerProvider? _timerProvider;
  PlayAnswerProvider? _playAnswerProvider;
  NativeVideoPlayerController? _videoPlayerController;
  AudioPlayer? _audioPlayerController;
  Record? _recordController;

  Timer? _countDown;
  Timer? _countDownCueCard;
  QuestionTopicModel? _currentQuestion;
  int _countRepeat = 0;
  final List<dynamic> _reviewingList = [];
  List<dynamic> _reviewingQuestionList = [];
  int _playingIndex = 0;
  bool _hasHeaderPart3 = false;
  int _endOfTakeNoteIndex = 0;
  bool _isBackgroundMode = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _audioPlayerController = AudioPlayer();
    _recordController = Record();

    _simulatorTestProvider =
        Provider.of<SimulatorTestProvider>(context, listen: false);
    _timerProvider = Provider.of<TimerProvider>(context, listen: false);
    _playAnswerProvider =
        Provider.of<PlayAnswerProvider>(context, listen: false);

    _testRoomPresenter = TestRoomPresenter(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _deallocateMemory();
    super.dispose();
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
          print('DEBUG: App detached');
        }
        break;
      
    }
  }

  Future _onAppInBackground() async {
    _isBackgroundMode = true;

    if (null != _videoPlayerController) {
      bool isPlaying = await _videoPlayerController!.isPlaying();
      if (isPlaying) {
        _videoPlayerController!.stop();
      }

      if (_simulatorTestProvider!.visibleRecord) {
        _recordController!.stop();

        if (null != _countDown) {
          _countDown!.cancel();
        }

        if (null != _countDownCueCard) {
          _countDownCueCard!.cancel();
        }
      }

      if (_audioPlayerController!.state == PlayerState.playing) {
        _audioPlayerController!.stop();
        _playAnswerProvider!.resetSelectedQuestionIndex();
      }
    }
  }

  Future _onAppActive() async {
    _isBackgroundMode = false;
    if (null != _videoPlayerController) {
      if (_simulatorTestProvider!.visibleCueCard) {
        // QuestionTopicModel currentQuestion =
        //     _simulatorTestProvider!.currentQuestion;

        // _simulatorTestProvider!.setVisibleCueCard(false);
        // _simulatorTestProvider!.setVisibleRecord(false);
        // _recordController!.stop();
        // _audioPlayerController!.stop();

        //Playing end_of_take_note ==> replay end_of_take_note
        if (_endOfTakeNoteIndex != 0) {
          _rePlayEndOfTakeNote();
        }

        //Recording the answer for Part 2 ==> Re record the answer
      } else {
        if (_simulatorTestProvider!.doingStatus != DoingStatus.finish &&
            _simulatorTestProvider!.reviewingStatus != ReviewingStatus.none &&
            _simulatorTestProvider!.visibleRecord == false) {
          _videoPlayerController!.play();
        } else if (_simulatorTestProvider!.visibleRecord == true) {
          //Re record
          _reRecord();
        }
      }
    }
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
          child: _buildVideoPlayerView(),
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

  Widget _buildVideoPlayerView() {
    double w = MediaQuery.of(context).size.width;
    double h = 200;

    return Consumer<SimulatorTestProvider>(
        builder: (context, simulatorTestProvider, child) {
      if (kDebugMode) {
        print("DEBUG: VideoPlayerWidget --- build");
      }

      if (simulatorTestProvider.isLoadingVideo) {
        return SizedBox(
          width: w,
          height: h,
          child: const Center(
            child: DefaultLoadingIndicator(
              color: AppColor.defaultPurpleColor,
            ),
          ),
        );
      } else {
        Widget buttonsControllerSubView = Container();

        switch (simulatorTestProvider.reviewingStatus.get) {
          case -1: //None
            {
              buttonsControllerSubView = SizedBox(
                width: w,
                height: h,
                child: Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: InkWell(
                      onTap: () {
                        simulatorTestProvider
                            .updateReviewingStatus(ReviewingStatus.playing);
                        _startToPlayVideo();
                      },
                      child: const Icon(
                        Icons.play_arrow,
                        color: AppColor.defaultAppColor,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              );
              break;
            }
          case 0: //Playing
            {
              buttonsControllerSubView = SizedBox(
                width: w,
                height: h,
                child: GestureDetector(onTap: () {
                  //Update reviewing status from playing -> pause
                  //show/hide pause button
                  if (simulatorTestProvider.doingStatus != DoingStatus.doing) {
                    if (simulatorTestProvider.reviewingStatus ==
                        ReviewingStatus.playing) {
                      simulatorTestProvider
                          .updateReviewingStatus(ReviewingStatus.pause);
                    }
                  }
                }),
              );
              break;
            }
          case 1: //Pause
            {
              buttonsControllerSubView = InkWell(
                onTap: () {
                  if (simulatorTestProvider.reviewingStatus ==
                      ReviewingStatus.pause) {
                    simulatorTestProvider
                        .updateReviewingStatus(ReviewingStatus.playing);
                  }
                },
                child: SizedBox(
                  width: w,
                  height: h,
                  child: Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: InkWell(
                        onTap: () {
                          //Update reviewing status from pause -> restart
                          //TODO
                          // simulatorTestProvider
                          //     .updateReviewingStatus(ReviewingStatus.restart);
                          // pauseToPlayVideo();
                        },
                        child: const Icon(
                          Icons.pause,
                          color: AppColor.defaultAppColor,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ),
              );
              break;
            }
          case 2: //Restart
            {
              buttonsControllerSubView = SizedBox(
                width: w,
                height: h,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: InkWell(
                          onTap: () {
                            //TODO
                            // restartToPlayVideo();
                          },
                          child: const Icon(
                            Icons.restart_alt,
                            color: AppColor.defaultAppColor,
                            size: 50,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: InkWell(
                          onTap: () {
                            //TODO
                            // continueToPlayVideo();
                          },
                          child: const Icon(
                            Icons.play_arrow,
                            color: AppColor.defaultAppColor,
                            size: 50,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
              break;
            }
        }

        return Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: NativeVideoPlayerView(
                onViewReady: _initController,
              ),
            ),

            //Play video controller buttons
            _simulatorTestProvider!.doingStatus != DoingStatus.finish
                ? buttonsControllerSubView
                : Container(),

            //TODO
            // Visibility(
            //   visible: simulatorTestProvider.isReviewingPlayAnswer,
            //   child: playAudioBackground(w, h),
            // )
          ],
        );
      }
    });
  }

  Future<void> _initController(NativeVideoPlayerController controller) async {
    _videoPlayerController = controller;
    _videoPlayerController!.setVolume(1.0);
    await _loadVideoSource(
            _simulatorTestProvider!.listVideoSource[_playingIndex].url)
        .then((_) {
      _videoPlayerController!.stop();
    });
  }

  Future<void> _loadVideoSource(String fileName) async {
    final videoSource = await _createVideoSource(fileName);
    await _videoPlayerController!.loadVideoSource(videoSource);
  }

  Future<VideoSource> _createVideoSource(String fileName) async {
    String path =
        await FileStorageHelper.getFilePath(fileName, MediaType.video, null);
    return VideoSource.init(
      path: path,
      type: VideoSourceType.file,
    );
  }

  void _startToDoTest() {
    _initVideoController();
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
      _videoPlayerController = null;
    }
  }

  void _playAnswerCallBack(
      QuestionTopicModel question, int selectedQuestionIndex) async {
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
    if (kDebugMode) {
      print("Audio update : $path");
    }
    _playAudio(path);
  }

  Future<void> _playAnswerAudio(
      String audioPath, QuestionTopicModel question) async {
    if (kDebugMode) {
      print(
          "DEBUG: Reviewing current index = ${_simulatorTestProvider!.reviewingCurrentIndex} -- play answer");
    }

    await _audioPlayerController!.play(DeviceFileSource(audioPath));
    await _audioPlayerController!.setVolume(2.5);
    _audioPlayerController!.onPlayerComplete.listen((event) {
      _reviewingProcess();
    });
  }

  Future<void> _playAudio(String audioPath) async {
    if (kDebugMode) {
      print("DEBUG: Play audio as FILE PATH $audioPath");
    }
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
          return ReAnswerDialog(context, question, _testRoomPresenter!,
              _simulatorTestProvider!.currentTestDetail.testId.toString(),
              (question) {
            // List<QuestionTopicModel> questions =
            //     _simulatorTestProvider!.questionList;
            // print("question length: ${questions.length.toString()}");
            int index = _simulatorTestProvider!.questionList.indexWhere((q) =>
                q.id == question.id && q.repeatIndex == question.repeatIndex);

            _simulatorTestProvider!.questionList[index] = question;
            //_simulatorTestProvider!.setQuestionList(questions);
          });
        },
      );
    });
  }

  void _playReAnswerCallBack(QuestionTopicModel question) {
    if (_simulatorTestProvider!.doingStatus == DoingStatus.finish) {
      bool isReviewing =
          _simulatorTestProvider!.reviewingStatus == ReviewingStatus.playing;

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
        bool isPart2 = question.numPart == PartOfTest.part2.get;
        _startRecordAnswer(
            fileName: question.files.first.url, isPart2: isPart2);
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
    bool isPart2 = _simulatorTestProvider!.topicsQueue.first.numPart ==
        PartOfTest.part2.get;
    onFinishAnswer(isPart2);
  }

  void _repeatQuestionCallBack(QuestionTopicModel questionTopicModel) async {
    //Stop record
    _setVisibleRecord(false, null, null);

    //Add question into List Question & show it
    _simulatorTestProvider!.addCurrentQuestionIntoList(
      questionTopic: _currentQuestion!,
      repeatIndex: _countRepeat,
      isRepeat: true,
    );

    _countRepeat++;

    TopicModel? topicModel = _getCurrentPart();
    if (null != topicModel) {
      if (topicModel.numPart == PartOfTest.part3.get) {
        bool finishFollowUp = _simulatorTestProvider!.finishPlayFollowUp;
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
        _reviewingQuestionList[_simulatorTestProvider!.reviewingCurrentIndex];
    if (item is String) {
      _simulatorTestProvider!.setIsReviewingPlayAnswer(false);

      //TODO
      // _initVideoController(
      //     fileName: item,
      //     handleWhenFinishType: HandleWhenFinish.reviewingVideoType);
    }
  }

  void _playReviewingQuestionAndAnswer(QuestionTopicModel question) async {
    String fileName = question.files.first.url;
    _playTheQuestionBeforePlayTheAnswer(fileName);
  }

  void _playTheQuestionBeforePlayTheAnswer(String fileName) {
    //TODO
    // _initVideoController(
    //     fileName: fileName,
    //     handleWhenFinishType: HandleWhenFinish.reviewingPlayTheQuestionType);
  }

  void _playTheAnswerOfQuestion(QuestionTopicModel question) async {
    _simulatorTestProvider!.setIsReviewingPlayAnswer(true);

    String path = await Utils.getReviewingAudioPathToPlay(
      question,
      _simulatorTestProvider!.currentTestDetail.testId.toString(),
    );
    _playAnswerAudio(path, question);
  }

  void _continueReviewing() {
    int index = _simulatorTestProvider!.reviewingCurrentIndex + 1;
    _simulatorTestProvider!.updateReviewingCurrentIndex(index);
    dynamic item =
        _reviewingQuestionList[_simulatorTestProvider!.reviewingCurrentIndex];
    if (item is String) {
      _simulatorTestProvider!.setIsReviewingPlayAnswer(false);

      //TODO
      // _initVideoController(
      //     fileName: item,
      //     handleWhenFinishType: HandleWhenFinish.reviewingVideoType);
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
      _startToDoTest();
    }
  }

  void _playNextQuestion() {
    _setIndexOfNextQuestion();
    _startToPlayQuestion();
  }

  void _setIndexOfNextQuestion() {
    int i = _simulatorTestProvider!.indexOfCurrentQuestion;
    _simulatorTestProvider!.setIndexOfCurrentQuestion(i + 1);
  }

  void _setIndexOfNextFollowUp() {
    int i = _simulatorTestProvider!.indexOfCurrentFollowUp;
    _simulatorTestProvider!.setIndexOfCurrentFollowUp(i + 1);
  }

  TopicModel? _getCurrentPart() {
    Queue<TopicModel> topicsQueue = _simulatorTestProvider!.topicsQueue;

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
              print("DEBUG: onPlayEndOfTakeNote(fileName)");
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
      int index = _simulatorTestProvider!.indexOfCurrentQuestion;
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

        //Play next video
        if (_countRepeat == 0) {
          _playingIndex++;
        }
        _initVideoController();
      }
    }
  }

  void _playNextPart() {
    //Remove part which played
    _simulatorTestProvider!.removeTopicsQueueFirst();
    _simulatorTestProvider!.resetIndexOfCurrentQuestion();

    _playingIndex++;
    if (_simulatorTestProvider!.topicsQueue.isEmpty) {
      //No part for next play
      _prepareToEndTheTest();
    } else {
      _testRoomPresenter!.startPart(_simulatorTestProvider!.topicsQueue);
    }
  }

  void _playNextFollowup() {
    _setIndexOfNextFollowUp();
    _startToPlayFollowup();
  }

  void _repeatPlayCurrentFollowup() {
    if (_countRepeat == 2) {
      //Disable repeat button
      _simulatorTestProvider!.setEnableRepeatButton(false);
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
      _simulatorTestProvider!.setFinishPlayFollowUp(true);
      _startToPlayQuestion();
    } else {
      _simulatorTestProvider!.resetIndexOfCurrentQuestion();

      int index = _simulatorTestProvider!.indexOfCurrentFollowUp;
      if (index >= followUpList.length) {
        _simulatorTestProvider!.setFinishPlayFollowUp(true);
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
          if (_countRepeat == 0) {
            _playingIndex++;
          }
          _initVideoController();
        }
      }
    }
  }

  void _repeatPlayCurrentQuestion() {
    if (_countRepeat == 2) {
      //Disable repeat button
      _simulatorTestProvider!.setEnableRepeatButton(false);
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

  void _prepareToRecordAnswer({
    required String fileName,
    required bool isPart2,
  }) {
    if (isPart2) {
      //Has Cue Card case
      _simulatorTestProvider!.setVisibleRecord(false);
      _simulatorTestProvider!.setCurrentQuestion(_currentQuestion!);

      int time = 60; //3 for test, 60 for product
      String timeString = Utils.getTimeRecordString(time);
      _simulatorTestProvider!.setCountDownCueCard(timeString);

      _countDownCueCard = _testRoomPresenter!.startCountDownForCueCard(
        context: context,
        count: time,
        isPart2: false,
      );
      _simulatorTestProvider!.setVisibleCueCard(true);
    } else {
      TopicModel? topicModel = _getCurrentPart();
      List<QuestionTopicModel> questionList = topicModel!.questionList;
      int index = _simulatorTestProvider!.indexOfCurrentQuestion;
      QuestionTopicModel question = questionList.elementAt(index);
      question.numPart = topicModel.numPart;
      _currentQuestion = question;

      _startRecordAnswer(fileName: fileName, isPart2: isPart2);
    }
  }

  void _checkStatusWhenFinishVideo() async {
    if (!_isBackgroundMode) {
      FileTopicModel current =
          _simulatorTestProvider!.listVideoSource[_playingIndex];
      //Check type of video
      switch (current.fileTopicType) {
        case FileTopicType.introduce:
          {
            // _playNextVideo();
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
        case FileTopicType.question:
          {
            //prepare to record answer
            bool isPart2 = current.numPart == PartOfTest.part2.get;
            _prepareToRecordAnswer(fileName: current.url, isPart2: isPart2);
            if (_countRepeat == 0) {
              _calculateIndexOfHeader();
            }
            break;
          }
        case FileTopicType.followup:
          {
            _startRecordAnswer(fileName: current.url, isPart2: false);
            if (!_hasHeaderPart3) {
              _calculateIndexOfHeader();
            }
            break;
          }
        case FileTopicType.end_of_take_note:
          {
            _endOfTakeNoteIndex = 0;
            _startRecordAnswer(fileName: current.url, isPart2: true);
            break;
          }
        case FileTopicType.end_of_test:
          {
            _prepareToEndTheTest();
            break;
          }
        case FileTopicType.answer:
        case FileTopicType.none:
          {
            break;
          }
      }
    } else {
      if (kDebugMode) {
        print("DEBUG: _checkStatusWhenFinishVideo: App is in background mode!");
      }
    }
  }

  Future<void> _initVideoController() async {
    FileTopicModel currentPlayingFile =
        _simulatorTestProvider!.listVideoSource[_playingIndex];
    if (kDebugMode) {
      print("DEBUG: _initVideoController: Playing - ${currentPlayingFile.url}");
    }

    //Remove old listener
    if (_videoPlayerController!.onPlaybackEnded.hasListeners) {
      _videoPlayerController!.onPlaybackEnded
          .removeListener(_checkStatusWhenFinishVideo);
    }

    //Add new listener
    _videoPlayerController!.onPlaybackEnded
        .addListener(_checkStatusWhenFinishVideo);

    if (_playingIndex == 0) {
      _videoPlayerController!.play();
    } else {
      if (_countRepeat != 0) {
        _videoPlayerController!.setPlaybackSpeed(0.95);
      } else {
        _videoPlayerController!.setPlaybackSpeed(1.0);
      }

      _createVideoSource(currentPlayingFile.url).then((value) async {
        _videoPlayerController!.loadVideoSource(value).then((_) {
          _videoPlayerController!.play();
        });
      });

      if (currentPlayingFile.fileTopicType == FileTopicType.introduce ||
          currentPlayingFile.fileTopicType == FileTopicType.end_of_test ||
          currentPlayingFile.fileTopicType == FileTopicType.end_of_take_note) {
        _reviewingList.add(currentPlayingFile.url);
      } else {
        if (null != _currentQuestion) {
          if (!_checkExist(_currentQuestion!)) {
            _reviewingList.add(_currentQuestion!); //Add file
          }
        }
      }
    }
  }

  Future<void> _stopRecord() async {
    String? path = await _recordController!.stop();
    if (kDebugMode) {
      print("DEBUG: RECORD FILE PATH: $path");
    }
  }

  void _setVisibleRecord(bool visible, Timer? count, String? fileName) async {
    if (false == visible) {
      await _stopRecord();
    }

    _simulatorTestProvider!.setVisibleRecord(visible);
    // _simulatorTestProvider!.setCountDownTimer(count); //TODO
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
        encoder: Platform.isAndroid ? AudioEncoder.wav : AudioEncoder.pcm16bit,
        bitRate: 128000,
        samplingRate: 44100,
      );

      List<FileTopicModel> temp = _currentQuestion!.answers;
      if (!_checkAnswerFileExist(newFileName, temp)) {
        temp.add(
            FileTopicModel.fromJson({'id': 0, 'url': newFileName, 'type': 0}));
        _currentQuestion!.answers = temp;
        _simulatorTestProvider!.setCurrentQuestion(_currentQuestion!);
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

  void _reviewingProcess() {
    if (_simulatorTestProvider!.reviewingCurrentIndex <
        _reviewingQuestionList.length) {
      _continueReviewing();
    } else {
      //Finish reviewing
      if (kDebugMode) print("DEBUG: Finish reviewing");
    }
  }

  void _prepareToEndTheTest() async {
    //Stop old record
    await _stopRecord();

    //Reset playingIndex
    _playingIndex = 0;

    _hasHeaderPart3 = false;

    //Finish doing test
    _simulatorTestProvider!.updateReviewingStatus(ReviewingStatus.none);
    _simulatorTestProvider!.updateDoingStatus(DoingStatus.finish);

    List<String> temp = _prepareAnswerListForDelete();
    _simulatorTestProvider!.setAnswerList(temp);

    //Auto submit test for activity type = test
    if (_simulatorTestProvider!.activityType == "test") {
      _startSubmitTest();
    } else {
      //Activity Type = "homework"
      _setVisibleSaveTest(true);
    }
  }

  void _startSubmitTest() {
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
            if (_simulatorTestProvider!.indexOfCurrentQuestion == 0) {
              _simulatorTestProvider!.setIndexOfHeaderPart2(
                  _simulatorTestProvider!.questionList.length);
            }
            break;
          }
        case 3:
          {
            //PART 3
            _hasHeaderPart3 = true;

            if (topicModel.followUp.isNotEmpty) {
              if (_simulatorTestProvider!.indexOfCurrentFollowUp == 0) {
                _simulatorTestProvider!.setIndexOfHeaderPart3(
                    _simulatorTestProvider!.questionList.length);
              }
            } else {
              if (_simulatorTestProvider!.indexOfCurrentQuestion == 0) {
                _simulatorTestProvider!.setIndexOfHeaderPart3(
                    _simulatorTestProvider!.questionList.length);
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

    Queue<TopicModel> queue = _simulatorTestProvider!.topicsQueue;
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
    _simulatorTestProvider!.setVisibleSaveTheTest(isVisible);
  }

  void _gotoMyTestScreen(ActivityAnswer activityAnswer) {
    widget.simulatorTestPresenter.gotoMyTestScreen(activityAnswer);
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

  void _rePlayEndOfTakeNote() {
    _playingIndex = _endOfTakeNoteIndex;
    _initVideoController();
  }

  void _reRecord() {
    FileTopicModel current =
        _simulatorTestProvider!.listVideoSource[_playingIndex];
    //prepare to record answer
    bool isPart2 = current.numPart == PartOfTest.part2.get;
    _prepareToRecordAnswer(fileName: current.url, isPart2: isPart2);
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

    //Enable repeat button
    _simulatorTestProvider!.setEnableRepeatButton(true);

    //Stop record
    _setVisibleRecord(false, null, null);

    if (_simulatorTestProvider!.visibleCueCard) {
      //Has cue card case
      if (isPart2) {
        _simulatorTestProvider!.setVisibleCueCard(false);

        //Add question into List Question & show it
        _simulatorTestProvider!.addCurrentQuestionIntoList(
          questionTopic: _currentQuestion!,
          repeatIndex: _countRepeat,
          isRepeat: false,
        );

        //Reset count repeat
        _countRepeat = 0;

        // _playNextQuestion();
        _playNextPart();
      } else {
        //Reset count repeat
        _countRepeat = 0;
        //Start to play end_of_take_note video
        Queue<TopicModel> topicQueue = _simulatorTestProvider!.topicsQueue;
        TopicModel topic = topicQueue.first;

        _testRoomPresenter!.playEndOfTakeNoteFile(topic);
      }
    } else {
      //Add question or followup into List Question & show it
      _simulatorTestProvider!.addCurrentQuestionIntoList(
        questionTopic: _currentQuestion!,
        repeatIndex: _countRepeat,
        isRepeat: false,
      );

      //Reset count repeat
      _countRepeat = 0;

      TopicModel? topicModel = _getCurrentPart();
      if (null != topicModel) {
        if (topicModel.numPart == PartOfTest.part3.get) {
          bool finishFollowUp = _simulatorTestProvider!.finishPlayFollowUp;
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
  void onPlayEndOfTakeNote(String fileName) {
    if (false == _simulatorTestProvider!.isLoadingVideo) {
      _playingIndex++;
      _endOfTakeNoteIndex = _playingIndex;
      _initVideoController();
    }
  }

  @override
  void onPlayEndOfTest(String fileName) {
    if (false == _simulatorTestProvider!.isLoadingVideo) {
      _playingIndex++;
      _initVideoController();
    }
  }

  @override
  void onPlayIntroduce() {
    if (false == _simulatorTestProvider!.isLoadingVideo) {
      _initVideoController();
    }
  }

  @override
  void onCountDownForCueCard(String countDownString) {
    if (mounted) {
      _simulatorTestProvider!.setCountDownCueCard(countDownString);
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
        return CustomAlertDialog(
          title: "Notify",
          description: "An error occur, please try again later!",
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

  @override
  void onSubmitTestSuccess(String msg, ActivityAnswer activityAnswer) {
    _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.success);

    showToastMsg(
      msg: msg,
      toastState: ToastStatesType.success,
    );

    _gotoMyTestScreen(activityAnswer);
  }

  @override
  void onClickSaveTheTest() async {
    if (SubmitStatus.none == _simulatorTestProvider!.submitStatus ||
        SubmitStatus.fail == _simulatorTestProvider!.submitStatus) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: "Notify",
            description: "Do you want to save this test?",
            okButtonTitle: "Save",
            cancelButtonTitle: "Don't Save",
            borderRadius: 8,
            hasCloseButton: true,
            okButtonTapped: () {
              _startSubmitTest();
            },
            cancelButtonTapped: () {
              Navigator.of(context).pop();
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

  @override
  void onReDownload() {
    _simulatorTestProvider!.setNeedDownloadAgain(true);
  }
}
