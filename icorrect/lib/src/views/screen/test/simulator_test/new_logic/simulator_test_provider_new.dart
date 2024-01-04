import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/models/auth_models/video_record_exam_info.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/new_logic/playlist_model.dart';
import 'package:video_player/video_player.dart';

class SimulatorTestProviderNew extends ChangeNotifier {
  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!isDisposed) {
      super.notifyListeners();
    }
  }

  bool _isGettingTestDetail = true;

  bool get isGettingTestDetail => _isGettingTestDetail;

  void setGettingTestDetailStatus(bool isProcessing) {
    _isGettingTestDetail = isProcessing;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isDownloadProgressing = false;

  bool get isDownloadProgressing => _isDownloadProgressing;

  void setDownloadProgressingStatus(bool isDownloading) {
    _isDownloadProgressing = isDownloading;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _startNowAvailable = false;

  bool get startNowAvailable => _startNowAvailable;

  void setStartNowStatus(bool available) {
    _startNowAvailable = available;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isDownloadAgainSuccess = false;
  bool _isDownloadAgain = false;
  bool get isDownloadAgainSuccess => _isDownloadAgainSuccess;
  bool get isDownloadAgain => _isDownloadAgain;
  void setDownloadAgain(bool isDownloadAgain) {
    _isDownloadAgain = isDownloadAgain;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void setDownloadAgainSuccess(bool isSuccess) {
    _isDownloadAgainSuccess = isSuccess;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  //=========================== Downloading video info==========================
  int _total = 0;

  int get total => _total;

  void setTotal(int total) {
    _total = total;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _downloadingIndex = 1;

  int get downloadingIndex => _downloadingIndex;

  void updateDownloadingIndex(int index) {
    _downloadingIndex = index;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  double _downloadingPercent = 0.0;

  double get downloadingPercent => _downloadingPercent;

  void updateDownloadingPercent(double percent) {
    _downloadingPercent = percent;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _permissionDeniedTime = 0;

  int get permissionDeniedTime => _permissionDeniedTime;

  void setPermissionDeniedTime() {
    _permissionDeniedTime++;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  final List<TopicModel> _topicsList = [];

  List<TopicModel> get topicsList => _topicsList;

  void setTopicsList(List<TopicModel> list) {
    _topicsList.clear();
    _topicsList.addAll(list);
  }

  void resetTopicsList() {
    _topicsList.clear();
  }

  bool _dialogShowing = false;

  bool get dialogShowing => _dialogShowing;

  void setDialogShowing(bool isShowing) {
    _dialogShowing = isShowing;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  //Status of doing the test
  DoingStatus _doingStatus = DoingStatus.none;

  DoingStatus get doingStatus => _doingStatus;

  void updateDoingStatus(DoingStatus status) {
    _doingStatus = status;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _activityType = '';

  String get activityType => _activityType;

  void setActivityType(String type) {
    _activityType = type;
  }

  SubmitStatus _submitStatus = SubmitStatus.none;

  SubmitStatus get submitStatus => _submitStatus;

  void updateSubmitStatus(SubmitStatus status) {
    _submitStatus = status;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  TestDetailModel _currentTestDetail = TestDetailModel();

  TestDetailModel get currentTestDetail => _currentTestDetail;

  void setCurrentTestDetail(TestDetailModel testDetailModel) {
    _currentTestDetail = testDetailModel;
  }

  final List<String> _answerList = [];

  List<String> get answerList => _answerList;

  void setAnswerList(List<String> list) {
    _answerList.clear();
    _answerList.addAll(list);
  }

  bool _isLoadingVideo = false;

  bool get isLoadingVideo => _isLoadingVideo;

  void setIsLoadingVideo(bool isLoading) {
    _isLoadingVideo = isLoading;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _needDownloadAgain = false;

  bool get needDownloadAgain => _needDownloadAgain;

  void setNeedDownloadAgain(bool need) {
    _needDownloadAgain = need;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _visibleRepeat = true;

  bool get visibleRepeat => _visibleRepeat;

  void setVisibleRepeat(bool visible) {
    _visibleRepeat = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _countRepeat = 0;

  int get countRepeat => _countRepeat;

  void setCountRepeat(int countRepeat) {
    _countRepeat = countRepeat;
  }

  List<VideoExamRecordInfo> _videosRecorded = [];

  List<VideoExamRecordInfo> get videosRecorded => _videosRecorded;

  void setVideosRecorded(List<VideoExamRecordInfo> videos) {
    if (_videosRecorded.isNotEmpty) {
      _videosRecorded.clear();
    }
    _videosRecorded.addAll(videos);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addVideoRecorded(VideoExamRecordInfo video) {
    _videosRecorded.add(video);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearVideosRecorded() {
    if (_videosRecorded.isNotEmpty) {
      _videosRecorded.clear();
    }
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _reviewingCurrentIndex = 0;

  int get reviewingCurrentIndex => _reviewingCurrentIndex;

  void updateReviewingCurrentIndex(int index) {
    _reviewingCurrentIndex = index;
  }

  final List<QuestionTopicModel> _questionList = [];

  List<QuestionTopicModel> get questionList => _questionList;

  void addCurrentQuestionIntoList({
    required QuestionTopicModel questionTopic,
    required int repeatIndex,
    required bool isRepeat,
  }) {
    QuestionTopicModel temp = QuestionTopicModel().copyWith(
        id: questionTopic.id,
        content: questionTopic.content,
        type: questionTopic.type,
        topicId: questionTopic.topicId,
        tips: questionTopic.tips,
        tipType: questionTopic.tipType,
        isFollowUp: questionTopic.isFollowUp,
        cueCard: questionTopic.cueCard,
        reAnswerCount: questionTopic.reAnswerCount,
        answers: questionTopic.answers,
        numPart: questionTopic.numPart,
        repeatIndex: questionTopic.repeatIndex,
        files: questionTopic.files);
    if (isRepeat) {
      temp.content = "Ask for repeating the question!";
    }
    temp.repeatIndex = repeatIndex;
    _questionList.add(temp);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addQuestionToList(QuestionTopicModel questionTopic) {
    _questionList.add(questionTopic);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void setQuestionList(List<QuestionTopicModel> list) {
    _questionList.clear();
    _questionList.addAll(list);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearQuestionList() {
    _questionList.clear();
  }

  int _indexOfHeaderPart2 = 0;

  int get indexOfHeaderPart2 => _indexOfHeaderPart2;

  void setIndexOfHeaderPart2(int i) {
    _indexOfHeaderPart2 = i;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _indexOfHeaderPart3 = 0;

  int get indexOfHeaderPart3 => _indexOfHeaderPart3;

  void setIndexOfHeaderPart3(int i) {
    _indexOfHeaderPart3 = i;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _indexOfCurrentQuestion = 0;

  int get indexOfCurrentQuestion => _indexOfCurrentQuestion;

  void setIndexOfCurrentQuestion(int i) {
    _indexOfCurrentQuestion = i;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void resetIndexOfCurrentQuestion() {
    _indexOfCurrentQuestion = 0;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _indexOfCurrentFollowUp = 0;

  int get indexOfCurrentFollowUp => _indexOfCurrentFollowUp;

  void setIndexOfCurrentFollowUp(int i) {
    _indexOfCurrentFollowUp = i;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void resetIndexOfCurrentFollowUp() {
    _indexOfCurrentFollowUp = 0;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _finishPlayFollowUp = false;

  bool get finishPlayFollowUp => _finishPlayFollowUp;

  void setFinishPlayFollowUp(bool isFinish) {
    _finishPlayFollowUp = isFinish;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _timeRecord = 0;

  int get timeRecord => _timeRecord;

  void setTimeRecord(int seconds) {
    _timeRecord = seconds;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  final Queue<TopicModel> _topicsQueue = Queue<TopicModel>();

  Queue<TopicModel> get topicsQueue => _topicsQueue;

  void setTopicsQueue(Queue<TopicModel> queue) {
    _topicsQueue.addAll(queue);
  }

  void removeTopicsQueueFirst() {
    _topicsQueue.removeFirst();
  }

  void resetTopicsQueue() {
    _topicsQueue.clear();
  }

  bool _isReviewingPlayAnswer = false;

  bool get isReviewingPlayAnswer => _isReviewingPlayAnswer;

  void setIsReviewingPlayAnswer(bool isReviewingPlayAnswer) {
    _isReviewingPlayAnswer = isReviewingPlayAnswer;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  final List<Map<String, dynamic>> _logActions = [];

  List<Map<String, dynamic>> get logActions => _logActions;

  void addLogActions(Map<String, dynamic> log) {
    _logActions.add(log);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void resetLogActions() {
    _logActions.clear();
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _selectedQuestionIndex = -1;
  bool _isPlaying = false;

  int get selectedQuestionIndex => _selectedQuestionIndex;

  bool get isPlaying => _isPlaying;

  void setSelectedQuestionIndex(int i, bool isPlaying) {
    _selectedQuestionIndex = i;
    _isPlaying = isPlaying;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _canPlayAnswer = false;

  bool get canPlayAnswer => _canPlayAnswer;

  void setCanPlayAnswer(bool canPlayAnswer) {
    _canPlayAnswer = canPlayAnswer;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _canReanswer = false;

  bool get canReanswer => _canReanswer;

  void setCanReanswer(bool reanswer) {
    _canReanswer = reanswer;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  File _fileImage = File("");

  File get fileImage => _fileImage;

  void setFileImage(File fileImage) {
    _fileImage = fileImage;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearImageFile() {
    _fileImage = File('');
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<FileTopicModel> _answersRecord = [];

  List<FileTopicModel> get answerRecord => _answersRecord;

  void addAnswerRecord(FileTopicModel file) {
    _answersRecord.add(file);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearAnswers() {
    if (_answersRecord.isNotEmpty) {
      _answersRecord.clear();
    }
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _playedIntroduce = false;

  bool get playedIntroduce => _playedIntroduce;

  void setPlayedIntroduce(bool played) {
    _playedIntroduce = played;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  PlayListModel _currentPlay = PlayListModel();

  PlayListModel get currentPlay => _currentPlay;

  void setCurrentPlay(PlayListModel play) {
    _currentPlay = play;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _repeatTimes = 0;

  int get repeatTimes => _repeatTimes;

  void setRepeatTimes(int time) {
    _repeatTimes = time;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _indexCurrentPlay = 0;

  int get indexCurrentPlay => _indexCurrentPlay;

  void setIndexCurrentPlay(int index) {
    _indexCurrentPlay = index;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _questionLength = 1;

  int get questionLength => _questionLength;

  void setQuestionLength(int length) {
    _questionLength = length;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _indexQuestion = 0;

  int get indexQuestion => _indexQuestion;

  void setIndexQuestion(int index) {
    _indexQuestion = index;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<PlayListModel> _playList = [];

  List<PlayListModel> get playList => _playList;

  void setPlayList(List<PlayListModel> playList) {
    _playList = playList;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _visibleRecord = false;

  bool get visibleRecord => _visibleRecord;

  void setVisibleRecord(bool visible) {
    _visibleRecord = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _enableRepeatButton = true;

  bool get enableRepeatButton => _enableRepeatButton;

  void setEnableRepeatButton(bool enable) {
    _enableRepeatButton = enable;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _strCountCueCard = "";

  String get strCountCueCard => _strCountCueCard;

  void setStrCountCueCard(String count) {
    _strCountCueCard = count;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _strCountDown = "";

  String get strCountDown => _strCountDown;

  void setStrCountDown(String count) {
    _strCountDown = count;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _currentCount = 100;

  int get currentCount => _currentCount;

  void setCurrentCount(int count) {
    _currentCount = count;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  QuestionTopicModel _currentQuestion = QuestionTopicModel();

  QuestionTopicModel get currentQuestion => _currentQuestion;

  void setCurrentQuestion(QuestionTopicModel question) {
    _currentQuestion = question;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  // List<QuestionTopicModel> _questionList = [];
  // List<QuestionTopicModel> get questionList => _questionList;
  // void addQuestionToList(QuestionTopicModel questionTopicModel) {
  //   _questionList.add(questionTopicModel);
  //   if (!isDisposed) {
  //     notifyListeners();
  //   }
  // }

  // void setQuestionList(List<QuestionTopicModel> questions) {
  //   if (_questionList.isNotEmpty) {
  //     _questionList.clear();
  //   }
  //   _questionList.addAll(questions);
  //   if (!isDisposed) {
  //     notifyListeners();
  //   }
  // }

  // Queue<TopicModel> _topicsQueue = Queue();
  // Queue<TopicModel> get topicQueue => _topicsQueue;
  // void setTopicModelQueue(Queue<TopicModel> topicsQueue) {
  //   if (_topicsQueue.isNotEmpty) {
  //     _topicsQueue.clear();
  //   }
  //   _topicsQueue.addAll(topicsQueue);
  //   if (!isDisposed) {
  //     notifyListeners();
  //   }
  // }

  TopicModel _currentTopic = TopicModel();

  TopicModel get currentTopic => _currentTopic;

  void setCurrentTopic(TopicModel currentTopic) {
    _currentTopic = currentTopic;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isVisibleCueCard = false;

  bool get isVisibleCueCard => _isVisibleCueCard;

  void setVisibleCueCard(bool visible) {
    _isVisibleCueCard = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isVisibleSaveTheTest = false;

  bool get isVisibleSaveTheTest => _isVisibleSaveTheTest;

  void setVisibleSaveTheTest(bool visible) {
    _isVisibleSaveTheTest = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isStartTest = false;

  bool get isStartTest => _isStartTest;

  void setStartTest(bool status) {
    _isStartTest = status;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  VideoPlayerController? _videoPlayerController;

  VideoPlayerController get videoPlayController =>
      _videoPlayerController ?? VideoPlayerController.networkUrl(Uri.parse(""));

  void setPlayController(VideoPlayerController videoPlayerController) {
    _videoPlayerController = videoPlayerController;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<QuestionTopicModel> _reanswersList = [];

  List<QuestionTopicModel> get reanswersList => _reanswersList;

  void setReanswerList(List<QuestionTopicModel> list) {
    _reanswersList.clear();
    _reanswersList.addAll(list);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addReanswerQuestion(QuestionTopicModel questionTopicModel) {
    _reanswersList.add(questionTopicModel);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearReasnwersList() {
    _reanswersList.clear();
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void resetAll() {
    _logActions.clear();
    _needDownloadAgain = false;
    _isLoadingVideo = false;
    _answerList.clear();
    _currentTestDetail = TestDetailModel();
    _doingStatus = DoingStatus.none;
    _submitStatus = SubmitStatus.none;
    _activityType = '';
    _dialogShowing = false;
    _permissionDeniedTime = 0;
    _isGettingTestDetail = true;
    _isDownloadProgressing = false;
    _startNowAvailable = false;
    _total = 0;
    _downloadingIndex = 1;
    _downloadingPercent = 0.0;
    _isReviewingPlayAnswer = false;
    _strCountCueCard = "";
    _enableRepeatButton = true;
    _visibleRecord = false;
    _indexOfHeaderPart2 = 0;
    _indexOfHeaderPart3 = 0;
    _visibleRepeat = true;
    _countRepeat = 0;
    _videoPlayerController = null;
    _currentQuestion = QuestionTopicModel();
    _indexOfCurrentQuestion = 0;

    _currentCount = 1000;
    _strCountCueCard = "";
    _currentQuestion = QuestionTopicModel();
    _isVisibleCueCard = false;
    _isVisibleSaveTheTest = false;
    _isStartTest = false;
    _videoPlayerController = VideoPlayerController.file(File(""))..initialize();
    _visibleRecord = false;
    _enableRepeatButton = true;
    _strCountCueCard = "";
    _strCountDown = "";
    _selectedQuestionIndex = -1;
    _canReanswer = false;
    _canPlayAnswer = false;
    _fileImage = File("");
    _answersRecord = [];
    _playedIntroduce = false;
    _currentPlay = PlayListModel();
    _repeatTimes = 0;
    _indexCurrentPlay = 0;
    _questionLength = 1;
    _indexQuestion = 0;
    _playList = [];
    _reanswersList.clear();
    // _topicsQueue = Queue();
    _currentTopic = TopicModel();
    resetTopicsQueue();
    clearQuestionList();
    resetTopicsList();
    resetTopicsQueue();
  }
}
