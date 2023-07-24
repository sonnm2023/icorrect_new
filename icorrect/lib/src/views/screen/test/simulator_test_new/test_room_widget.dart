import 'dart:async';
import 'dart:collection';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect/src/presenters/test_room_presenter.dart';
import 'package:icorrect/src/provider/play_answer_provider.dart';
import 'package:icorrect/src/provider/prepare_simulator_test_provider.dart';
import 'package:icorrect/src/provider/test_provider.dart';
import 'package:icorrect/src/provider/timer_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/alert_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/confirm_dialog.dart';
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
  const TestRoomWidget({super.key, required this.needUpdate});

  final bool needUpdate;

  @override
  State<TestRoomWidget> createState() => _TestRoomWidgetState();
}

class _TestRoomWidgetState extends State<TestRoomWidget>
    with WidgetsBindingObserver
    implements TestRoomViewContract, ActionAlertListener {
  TestRoomPresenter? _testRoomPresenter;
  TestProvider? _testProvider;
  PrepareSimulatorTestProvider? _prepareSimulatorTestProvider;

  TimerProvider? _timerProvider;
  PlayAnswerProvider? _playAnswerProvider;
  VideoPlayerController? _videoPlayerController;
  final AudioPlayer _audioPlayerController = AudioPlayer();
  final Record _recordController = Record();

  Timer? _countDown;
  QuestionTopicModel? _currentQuestion;
  int _countRepeat = 0;
  final List<String> _reviewingList = [];

  @override
  void didUpdateWidget(covariant TestRoomWidget oldWidget) {
    _doSomething();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _prepareSimulatorTestProvider =
        Provider.of<PrepareSimulatorTestProvider>(context, listen: false);
    _testProvider = Provider.of<TestProvider>(context, listen: false);
    _timerProvider = Provider.of<TimerProvider>(context, listen: false);
    _playAnswerProvider =
        Provider.of<PlayAnswerProvider>(context, listen: false);

    _testRoomPresenter = TestRoomPresenter(this);

    _startToDoTest();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) print("TestRoom-Build");
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
          child: VideoPlayerWidget(playVideo: _playVideo), //TODO
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
                        SaveTheTestWidget(
                            testRoomPresenter: _testRoomPresenter!),
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
    if (_prepareSimulatorTestProvider!.topicsQueue.isNotEmpty) {
      _testProvider!.setTopicsQueue(_prepareSimulatorTestProvider!.topicsQueue);
      _testRoomPresenter!.startPart(_prepareSimulatorTestProvider!.topicsQueue);
    }
  }

  void _doSomething() async {
    //Stop count down timer
    _countDown!.cancel();

    _stopRecording();

    if (_audioPlayerController.state == PlayerState.playing) {
      _audioPlayerController.stop();
    }
    await _audioPlayerController.dispose();

    if (null != _videoPlayerController) {
      if (_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.pause();
      }

      await _videoPlayerController!.dispose();
      _testProvider!.setPlayController(null);
    }

    _testProvider!.resetAll();
    if (null != _testProvider) {
      if (!_testProvider!.isDisposed) {
        _testProvider!.dispose();
      }
    }
  }

  void _stopRecording() async {
    bool isRecording = await _recordController.isRecording();

    if (isRecording) {
      _recordController.stop();
    }
    await _recordController.dispose();
  }

  void _playAnswerCallBack(
      QuestionTopicModel question, int selectedQuestionIndex) async {
    if (_testProvider!.isShowPlayVideoButton) {
      //Stop playing current question
      if (_audioPlayerController.state == PlayerState.playing) {
        await _audioPlayerController.stop().then((_) {
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

    String path = await Utils.getAudioPathToPlay(question);
    _playAudio(path, question.id.toString());
  }

  Future<void> _playAudio(String audioPath, String questionId) async {
    try {
      await _audioPlayerController.play(DeviceFileSource(audioPath));
      await _audioPlayerController.setVolume(2.5);
      _audioPlayerController.onPlayerComplete.listen((event) {
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
            _testRoomPresenter!,
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

  void _cancelButtonTapped() {
    if (kDebugMode) print("_cancelButtonTapped");
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
    _testProvider!.addCurrentQuestionIntoList(
        questionTopic: _currentQuestion!, repeatIndex: _countRepeat);

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

  void _playNextQuestion() {
    //Reset countdown
    _countDown!.cancel();

    _setIndexOfNextQuestion();
    _startToPlayQuestion(needResetAnswerList: true);
  }

  void _setIndexOfNextQuestion() {
    int i = _testProvider!.indexOfCurrentQuestion;
    _testProvider!.setIndexOfCurrentQuestion(i + 1);
  }

  void _setIndexOfNextFollowUp() {
    int i = _testProvider!.indexOfCurrentFollowUp;
    _testProvider!.setIndexOfCurrentFollowUp(i + 1);
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
      _testRoomPresenter!.playEndOfTestFile(topicModel);
    } else {
      int index = _testProvider!.indexOfCurrentQuestion;
      if (index >= questionList.length) {
        //TODO: We played all questions of current part
        //TODO: _playNextPart
        //If current part is part 3 ==> to play end_of_test
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

    _testRoomPresenter!.startPart(_testProvider!.topicsQueue);
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
      _testProvider!.setEnableRepeatButton(false);
    }
    //Reset countdown
    _countDown!.cancel();

    _startToPlayFollowup(needResetAnswerList: false);
  }

  Future<void> _startToPlayFollowup({required bool needResetAnswerList}) async {
    //TODO
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

  void _repeatPlayCurrentQuestion() {
    if (_countRepeat == 2) {
      //Disable repeat button
      _testProvider!.setEnableRepeatButton(false);
    }
    //Reset countdown
    _countDown!.cancel();

    _startToPlayQuestion(needResetAnswerList: false);
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
  void onCountDown(String countDownString) {
    if (mounted) {
      _timerProvider!.setCountDown(countDownString);
    }
  }

  @override
  void onFinishAnswer(bool isPart2) {
    //Reset countdown
    _countDown!.cancel();

    //Reset count repeat
    _countRepeat = 0;

    //Enable repeat button
    _testProvider!.setEnableRepeatButton(true);

    if (_testProvider!.isVisibleCueCard) {
      //Has cue card case
      if (isPart2) {
        //Finish record answer for part2
        _testProvider!.setVisibleRecord(false);
        _testProvider!.setVisibleCueCard(false);

        //Add question into List Question & show it
        _testProvider!.addCurrentQuestionIntoList(
            questionTopic: _currentQuestion!, repeatIndex: _countRepeat);

        _playNextQuestion();
      } else {
        //Start to play end_of_take_note video
        Queue<TopicModel> topicQueue = _testProvider!.topicsQueue;
        TopicModel topic = topicQueue.first;

        _testRoomPresenter!.playEndOfTakeNoteFile(topic);
      }
    } else {
      //Add question or followup into List Question & show it
      _testProvider!.addCurrentQuestionIntoList(
          questionTopic: _currentQuestion!, repeatIndex: _countRepeat);

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
    _initVideoController(
      fileName: fileName,
      handleWhenFinishType: HandleWhenFinish.cueCardVideoType,
    );
  }

  @override
  void onPlayEndOfTest(String fileName) {
    // TODO: implement onPlayEndOfTest
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
    // TODO: implement onSaveTopicListIntoProvider
  }

  Future<void> _initVideoController({
    required String fileName,
    required HandleWhenFinish handleWhenFinishType,
  }) async {
    _setVisibleRecord(false, null, null);
    _testProvider!.setIsLoadingVideo(true);
    _reviewingList.add(fileName); //Add file

    Utils.prepareVideoFile(fileName).then((value) {
      if(kDebugMode) print("Playing: $fileName");

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

  void _setVisibleRecord(bool visible, Timer? count, String? fileName) {
    _testProvider!.setVisibleRecord(visible);

    if (_testProvider!.visibleRecord) {
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
    // String folderPath = await FileStorageHelper.getFolderPath(MediaType.audio);
    // String path = "$folderPath\\$newFileName";
    String path =
        await FileStorageHelper.getFilePath(newFileName, MediaType.audio);

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

  void _checkVideo(String fileName, HandleWhenFinish handleWhenFinishType) {
    if (null != _testProvider!.playController) {
      if (_testProvider!.playController!.value.position ==
          _testProvider!.playController!.value.duration) {
        switch (handleWhenFinishType) {
          case HandleWhenFinish.questionVideoType:
            {
              if (_currentQuestion!.cueCard.isNotEmpty &&
                  (false == _testProvider!.isVisibleCueCard)) {
                //Has Cue Card case
                _testProvider!.setVisibleRecord(false);
                _testProvider!.setCurrentQuestion(_currentQuestion!);
                _countDown = _testRoomPresenter!.startCountDown(
                  context: context,
                  count: 10,
                  isPart2: false,
                ); //For test 10, product 60
                _testProvider!.setVisibleCueCard(true);
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
      return;
    }

    Queue<TopicModel> queue = _testProvider!.topicsQueue;
    int timeRecord = Utils.getRecordTime(queue.first.numPart);

    String timeString = Utils.getTimeRecordString(timeRecord);

    //Record the answer
    _timerProvider!.setCountDown(timeString);

    _countDown = _testRoomPresenter!
        .startCountDown(context: context, count: timeRecord, isPart2: isPart2);
    _setVisibleRecord(true, _countDown, fileName);
  }

  void _setVisibleSaveTest(bool isVisible) {
    _testProvider!.setVisibleSaveTheTest(isVisible);
  }
}
