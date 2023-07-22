import 'dart:async';
import 'dart:collection';
import 'dart:core';

import 'package:flutter/material.dart';
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

  bool _isRepeatVisible = true;
  bool get isRepeatVisible => _isRepeatVisible;
  void setRepeatVisible(bool visible) {
    _isRepeatVisible = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _countRepeat = 0;
  int get countRepeat => _countRepeat;
  void setCountRepeat(int countRepeat) {
    _countRepeat = countRepeat;
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
  void addCurrentQuestionIntoList({
    required QuestionTopicModel questionTopic,
    required int repeatIndex,
  }) {
    QuestionTopicModel temp =
        QuestionTopicModel().copyWith(questionTopicModel: questionTopic);
    if (repeatIndex != 0) {
      temp.content = "Ask for repeating the question!";
      temp.repeatIndex = repeatIndex;
    }
    _questionList.add(temp);

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

  QuestionTopicModel _currentQuestion = QuestionTopicModel();
  QuestionTopicModel get currentQuestion => _currentQuestion;
  void setCurrentQuestion(QuestionTopicModel question) {
    _currentQuestion = question;

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
    _isVisibleCueCard = false;
    _isRepeatVisible = true;
    _isVisibleSave = false;
    setTopicsList([]);
    clearQuestions();
    resetTopicsQueue();
    _countRepeat = 0;
    _countDownTimer = null;
    _playerController = null;
    _currentQuestion = QuestionTopicModel();
    _dialogShowing = false;
    _permissionDeniedTime = 0;
    _indexOfCurrentQuestion = 0;
    _isShowPlayVideoButton = true;
  }
}
