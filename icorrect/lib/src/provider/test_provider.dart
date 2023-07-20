import 'dart:async';
import 'dart:collection';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:video_player/video_player.dart';

class TestProvider with ChangeNotifier {
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

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;
  void updateProcessingStatus() {
    _isProcessing = !_isProcessing;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;
  void setDownloadingStatus(bool isDownloading) {
    _isDownloading = isDownloading;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _canStartNow = false;
  bool get canStartNow => _canStartNow;
  void setStartNowButtonStatus(bool available) {
    _canStartNow = available;

    if (!isDisposed) {
      notifyListeners();
    }
  }

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

  //Cue card
  Timer? _timerCueCard;
  Timer get timerCueCard =>
      _timerCueCard ?? Timer(const Duration(seconds: 0), () {});

  bool _isVisibleCueCard = false;
  bool get isVisibleCueCard => _isVisibleCueCard;
  void setVisibleCueCard(bool visible, {required Timer? timer}) {
    _isVisibleCueCard = visible;
    _timerCueCard = timer;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  String? _strCount;
  String get strCount => _strCount ?? '00:00';
  void setCountDown(String strCount) {
    _strCount = strCount;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isRepeatVisible = true;
  bool get isRepeatVisible => _isRepeatVisible;
  void setRepeatVisible(bool visible) {
    _isRepeatVisible = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isVisibleSave = false;
  bool get isVisibleSaveTheTest => _isVisibleSave;
  void setVisibleSaveTheTest(bool visible) {
    _isVisibleSave = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  final List<TopicModel> _topicsList = [];
  List<TopicModel> get topicsList => _topicsList;
  void setTopicsList(List<TopicModel> list) {
    _topicsQueue.clear();
    _topicsQueue.addAll(list);
  }

  final List<QuestionTopicModel> _questionList = [];
  List<QuestionTopicModel> get questionList => _questionList;
  void addCurrentQuestionIntoList(QuestionTopicModel questionTopic) {
    _questionList.add(questionTopic);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void setQuestionsList(List<QuestionTopicModel> list) {
    _questionList.clear();
    _questionList.addAll(list);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearQuestions() {
    _questionList.clear();
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

  int _indexFollowUp = 0;
  int get indexFollowUp => _indexFollowUp;
  void incrementIndexFollowUpBy1() {
    _indexFollowUp += 1;
  }

  void setIndexFollowUp(int i) {
    _indexFollowUp = i;
  }

  int _countRepeat = 0;
  int get countRepeat => _countRepeat;
  void setCountRepeat(int countRepeat) {
    _countRepeat = countRepeat;
  }

  Timer? _countDownTimer;
  Timer? get countDownTimer => _countDownTimer;

  void setCountDownTimer(Timer? timer) {
    _countDownTimer = timer;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  VideoPlayerController? _playerController;
  VideoPlayerController? get playController => _playerController;
  void setPlayController(VideoPlayerController? playerController) {
    _playerController = null;
    _playerController = playerController;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _visibleRecord = false;
  bool get visibleRecord => _visibleRecord;
  void setVisibleRecord(bool isVisible) {
    _visibleRecord = isVisible;

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

  final List<FileTopicModel> _answers = [];
  List<FileTopicModel> get answers => _answers;
  void addAnswer(FileTopicModel answer) {
    _answers.add(answer);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void setAnswers(List<FileTopicModel> list) {
    _answers.clear();
    _answers.addAll(list);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearAnswers() {
    _answers.clear();

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isVisibleReAnswer = false;
  bool get isVisibleReAnswer => _isVisibleReAnswer;
  void setVisibleReAnswer(bool visible) {
    _isVisibleReAnswer = visible;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _dialogShowing = false;
  bool get dialogShowing => _dialogShowing;
  void setDialogShowing(bool isShowing) {
    _dialogShowing = isShowing;

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

  int _timeRecord = 0;
  int get timeRecord => _timeRecord;
  void setTimeRecord(int seconds) {
    _timeRecord = seconds;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _pathFile = '';
  String get pathFile => _pathFile;
  void setFilePath(String filePath) {
    _pathFile = filePath;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isShowPlayVideoButton = true;
  bool get isShowPlayVideoButton => _isShowPlayVideoButton;
  void setIsShowPlayVideoButton(bool isShow) {
    _isShowPlayVideoButton = isShow;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isLoadingVideo = false;
  bool get isLoadingVideo => _isLoadingVideo;
  void setIsLoadingVideo(bool isLoading) {
    _isLoadingVideo = isLoading;

    if (!isDisposed) {
      notifyListeners();
    }
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

  void resetAll() {
    resetTopicsQueue();
    _indexOfHeaderPart2 = 0;
    _indexOfHeaderPart3 = 0;
    _isLoadingVideo = false;
    _isProcessing = false;
    _isDownloading = false;
    _canStartNow = false;
    _total = 0;
    _downloadingIndex = 1;
    _downloadingPercent = 0.0;
    _isVisibleCueCard = false;
    _strCount = '';
    _isRepeatVisible = true;
    _isVisibleSave = false;
    setTopicsList([]);
    clearQuestions();
    // setTopicsQueue(Queue<TopicModel>());
    resetTopicsQueue();
    _indexFollowUp = 0;
    _countRepeat = 0;
    _countDownTimer = null;
    // setPlayController(VideoPlayerController.networkUrl(Uri.parse("")));
    _playerController = null;
    _visibleRecord = false;
    _currentQuestion = QuestionTopicModel();
    clearAnswers();
    _isVisibleReAnswer = false;
    _dialogShowing = false;
    _permissionDeniedTime = 0;
    _indexOfCurrentQuestion = 0;
    _timeRecord = 0;
    _pathFile = '';
    _isShowPlayVideoButton = true;
  }
}
