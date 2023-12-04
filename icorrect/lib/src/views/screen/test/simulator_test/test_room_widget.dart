import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart' as AudioPlayers;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/core/camera_service.dart';
import 'package:icorrect/core/connectivity_service.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/auth_models/video_record_exam_info.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect/src/presenters/simulator_test_presenter.dart';
import 'package:icorrect/src/presenters/test_room_presenter.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/provider/play_answer_provider.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:icorrect/src/provider/timer_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/confirm_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/custom_alert_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/resize_video_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/tip_question_dialog.dart';
import 'package:icorrect/src/views/widget/default_loading_indicator.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/cached_network_image_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/cue_card_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/load_local_image_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/save_test_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/test_question_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/test_record_widget.dart';
import 'package:native_video_player/native_video_player.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

class TestRoomWidget extends StatefulWidget {
  const TestRoomWidget(
      {super.key, this.homeWorkModel, required this.simulatorTestPresenter});

  final ActivitiesModel? homeWorkModel;
  final SimulatorTestPresenter simulatorTestPresenter;

  @override
  State<TestRoomWidget> createState() => _TestRoomWidgetState();
}

class _TestRoomWidgetState extends State<TestRoomWidget>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin<TestRoomWidget>
    implements TestRoomViewContract {
  TestRoomPresenter? _testRoomPresenter;
  SimulatorTestProvider? _simulatorTestProvider;

  TimerProvider? _timerProvider;
  PlayAnswerProvider? _playAnswerProvider;
  NativeVideoPlayerController? _videoPlayerController;
  AudioPlayers.AudioPlayer? _audioPlayerController;
  Record? _recordController;
  late FlutterSoundRecorder _recorder;
  CameraService? _cameraService;

  Timer? _countDown;
  Timer? _countDownCueCard;
  Timer? _countRecording;
  QuestionTopicModel? _currentQuestion;
  int _countRepeat = 0;
  final List<dynamic> _reviewingList = [];
  List<dynamic> _reviewingQuestionList = [];
  int _playingIndex = 0;
  bool _hasHeaderPart3 = false;
  int _endOfTakeNoteIndex = 0;
  bool _isBackgroundMode = false;
  String _reanswerFilePath = "";
  String _originalAnswerFilePath = "";
  CircleLoading? _loading;
  bool _isReDownload = false;
  bool _cameraIsRecording = false;
  bool _isExam = false;
  DateTime? _logStartTime;
  DateTime? _logEndTime;
  //type : 1 out app: play video  , 2 out app: record answer, 3 out app: takenote
  int _typeOfActionLog = 0; //Default
  final connectivityService = ConnectivityService();
  int _questionIndex = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    _audioPlayerController = AudioPlayers.AudioPlayer();

    if (Platform.isIOS) {
      _recordController = Record();
    } else {
      _recorder = FlutterSoundRecorder();
    }

    _simulatorTestProvider =
        Provider.of<SimulatorTestProvider>(context, listen: false);
    _timerProvider = Provider.of<TimerProvider>(context, listen: false);
    _playAnswerProvider =
        Provider.of<PlayAnswerProvider>(context, listen: false);

    _testRoomPresenter = TestRoomPresenter(this);
    _loading = CircleLoading();

    if (widget.homeWorkModel != null) {
      _isExam = widget.homeWorkModel!.activityType == ActivityType.exam.name ||
          widget.homeWorkModel!.activityType == ActivityType.test.name;
    } else {
      _isExam = false;
    }

    if (_isExam) {
      _cameraService = CameraService();
      _cameraService!.initialize(() {
        setState(() {});
      });
    }
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
        _onAppInBackground();
        if (kDebugMode) {
          print('DEBUG: App paused');
        }
        break;
      case AppLifecycleState.inactive:
        if (kDebugMode) {
          print('DEBUG: App inactive');
        }
        break;
      case AppLifecycleState.detached:
        if (kDebugMode) {
          print('DEBUG: App detached');
        }
        break;
      case AppLifecycleState.hidden:
        if (kDebugMode) {
          print('DEBUG:App hidden');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<SimulatorTestProvider>(
      builder: (context, provider, child) {
        if (kDebugMode) {
          print("DEBUG: TestRoomWidget --- build");
        }

        if (provider.visibleRecord) {
          _startVideoRecord();
        }
        bool showSaveTheExamButton = _simulatorTestProvider!.activityType ==
                ActivityType.homework.name ||
            _simulatorTestProvider!.activityType ==
                ActivityType.practice.name ||
            _simulatorTestProvider!.submitStatus == SubmitStatus.fail;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
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
                (_isExam &&
                        _cameraService!.cameraController != null &&
                        provider.visibleCameraLive)
                    ? Container(
                        alignment: Alignment.bottomRight,
                        margin: const EdgeInsets.all(10),
                        child: _buildCameraLive(),
                      )
                    : Container()
              ],
            ),
            Expanded(
              child: Container(
                color: AppColor.defaultGraySlightColor,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    SingleChildScrollView(
                      child: TestQuestionWidget(
                        testRoomPresenter: _testRoomPresenter!,
                        playAnswerCallBack: _playAnswerCallBack,
                        reAnswerCallBack: _reAnswerCallBack,
                        showTipCallBack: _showTipCallBack,
                        simulatorTestProvider: _simulatorTestProvider!,
                        isExam: _isExam,
                      ),
                    ),
                    const CueCardWidget(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Consumer<SimulatorTestProvider>(
                          builder: (context, simulatorTestProvider, _) {
                            return Expanded(
                              child: simulatorTestProvider.questionHasImage
                                  ? Container(
                                      decoration: const BoxDecoration(
                                        color: AppColor.defaultAppColor,
                                      ),
                                      child: Center(
                                        child: simulatorTestProvider
                                                .questionImageUrlFromLocal
                                                .isNotEmpty
                                            ? LoadLocalImageWidget(
                                                imageUrl: simulatorTestProvider
                                                    .questionImageUrlFromLocal,
                                                isInRow: false,
                                              )
                                            : CachedNetworkImageWidget(
                                                imageUrl: simulatorTestProvider
                                                    .questionImageUrl,
                                                isInRow: false,
                                              ),
                                      ),
                                    )
                                  : const SizedBox(),
                            );
                          },
                        ),
                        SizedBox(
                          height: 200,
                          child: Stack(
                            children: [
                              TestRecordWidget(
                                finishAnswer: _finishAnswerCallBack,
                                repeatQuestion: _repeatQuestionCallBack,
                                cancelReAnswer: _cancelReanswerCallBack,
                              ),
                              showSaveTheExamButton
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
              ),
            )
          ],
        );
      },
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
                          _simulatorTestProvider!
                              .updateDoingStatus(DoingStatus.doing);
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
                  child: GestureDetector(
                    onTap: () {
                      //Update reviewing status from playing -> pause
                      //show/hide pause button
                      if (simulatorTestProvider.doingStatus !=
                          DoingStatus.doing) {
                        if (simulatorTestProvider.reviewingStatus ==
                            ReviewingStatus.playing) {
                          simulatorTestProvider
                              .updateReviewingStatus(ReviewingStatus.pause);
                        }
                      }
                    },
                  ),
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
      },
    );
  }

  @override
  void onCountRecordingVideo(int currentCount) {
    if (kDebugMode) {
      print("RECORDING_VIDEO: onCountRecording : $currentCount ");
    }
    _simulatorTestProvider!.setCurrentCountRecordingVideo(currentCount);
  }

  void _startVideoRecord() {
    if (_canRecordingCamera()) {
      if (_countRecording != null) {
        _countRecording!.cancel();
      }
      if (kDebugMode) {
        print("RECORDING_VIDEO: Start Recording Video");
      }
      _countRecording = _testRoomPresenter!.startCountRecording();
      _cameraService!.startCameraRecording();
      _cameraIsRecording = true;
    }
  }

  bool _canRecordingCamera() {
    return _cameraService != null &&
        _cameraService!.cameraController!.value.isInitialized &&
        !_cameraIsRecording &&
        !_cameraService!.cameraController!.value.isRecordingVideo;
  }

  void _saveVideoRecording() {
    if (null != _countRecording) {
      _countRecording!.cancel();
    }
    if (_cameraService != null &&
        _cameraService!.cameraController!.value.isRecordingVideo) {
      _cameraService!.saveVideoDoingTest((savedFile) {
        VideoExamRecordInfo examRecordInfo = VideoExamRecordInfo(
            questionId: _simulatorTestProvider!.currentQuestion.id,
            filePath: savedFile.path,
            duration: _simulatorTestProvider!.currentCountRecordingVideo);
        _simulatorTestProvider!.addVideoRecorded(examRecordInfo);
        _simulatorTestProvider!.setCurrentCountRecordingVideo(0);
        _cameraIsRecording = true;
      });
      if (kDebugMode) {
        print("RECORDING_VIDEO :Stop Recoring");
      }
    }
  }

  void _hideCameraLive() {
    if (_isExam) {
      if (null != _countRecording) {
        _countRecording!.cancel();
      }
      _simulatorTestProvider!.setVisibleCameraLive(false);

      if (null == _cameraService) {
        return;
      }

      _saveVideoRecording();
    }
  }

  Widget _buildCameraLive() {
    double w = MediaQuery.of(context).size.width;
    double h = 200;
    final radius = BorderRadius.circular(10);
    return Container(
      width: w / 4,
      height: h / 1.7,
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.defaultPurpleColor, width: 2),
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
                height: 1,
                child: AspectRatio(
                  aspectRatio: 1 / 2,
                  child: CameraPreview(_cameraService!.cameraController!),
                )),
          ),
        ),
      ),
    );
  }

  Future<void> _initController(NativeVideoPlayerController controller) async {
    if (_simulatorTestProvider!.listVideoSource.isNotEmpty) {
      _videoPlayerController = controller;
      _videoPlayerController!.setVolume(1.0);
      await _loadVideoSource(
              _simulatorTestProvider!.listVideoSource[_playingIndex].url)
          .then((_) {
        _videoPlayerController!.stop();
      });
    }
  }

  Future<void> _loadVideoSource(String fileName) async {
    VideoSource? videoSource = await _createVideoSource(fileName);
    if (null == videoSource) {
      if (kDebugMode) {
        print("DEBUG: _loadVideoSource fail");
      }
    } else {
      // final videoSource = await _createVideoSource(fileName);
      await _videoPlayerController!.loadVideoSource(videoSource);
    }
  }

  Future<VideoSource?> _createVideoSource(String fileName) async {
    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.createVideoSource);
    }
    Map<String, dynamic> dataLog = {};

    String path =
        await FileStorageHelper.getFilePath(fileName, MediaType.video, null);

    dataLog["video_path"] = path;

    VideoSource? result;

    bool isExist = await Utils.checkVideoFileExist(path, MediaType.video);
    if (isExist) {
      try {
        result = await VideoSource.init(
          path: path,
          type: VideoSourceType.file,
        );
        if (kDebugMode) {
          print("DEBUG: init video controller: $result");
        }

        //Add log
        Utils.prepareLogData(
          log: log,
          data: dataLog,
          message: "",
          status: LogEvent.success,
        );
      } catch (e) {
        if (kDebugMode) {
          print("DEBUG: init video controller fail");
        }

        //Add log
        Utils.prepareLogData(
          log: log,
          data: dataLog,
          message: "Can not init video controller!",
          status: LogEvent.failed,
        );

        result = null;
      }
    } else {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "This video is NOT exist!",
        status: LogEvent.failed,
      );

      result = null;
    }
    return result;
  }

  void _createLog(
      {required String action, required Map<String, dynamic>? data}) async {
    if (context.mounted) {
      //Add action log
      LogModel actionLog =
          await Utils.prepareToCreateLog(context, action: action);
      if (null != data) {
        if (data.isNotEmpty) {
          actionLog.addData(
              key: StringConstants.k_data, value: jsonEncode(data));
        }
      }
      Utils.addLog(actionLog, LogEvent.none);
    }
  }

  void _startToDoTest() {
    Map<String, dynamic> info = {
      StringConstants.k_test_id:
          _simulatorTestProvider!.currentTestDetail.testId.toString(),
    };
    if (widget.homeWorkModel != null) {
      info.addEntries([
        MapEntry(StringConstants.k_activity_id,
            widget.homeWorkModel!.activityId.toString())
      ]);
    }
    _createLog(action: LogEvent.actionStartToDoTest, data: info);

    _initVideoController(isIntroduceVideo: false);
  }

  Future _onAppInBackground() async {
    _isBackgroundMode = true;

    //Create start time to save log
    _logStartTime = DateTime.now();
    if (kDebugMode) {
      print("DEBUG: action log starttime: $_logStartTime");
    }

    if (null != _videoPlayerController) {
      bool isPlaying = await _videoPlayerController!.isPlaying();
      if (isPlaying) {
        _typeOfActionLog = 1;
        _videoPlayerController!.stop();
      }

      if (_simulatorTestProvider!.visibleRecord) {
        _typeOfActionLog = 2;
        int numPart = _simulatorTestProvider!.currentQuestion.numPart;

        //TODO
        if (Platform.isIOS) {
          if (numPart == PartOfTest.part2.get &&
              await _recordController!.isRecording()) {
            _recordController!.pause();
          } else {
            _recordController!.stop();
          }
        } else {
          if (numPart == PartOfTest.part2.get && _recorder.isRecording) {
            _recorder.pauseRecorder();
          } else {
            _stopRecord();
          }
        }

        if (null != _countDown) {
          _countDown!.cancel();
        }

        if (null != _countDownCueCard) {
          _countDownCueCard!.cancel();
        }
      } else {
        if (null != _countDownCueCard) {
          _typeOfActionLog = 3;
        }
      }

      if (_audioPlayerController!.state == AudioPlayers.PlayerState.playing) {
        _audioPlayerController!.stop();
        _playAnswerProvider!.resetSelectedQuestionIndex();
      }
    }

    if (null != _countRecording) {
      _countRecording!.cancel();
    }

    if (_isExam) {
      if (null == _cameraService) return;

      if (null == _cameraService!.cameraController) return;

      CameraController? cameraController = _cameraService!.cameraController;

      if (cameraController != null && cameraController.value.isInitialized) {
        cameraController.pausePreview();
        if (cameraController.value.isRecordingVideo) {
          cameraController.pauseVideoRecording();
        }
      }
    }
  }

  void _resetActionLogTimes() {
    _logStartTime = null;
    _logEndTime = null;
  }

  Future _onAppActive() async {
    _isBackgroundMode = false;

    //Calculation time of being out and save into a action log
    if (null != _logStartTime && null != _currentQuestion) {
      _logEndTime = DateTime.now();
      if (kDebugMode) {
        print("DEBUG: action log endtime: $_logEndTime");
      }

      int second = Utils.getBeingOutTimeInSeconds(_logStartTime!, _logEndTime!);

      var jsonData = {
        StringConstants.k_question_id: _currentQuestion!.id.toString(),
        StringConstants.k_question_text: _currentQuestion!.content,
        StringConstants.k_type: _typeOfActionLog,
        StringConstants.k_time: second
      };

      _resetActionLogTimes();

      //Add action log
      _simulatorTestProvider!.addLogActions(jsonData);
    }

    if (_simulatorTestProvider!.doingStatus == DoingStatus.finish) {
      if (_audioPlayerController != null) {
        //Re play answer audio
      } else if (_simulatorTestProvider!.visibleRecord == true) {
        //Re record reanswer
        // _reRecordReanswer();
      }

      if (_simulatorTestProvider!.submitStatus != SubmitStatus.success ||
          _simulatorTestProvider!.needUpdateReanswer) {
        _hideCameraLive();
        _simulatorTestProvider!.setVisibleSaveTheTest(true);
      }
    } else {
      if (null != _videoPlayerController) {
        if (_simulatorTestProvider!.visibleCueCard) {
          //Playing end_of_take_note ==> replay end_of_take_note

          if (_endOfTakeNoteIndex != 0) {
            _rePlayEndOfTakeNote();
          } else if (_simulatorTestProvider!.visibleRecord) {
            _continueRecordPart2();
          }

          //Recording the answer for Part 2 ==> Re record the answer
        } else {
          if (_simulatorTestProvider!.doingStatus != DoingStatus.finish &&
              _simulatorTestProvider!.reviewingStatus != ReviewingStatus.none &&
              _isReDownload == false &&
              _simulatorTestProvider!.visibleRecord == false) {
            _videoPlayerController!.play();
          } else if (_simulatorTestProvider!.visibleRecord == true) {
            _reRecordAnswer();
          }
        }
      }
    }

    if (_isExam) {
      if (null == _cameraService) return;

      if (null == _cameraService!.cameraController) return;

      CameraController cameraController = _cameraService!.cameraController!;

      if (cameraController.value.isInitialized) {
        if (cameraController.value.isPreviewPaused) {
          cameraController.resumePreview();
        }

        if (cameraController.value.isRecordingPaused) {
          cameraController.resumeVideoRecording();
          if (null != _countRecording) {
            _countRecording!.cancel();
          }
          int countFrom = _simulatorTestProvider!.currentCountRecordingVideo;
          _countRecording =
              _testRoomPresenter!.startCountRecording(countFrom: countFrom);
        }
      }
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

    if (null != _countRecording) {
      _countRecording!.cancel();
    }

    await _stopRecord();
    // await _recordController!.dispose();//TODO

    if (null != _cameraService) {
      _cameraService!.dispose();
    }

    if (_audioPlayerController!.state == AudioPlayers.PlayerState.playing) {
      _audioPlayerController!.stop();
    }

    if (null != _videoPlayerController) {
      _videoPlayerController = null;
    }
  }

  void _playAnswerCallBack(
    QuestionTopicModel question,
    int selectedQuestionIndex,
  ) async {
    if (_simulatorTestProvider!.submitStatus == SubmitStatus.submitting) {
      return;
    }

    if (_simulatorTestProvider!.doingStatus == DoingStatus.finish) {
      //Stop playing current question
      if (_audioPlayerController!.state == AudioPlayers.PlayerState.playing) {
        await _audioPlayerController!.stop().then(
          (_) {
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
          },
        );
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
      _showWaitUntilTheExamFinishedDialog();
    }
  }

  void _startPlayAudio({
    required QuestionTopicModel question,
    required int selectedQuestionIndex,
  }) async {
    _playAnswerProvider!.setSelectedQuestionIndex(selectedQuestionIndex);

    String path = await Utils.createNewFilePath(
        question.answers[question.repeatIndex].url);
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

    await _audioPlayerController!
        .play(AudioPlayers.DeviceFileSource(audioPath));
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
      await _audioPlayerController!
          .play(AudioPlayers.DeviceFileSource(audioPath));
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

  // void _showReAnswerDialog(QuestionTopicModel question) {
  //   Future.delayed(
  //     Duration.zero,
  //     () async {
  //       showDialog(
  //         context: context,
  //         barrierDismissible: false,
  //         builder: (context) {
  //           return ReAnswerDialog(
  //             context,
  //             question,
  //             _testRoomPresenter!,
  //             _simulatorTestProvider!.currentTestDetail.testId.toString(),
  //             (question) {
  //               int index = _simulatorTestProvider!.questionList.indexWhere(
  //                   (q) =>
  //                       q.id == question.id &&
  //                       q.repeatIndex == question.repeatIndex);

  //               _simulatorTestProvider!.questionList[index] = question;

  //               _simulatorTestProvider!.setVisibleSaveTheTest(true);
  //             },
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  void _reAnswerCallBack(QuestionTopicModel question) async {
    if (_simulatorTestProvider!.submitStatus == SubmitStatus.submitting) {
      return;
    }

    if (_simulatorTestProvider!.doingStatus == DoingStatus.finish) {
      bool isReviewing =
          _simulatorTestProvider!.reviewingStatus == ReviewingStatus.playing;

      if (isReviewing) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ConfirmDialogWidget(
              title: Utils.multiLanguage(StringConstants.dialog_title),
              message: Utils.multiLanguage(
                StringConstants.confirm_reanswer_when_reviewing_message,
              ),
              cancelButtonTitle:
                  Utils.multiLanguage(StringConstants.cancel_button_title),
              okButtonTitle:
                  Utils.multiLanguage(StringConstants.ok_button_title),
              cancelButtonTapped: _cancelButtonTapped,
              okButtonTapped: () {
                //TODO: Pause reviewing process

                //Show re-answer dialog
                // _showReAnswerDialog(question);

                //TODO
                // _simulatorTestProvider!
                //     .setReanswerAction(true, index, question);
              },
            );
          },
        );
      } else {
        if (_audioPlayerController!.state == AudioPlayers.PlayerState.playing) {
          _audioPlayerController!.stop();
          _playAnswerProvider!.resetSelectedQuestionIndex();
        }

        bool isPart2 = question.numPart == PartOfTest.part2.get;

        //Save into current question
        _currentQuestion = question;

        _prepareRecordForReanswer(
          fileName: question.answers[question.repeatIndex].url,
          numPart: question.numPart,
          isPart2: isPart2,
        );
      }
    } else {
      _showWaitUntilTheExamFinishedDialog();
    }
  }

  void _showWaitUntilTheExamFinishedDialog() {
    showToastMsg(
      msg: Utils.multiLanguage(
          StringConstants.wait_until_the_exam_finished_message),
      toastState: ToastStatesType.warning,
    );
  }

  void _cancelButtonTapped() {
    if (kDebugMode) {
      print("DEBUG: _cancelButtonTapped");
    }
  }

  void _showTipCallBack(QuestionTopicModel question) {
    if (_simulatorTestProvider!.submitStatus == SubmitStatus.submitting) {
      return;
    }

    _showTip(question);
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
    Map<String, dynamic> info = {
      StringConstants.k_question_id: questionTopicModel.id.toString(),
      StringConstants.k_question_content: questionTopicModel.content,
    };

    if (_simulatorTestProvider!.doingStatus == DoingStatus.finish) {
      _createLog(action: LogEvent.actionFinishReAnswer, data: info);

      //Finish re answer
      onFinishForReAnswer();
    } else {
      //Finish answer
      bool isPart2 = false;

      if (_simulatorTestProvider!.topicsQueue.isNotEmpty) {
        isPart2 = _simulatorTestProvider!.topicsQueue.first.numPart ==
            PartOfTest.part2.get;
      } else {
        isPart2 = questionTopicModel.numPart == PartOfTest.part2.get;
      }

      _createLog(action: LogEvent.actionFinishAnswer, data: info);

      if (_isExam) {
        //Increase question index
        _questionIndex++;
        //Call api test-position
        _callTestPositionApi();
      }

      onFinishAnswer(isPart2);
    }
  }

  void _callTestPositionApi() {
    if (widget.homeWorkModel != null) {
      String activityId = widget.homeWorkModel!.activityId.toString();
      _testRoomPresenter!.callTestPositionApi(
        context,
        activityId: activityId,
        questionIndex: _questionIndex,
      );
    }
  }

  void _cancelReanswerCallBack() async {
    if (kDebugMode) {
      print("DEBUG: _cancelReanswerCallBack");
    }
    _resetDataAfterReanswer(isCancel: true);
  }

  void _resetDataAfterReanswer({required bool isCancel}) async {
    String path = "";
    if (isCancel) {
      //Delete reanswer file
      path = _reanswerFilePath;
    } else {
      //Delete original answer file
      path = _originalAnswerFilePath;
    }

    if (File(path).existsSync()) {
      await File(path).delete();
      if (kDebugMode) {
        print("DEBUG: File Record is delete: ${File(path).existsSync()}");
      }
    }

    _reanswerFilePath = "";
    _originalAnswerFilePath = "";

    //Show SAVE THE TEST when re answer
    if (_simulatorTestProvider!.doingStatus == DoingStatus.finish) {
      _hideCameraLive();
      _simulatorTestProvider!.setVisibleSaveTheTest(true);
    }
    _currentQuestion = null;
    _countDown!.cancel();
    if (Platform.isIOS) {
      _recordController!.stop();
    } else {
      _stopRecord();
    }
    _simulatorTestProvider!.setVisibleRecord(false);
  }

  void _resetEnableFinishStatus() {
    _simulatorTestProvider!.setEnabledFinish(true);
  }

  void _resetQuestionImage() {
    if (_simulatorTestProvider!.questionHasImage) {
      _simulatorTestProvider!.setQuestionHasImageStatus(false);
      _simulatorTestProvider!.resetQuestionImageUrl();
      _simulatorTestProvider!.resetQuestionImageUrlFromLocal();
    }
  }

  void _repeatQuestionCallBack(QuestionTopicModel questionTopicModel) async {
    //Comment from build release 1.1.9 (build 1) 2023-11-29 16:55
    //Check answer of user must be greater than 2 seconds
    // if (_checkAnswerDuration()) {
    //   _resetEnableFinishStatus();
    //   return;
    // }

    Map<String, dynamic> info = {
      StringConstants.k_question_id: questionTopicModel.id.toString(),
      StringConstants.k_question_content: questionTopicModel.content,
    };
    _createLog(action: LogEvent.actionRepeatQuestion, data: info);

    //Stop record
    _setVisibleRecord(false, null, null);

    //Reset question image
    _resetQuestionImage();

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
        msg: Utils.multiLanguage(StringConstants.feature_not_available_message),
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
        _initVideoController(isIntroduceVideo: false);
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
          _initVideoController(isIntroduceVideo: false);
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

  void _prepareStep1RecordAnswer({
    required String fileName,
    required bool isPart2,
  }) async {
    if (isPart2) {
      //Has Cue Card case
      _simulatorTestProvider!.setVisibleRecord(false);
      _simulatorTestProvider!.setCurrentQuestion(_currentQuestion!);

      int time = widget.simulatorTestPresenter.testDetail!
          .takeNoteTime; //60; //3 for test, 60 for product
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

      //TODO: Need check again here
      // if (questionList.isEmpty) return;
      // if (index >= questionList.length) return;

      QuestionTopicModel question = questionList.elementAt(index);
      question.numPart = topicModel.numPart;
      _currentQuestion = question;

      _prepareRecordForAnswer(fileName: fileName, isPart2: isPart2);
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
            String fileName = current.id.toString();
            _prepareStep1RecordAnswer(fileName: fileName, isPart2: isPart2);
            if (_countRepeat == 0) {
              _calculateIndexOfHeader();
            }
            break;
          }
        case FileTopicType.followup:
          {
            _prepareRecordForAnswer(fileName: current.url, isPart2: false);
            if (!_hasHeaderPart3) {
              _calculateIndexOfHeader();
            }
            break;
          }
        case FileTopicType.end_of_take_note:
          {
            _endOfTakeNoteIndex = 0;
            _prepareRecordForAnswer(fileName: current.url, isPart2: true);
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

  void _showQuestionImage() async {
    TopicModel? topicModel = _getCurrentPart();
    List<QuestionTopicModel> questionList = topicModel!.questionList;
    int index = _simulatorTestProvider!.indexOfCurrentQuestion;

    if (index >= questionList.length) {
      return;
    }

    QuestionTopicModel question = questionList.elementAt(index);
    question.numPart = topicModel.numPart;

    //Validate question with image
    bool hasImage = Utils.checkHasImage(question: question);
    if (hasImage) {
      String fileName = question.files.last.url;
      String imageUrl = downloadFileEP(fileName);
      if (kDebugMode) {
        print(
            "DEBUG: This question has an image: url = $imageUrl \t question: ${question.id} - ${question.content}");
      }
      //Update has image status in provider
      _simulatorTestProvider!.setQuestionHasImageStatus(true);
      _simulatorTestProvider!.setQuestionImageUrl(imageUrl);
      String localImagePath = await Utils.getLocalImagePath(fileName);
      _simulatorTestProvider!.setQuestionImageUrlFromLocal(localImagePath);
    }
  }

  Future<void> _initVideoController({required isIntroduceVideo}) async {
    if (_simulatorTestProvider!.playingIndexWhenReDownload != 0) {
      _playingIndex = _simulatorTestProvider!.playingIndexWhenReDownload;

      //Reset _playingIndexWhenReDownload
      _simulatorTestProvider!.setPlayingIndexWhenReDownload(0);
    }
    FileTopicModel currentPlayingFile =
        _simulatorTestProvider!.listVideoSource[_playingIndex];
    if (kDebugMode) {
      print("DEBUG: _initVideoController: Playing - ${currentPlayingFile.url}");
    }

    Map<String, dynamic> info = {
      StringConstants.k_file_id: currentPlayingFile.id.toString(),
      StringConstants.k_file_url: currentPlayingFile.url,
    };
    _createLog(action: LogEvent.actionPlayVideoQuestion, data: info);

    //Remove old listener
    // ignore: invalid_use_of_protected_member
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
      switch (_countRepeat) {
        case 0:
          {
            _videoPlayerController!.setPlaybackSpeed(
                _simulatorTestProvider!.currentTestDetail.normalSpeed);
            break;
          }
        case 1:
          {
            _videoPlayerController!.setPlaybackSpeed(
                _simulatorTestProvider!.currentTestDetail.firstRepeatSpeed);
            break;
          }
        case 2:
          {
            _videoPlayerController!.setPlaybackSpeed(
                _simulatorTestProvider!.currentTestDetail.secondRepeatSpeed);
            break;
          }
      }

      _createVideoSource(currentPlayingFile.url).then((value) async {
        if (kDebugMode) {
          print(
              "DEBUG: _createVideoSource: ${currentPlayingFile.url} - $value");
        }
        if (null == value) {
          if (kDebugMode) {
            print("DEBUG: ReDownload here");
          }
          _isReDownload = true;
          _simulatorTestProvider!.setPlayingIndexWhenReDownload(_playingIndex);
          _redownload();
        } else {
          try {
            if (kDebugMode) {
              print("DEBUG: _videoPlayerController!.loadVideoSource");
            }

            _videoPlayerController!.loadVideoSource(value).then((_) {
              _videoPlayerController!.play();

              if (!isIntroduceVideo) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  _showQuestionImage();
                });
              }
            });
          } catch (e) {
            //Add log
            LogModel? log;
            Map<String, dynamic> dataLog = {"error": e.toString()};

            if (context.mounted) {
              log = await Utils.prepareToCreateLog(context,
                  action: LogEvent.callApiSubmitTest);
            }
            //Add log
            Utils.prepareLogData(
              log: log,
              data: dataLog,
              message: "_videoPlayerController!.loadVideoSource",
              status: LogEvent.failed,
            );
          }
        }
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

  void _redownload() async {
    _simulatorTestProvider!.setNeedDownloadAgain(true);
    _simulatorTestProvider!.setIsReDownload(true);
    _setVisibleRecord(false, null, null);

    if (null != _videoPlayerController) {
      bool isPlaying = await _videoPlayerController!.isPlaying();
      if (isPlaying) {
        _videoPlayerController!.stop();
      }

      if (_simulatorTestProvider!.visibleRecord) {
        if (Platform.isIOS) {
          _recordController!.stop();
        } else {
          _stopRecord();
        }

        if (null != _countDown) {
          _countDown!.cancel();
        }

        if (null != _countDownCueCard) {
          _countDownCueCard!.cancel();
        }
      }

      if (_audioPlayerController!.state == AudioPlayers.PlayerState.playing) {
        _audioPlayerController!.stop();
        _playAnswerProvider!.resetSelectedQuestionIndex();
      }
    }
  }

  Future<void> _stopRecord() async {
    if (Platform.isIOS) {
      String? path = await _recordController!.stop(); //TODO
      if (kDebugMode) {
        print("DEBUG: RECORD FILE PATH: $path");
      }
    } else {
      if (_recorder.isRecording) {
        String? recordFilePath = await _recorder.stopRecorder();
        await _recorder.closeRecorder();
        if (recordFilePath != null) {
          if (kDebugMode) {
            print("DEBUG: recordFilePath: $recordFilePath");
          }
        } else {
          if (kDebugMode) {
            print("DEBUG: recordFilePath: FAIL");
          }
        }
      }
    }
  }

  void _setVisibleRecord(bool visible, Timer? count, String? fileName) async {
    if (false == visible) {
      await _stopRecord();
    } else {
      _resetEnableFinishStatus();
    }

    _simulatorTestProvider!.setVisibleRecord(visible);
    _cameraIsRecording = !visible;
  }

  Future<void> _recordAnswer(String fileName) async {
    String newFileName =
        "${await _createLocalAudioFileName(_simulatorTestProvider!.currentTestDetail.testId.toString(), fileName)}.wav";
    String path = await Utils.createNewFilePath(newFileName);

    if (kDebugMode) {
      print("DEBUG: RECORD AS FILE PATH: $path");
    }

    Map<String, dynamic> info = {
      StringConstants.k_file_path: path,
    };
    _createLog(action: LogEvent.actionRecordAnswer, data: info);

    try {
      if (Platform.isIOS) {
        await _recordController!.start(
          path: path,
          encoder:
              Platform.isAndroid ? AudioEncoder.wav : AudioEncoder.pcm16bit,
          bitRate: 128000,
          samplingRate: 44100,
        );
      } else {
        await _recorder.openRecorder();
        await _recorder.startRecorder(
          codec: Codec.pcm16WAV,
          toFile: path,
          sampleRate: 44100,
          bitRate: 128000,
        );
      }

      List<FileTopicModel> temp = _currentQuestion!.answers;
      if (!_checkAnswerFileExist(newFileName, temp)) {
        temp.add(
            FileTopicModel.fromJson({'id': 0, 'url': newFileName, 'type': 0}));
        _currentQuestion!.answers = temp;
        _simulatorTestProvider!.setCurrentQuestion(_currentQuestion!);
      }
    } catch (e) {
      if (kDebugMode) {
        print("DEBUG: init record audio FAIL: ${e.toString()}");
      }
      //Add log
      LogModel? log;
      Map<String, dynamic>? dataLog = {};

      if (context.mounted) {
        log = await Utils.prepareToCreateLog(context,
            action: LogEvent.crash_bug_audio_record);
      }

      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: e.toString(),
        status: LogEvent.failed,
      );
    }
  }

  Future<void> _recordForReAnswer(String fileName) async {
    _reanswerFilePath = '${await Utils.generateAudioFileName()}.$fileName';
    _originalAnswerFilePath = await Utils.createNewFilePath(fileName);

    String path = await Utils.createNewFilePath(_reanswerFilePath);

    if (kDebugMode) {
      print("DEBUG: RECORD AS FILE PATH: $path");
    }

    if (Platform.isIOS) {
      await _recordController!.start(
        path: path,
        encoder: Platform.isAndroid ? AudioEncoder.wav : AudioEncoder.pcm16bit,
        bitRate: 128000,
        samplingRate: 44100,
      );
    } else {
      await _recorder.openRecorder();
      await _recorder.startRecorder(
        codec: Codec.pcm16WAV,
        toFile: path,
        sampleRate: 44100,
        bitRate: 128000,
      );
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

  Future<String> _createLocalAudioFileName(String testId, String origin) async {
    String fileName = "";
    final split = origin.split('.');
    if (_countRepeat > 0) {
      fileName = '${testId}_repeat_${_countRepeat.toString()}_${split[0]}';
    } else {
      fileName = '${testId}_answer_${split[0]}';
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

    // if (null != _cameraService) {
    //   _cameraService!.dispose();
    // }

    //Reset playingIndex
    _playingIndex = 0;

    _hasHeaderPart3 = false;

    //Finish doing test
    _simulatorTestProvider!.updateReviewingStatus(ReviewingStatus.none);
    _simulatorTestProvider!.updateDoingStatus(DoingStatus.finish);

    List<String> temp = _prepareAnswerListForDelete();
    _simulatorTestProvider!.setAnswerList(temp);

    //Hide cameraLive
    if (_isExam) {
      if (null != _countRecording) {
        _countRecording!.cancel();
      }
      _simulatorTestProvider!.setVisibleCameraLive(false);

      if (null == _cameraService) {
        return;
      }
      //_cameraService!.dispose();
    }

    //Auto submit test for activity type = test or type = exam
    if (_isExam) {
      _showResizeVideoDialog();
    } else {
      //Activity Type = "homework"
      _setVisibleSaveTest(true);
    }
  }

  Future<void> _showResizeVideoDialog() async {
    String savedVideoPath = _testRoomPresenter!
        .getVideoLongestDuration(_simulatorTestProvider!.videosSaved);

    double sizeFile = File(savedVideoPath).lengthSync() / (1024 * 1024);
    if (kDebugMode) {
      print("RECORDING_VIDEO : Video Random saved to $savedVideoPath,"
          " size : ${File(savedVideoPath).lengthSync() / 1024}kb, "
          "size ${(File(savedVideoPath).lengthSync() / 1024) / 1024}mb");
    }
    if (sizeFile > 40) {
      _startResizeVideo(savedVideoPath);
    } else {
      _startSubmitTest(videoConfirmFile: File(savedVideoPath));
      _simulatorTestProvider!.setVideoFile(File(savedVideoPath));
    }
  }

  void _startResizeVideo(String savedVideoPath) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (builderContext) {
        return WillPopScope(
            child: ResizeVideoDialog(
                videoFile: File(savedVideoPath),
                isVideoExam: true,
                onResizeCompleted: (resizedFile) {
                  _startSubmitTest(videoConfirmFile: resizedFile);
                  _simulatorTestProvider!.setVideoFile(resizedFile);
                },
                onSubmitNow: () {
                  _startSubmitTest();
                },
                onErrorResizeFile: () {
                  if (kDebugMode) {
                    print('DEBUG: Error when compress video');
                  }
                  _startSubmitTest();
                }),
            onWillPop: () async {
              return false;
            });
      },
    );
  }

  void _startSubmitTest({File? videoConfirmFile}) {
    _createLog(action: LogEvent.actionSubmitTest, data: null);

    _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.submitting);

    List<QuestionTopicModel> questions = _prepareQuestionListForSubmit();

    String activityId = "";
    if (widget.homeWorkModel != null) {
      activityId = widget.homeWorkModel!.activityId.toString();
    }
    _testRoomPresenter!.submitTest(
      context: context,
      testId: _simulatorTestProvider!.currentTestDetail.testId.toString(),
      activityId: activityId,
      questions: questions,
      isExam: _isExam,
      videoConfirmFile: videoConfirmFile,
      logAction: _simulatorTestProvider!.logActions,
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

  int _getRecordTime(int type) {
    switch (type) {
      case 0: //Answer for question in introduce
      case 1: //Answer for question in part 1
        return widget.simulatorTestPresenter.testDetail!.part1Time;
      case 2: //Answer for question in part 2
        return widget.simulatorTestPresenter.testDetail!.part2Time;
      case 3: //Answer for question in part 3
        return widget.simulatorTestPresenter.testDetail!.part3Time;
      default:
        return 0;
    }
  }

  void _prepareRecordForReanswer({
    required String fileName,
    required int numPart,
    required bool isPart2,
  }) async {
    //Hide SAVE THE TEST when re answer
    if (_simulatorTestProvider!.doingStatus == DoingStatus.finish) {
      _simulatorTestProvider!.setVisibleSaveTheTest(false);
    }

    int timeRecord = _getRecordTime(numPart);
    String timeString = Utils.getTimeRecordString(timeRecord);

    //Record the answer
    _timerProvider!.setCountDown(timeString);

    if (null != _countDown) {
      _countDown!.cancel();
    }

    _simulatorTestProvider!.setIsLessThan2Second(true);
    _countDown = _testRoomPresenter!.startCountDown(
        context: context,
        count: timeRecord,
        isPart2: isPart2,
        isReAnswer: true,
        isLessThan2Seconds: true);

    _setVisibleRecord(true, _countDown, fileName);

    _recordForReAnswer(fileName);
  }

  void _prepareRecordForAnswer({
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
    //TODO
    int timeRecord = _getRecordTime(queue.first.numPart);
    // int timeRecord = Utils.getRecordTime(queue.first.numPart);
    String timeString = Utils.getTimeRecordString(timeRecord);
    //Record the answer
    _timerProvider!.setCountDown(timeString);

    if (null != _countDown) {
      _countDown!.cancel();
    }
    _simulatorTestProvider!.setIsLessThan2Second(true);
    _countDown = _testRoomPresenter!.startCountDown(
        context: context,
        count: timeRecord,
        isPart2: isPart2,
        isReAnswer: false,
        isLessThan2Seconds: true);

    _setVisibleRecord(true, _countDown, fileName);

    _recordAnswer(fileName);
  }

  void _setVisibleSaveTest(bool isVisible) {
    _simulatorTestProvider!.setVisibleSaveTheTest(isVisible);
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
    _initVideoController(isIntroduceVideo: false);
  }

  void _continueRecordPart2() async {
    if (kDebugMode) {
      print("DEBUG: _continueRecordPart2");
    }

    int timeRecordCounting = _simulatorTestProvider!.timeRecordCounting;

    String timeString = Utils.getTimeRecordString(timeRecordCounting);
    //TODO
    int totalTimeRecordPart2 = _getRecordTime(PartOfTest.part2.get);
    // int totalTimeRecordPart2 = Utils.getRecordTime(PartOfTest.part2.get);

    if (timeRecordCounting < totalTimeRecordPart2) {
      _timerProvider!.setCountDown(timeString);
      if (null != _countDown) {
        _countDown!.cancel();
      }

      if (Platform.isIOS) {
        if (await _recordController!.isPaused()) {
          _recordController!.resume();
        }
      } else {
        if (_recorder.isPaused) {
          _recorder.resumeRecorder();
        }
      }

      _simulatorTestProvider!.setIsLessThan2Second(true);
      _countDown = _testRoomPresenter!.startCountDown(
          context: context,
          count: timeRecordCounting,
          isPart2: true,
          isReAnswer: false,
          isLessThan2Seconds: true);
    }
  }

  void _reRecordAnswer() {
    if (kDebugMode) {
      print("DEBUG: _reRecordAnswer");
    }
    FileTopicModel current =
        _simulatorTestProvider!.listVideoSource[_playingIndex];
    //prepare to record answer
    bool isPart2 = current.numPart == PartOfTest.part2.get;
    String fileName = current.id.toString();
    _prepareStep1RecordAnswer(fileName: fileName, isPart2: isPart2);
  }

  bool _isLastAnswer(QuestionTopicModel question) {
    return question.answers[question.repeatIndex].url ==
        question.answers.last.url;
  }

  void _updateReAnswers() {
    _createLog(action: LogEvent.actionUpdateAnswer, data: null);

    if (kDebugMode) {
      print("DEBUG: _updateReAnswers");
    }

    if (null != _loading) {
      _loading!.show(context: context, isViewAIResponse: false);
    }

    String activityId = "";
    if (widget.homeWorkModel != null) {
      activityId = widget.homeWorkModel!.activityId.toString();
    }

    _testRoomPresenter!.updateMyAnswer(
        context: context,
        testId: _simulatorTestProvider!.currentTestDetail.testId.toString(),
        activityId: activityId,
        reQuestions: _simulatorTestProvider!.questionList,
        isExam: _isExam);
  }

  bool _checkAnswerDuration() {
    if (_simulatorTestProvider!.isLessThan2Second) {
      Fluttertoast.showToast(
        msg: Utils.multiLanguage(
          StringConstants.answer_must_be_greater_than_2_seconds_message,
        ),
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
  void onCountDown(
      String countDownString, bool isLessThan2Second, int timeCounting) {
    if (mounted) {
      int numPart = _simulatorTestProvider!.currentQuestion.numPart;
      if (numPart == PartOfTest.part2.get) {
        _simulatorTestProvider!.setTimeRecordCounting(timeCounting);
      }
      _timerProvider!.setCountDown(countDownString);
      _simulatorTestProvider!.setIsLessThan2Second(isLessThan2Second);
    }
  }

  @override
  void onFinishAnswer(bool isPart2) {
    //Check answer of user must be greater than 2 seconds
    if (_checkAnswerDuration()) {
      _resetEnableFinishStatus();
      return;
    }

    //Finish answer
    _resetQuestionImage();

    //Reset countdown
    if (null != _countDown) {
      _countDown!.cancel();
    }

    //Finish and Save video file to videos saved
    if (_isExam) {
      Future.delayed(Duration.zero, () {
        _saveVideoRecording();
      });
    }

    //Stop record
    _setVisibleRecord(false, null, null);

    //Enable repeat button
    _simulatorTestProvider!.setEnableRepeatButton(true);

    //Show SAVE THE TEST when re answer
    if (_simulatorTestProvider!.doingStatus == DoingStatus.finish) {
      _hideCameraLive();
      _simulatorTestProvider!.setVisibleSaveTheTest(true);
    }

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
      _initVideoController(isIntroduceVideo: false);
    }
  }

  @override
  void onPlayEndOfTest(String fileName) {
    if (false == _simulatorTestProvider!.isLoadingVideo) {
      _playingIndex++;
      _initVideoController(isIntroduceVideo: false);
    }
  }

  @override
  void onPlayIntroduce() {
    if (false == _simulatorTestProvider!.isLoadingVideo) {
      _initVideoController(isIntroduceVideo: true);
    }
  }

  @override
  void onIntroduceFileEmpty() {
    _startToPlayFollowup();
  }

  @override
  void onCountDownForCueCard(String countDownString) {
    if (mounted) {
      _simulatorTestProvider!.setCountDownCueCard(countDownString);
    }
  }

  @override
  void onSubmitTestFail(String msg) async {
    if (null != _loading) {
      _loading!.hide();
    }
    //Update indicator process status
    _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.fail);
    _simulatorTestProvider!.setVisibleSaveTheTest(true);

    if (_isExam) {
      //Reset _questionIndex
      _questionIndex = 0;
    }

    //Send log
    Utils.sendLog();

    //Show submit error popup
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: Utils.multiLanguage(StringConstants.dialog_title),
          description: msg,
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

  @override
  void onSubmitTestSuccess(String msg) {
    _hideCameraLive();

    _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.success);
    _simulatorTestProvider!.setVisibleSaveTheTest(false);
    _simulatorTestProvider!.resetNeedUpdateReanswerStatus();
    _simulatorTestProvider!.setNeedRefreshActivityList(true);

    if (_isExam) {
      //Reset _questionIndex
      _questionIndex = 0;
    }

    //Send log
    Utils.sendLog();

    //Delete file video record exam
    _deleteFileVideoExam();
    showToastMsg(
      msg: msg,
      toastState: ToastStatesType.success,
    );
  }

  Future<void> _deleteFileVideoExam() async {
    File videoResizePath = _simulatorTestProvider!.savedVideoFile;
    if (videoResizePath.existsSync()) {
      if (kDebugMode) {
        print("RECORDING_VIDEO : Delete Saved Resize File Recording");
      }
      await videoResizePath.delete();
    }

    List<VideoExamRecordInfo> videosSaved = _simulatorTestProvider!.videosSaved;
    for (int i = 0; i < videosSaved.length; i++) {
      File videoRecordFile = File(videosSaved[i].filePath ?? "");
      if (videoRecordFile.existsSync()) {
        if (kDebugMode) {
          print("RECORDING_VIDEO : Delete Saved File Recording index : $i");
        }
        await videoRecordFile.delete();
      }
    }
  }

  @override
  void onClickSaveTheTest() async {
    //Check connection
    var connectivity = await connectivityService.checkConnectivity();
    if (connectivity.name != StringConstants.connectivity_name_none) {
      if (SubmitStatus.none == _simulatorTestProvider!.submitStatus ||
          SubmitStatus.fail == _simulatorTestProvider!.submitStatus) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              title: Utils.multiLanguage(StringConstants.dialog_title),
              description: Utils.multiLanguage(
                  StringConstants.confirm_save_the_test_message),
              okButtonTitle:
                  Utils.multiLanguage(StringConstants.save_button_title),
              cancelButtonTitle:
                  Utils.multiLanguage(StringConstants.dont_save_button_title),
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
      } else if (SubmitStatus.success == _simulatorTestProvider!.submitStatus) {
        if (kDebugMode) {
          print("DEBUG: Submit success: update answer after reanswer");
        }

        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              title: Utils.multiLanguage(StringConstants.confirm_title),
              description: Utils.multiLanguage(
                  StringConstants.confirm_save_change_answers_message),
              okButtonTitle:
                  Utils.multiLanguage(StringConstants.save_button_title),
              cancelButtonTitle:
                  Utils.multiLanguage(StringConstants.cancel_button_title),
              borderRadius: 8,
              hasCloseButton: true,
              okButtonTapped: () {
                _updateReAnswers();
              },
              cancelButtonTapped: () {
                Navigator.of(context).pop();
              },
            );
          },
        );
      }
    } else {
      //Show connect error here
      if (kDebugMode) {
        print("DEBUG: Connect error here!");
      }
      Utils.showConnectionErrorDialog(context);

      Utils.addConnectionErrorLog(context);
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

  @override
  bool get wantKeepAlive => true;

  @override
  void onFinishForReAnswer() {
    //Check answer of user must be greater than 2 seconds
    if (_checkAnswerDuration()) {
      _resetEnableFinishStatus();
      return;
    }

    _timerProvider!.strCount;
    //Change need update reanswer status
    _simulatorTestProvider!.setNeedUpdateReanswerStatus(true);

    if (kDebugMode) {
      print("DEBUG: onFinishForReAnswer");
    }
    // widget.provider.setReAnswerOfQuestions(question);
    if (null == _currentQuestion) {
      if (kDebugMode) {
        print("DEBUG: onFinishForReAnswer: _currentQuestion == null");
      }
      return;
    }

    int index = _simulatorTestProvider!.questionList.indexWhere((q) =>
        q.id == _currentQuestion!.id &&
        q.repeatIndex == _currentQuestion!.repeatIndex);
    if (index < 0 ||
        index > _simulatorTestProvider!.questionList.length ||
        _simulatorTestProvider!.questionList.isEmpty) {
      if (kDebugMode) {
        print("DEBUG: onFinishForReAnswer: Out of range");
      }
      return;
    }

    _currentQuestion!.answers[_currentQuestion!.repeatIndex].url =
        _reanswerFilePath;
    if (_isLastAnswer(_currentQuestion!)) {
      _currentQuestion!.reAnswerCount++;
    }
    _simulatorTestProvider!.questionList[index] = _currentQuestion!;
    _resetDataAfterReanswer(isCancel: false);
  }

  @override
  void onUpdateReAnswersFail(String msg) {
    if (null != _loading) {
      _loading!.hide();
    }
    //Update indicator process status
    _simulatorTestProvider!.setVisibleSaveTheTest(true);

    //Just for test
    // _simulatorTestProvider!.setVisibleSaveTheTest(false);

    //Send log
    Utils.sendLog();

    Fluttertoast.showToast(
        msg: msg,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        gravity: ToastGravity.CENTER,
        fontSize: 18,
        toastLength: Toast.LENGTH_LONG);
  }

  @override
  void onUpdateReAnswersSuccess(String msg) {
    if (null != _loading) {
      _loading!.hide();
    }

    _simulatorTestProvider!.setVisibleSaveTheTest(false);
    _simulatorTestProvider!.resetNeedUpdateReanswerStatus();

    //Send log
    Utils.sendLog();

    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      gravity: ToastGravity.CENTER,
      fontSize: 18,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  @override
  void onUpdateHasOrderStatus(bool hasOrder) {
    _simulatorTestProvider!.setHasOrderStatus(hasOrder);
  }
}
