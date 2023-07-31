import 'dart:async';
import 'dart:collection';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:video_player/video_player.dart';

class TestProvider with ChangeNotifier {
  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
  }

  @override
  void notifyListeners() {
    if (!isDisposed) {
      super.notifyListeners();
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

  int _reviewingCurrentIndex = 0;
  int get reviewingCurrentIndex => _reviewingCurrentIndex;
  void updateReviewingCurrentIndex(int index) {
    _reviewingCurrentIndex = index;
  }

  void resetReviewingCurrentIndex() {
    _reviewingCurrentIndex = 0;
  }

  final List<QuestionTopicModel> _questionList = [];
  List<QuestionTopicModel> get questionList => _questionList;
  void addCurrentQuestionIntoList({
    required QuestionTopicModel questionTopic,
    required int repeatIndex,
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
      files: questionTopic.files
    );
    if (repeatIndex != 0) {
      temp.content = "Ask for repeating the question!";
      temp.repeatIndex = repeatIndex;
    }
    _questionList.add(temp);

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
    if (!isDisposed) {
      notifyListeners();
    }
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

  ReviewingStatus _reviewingStatus = ReviewingStatus.none;
  ReviewingStatus get reviewingStatus => _reviewingStatus;
  void updateReviewingStatus(ReviewingStatus status) {
    _reviewingStatus = status;

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

  /*================================= Record =================================*/
  bool _visibleRecord = false;
  bool get visibleRecord => _visibleRecord;
  void setVisibleRecord(bool isVisible) {
    _visibleRecord = isVisible;

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

  bool _enableRepeatButton = true;
  bool get enableRepeatButton => _enableRepeatButton;
  void setEnableRepeatButton(bool enable) {
    _enableRepeatButton = enable;

    if (!isDisposed) {
      notifyListeners();
    }
  }
  /*================================= Record =================================*/

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

  String? _strCountCueCard;
  String get strCountCueCard => _strCountCueCard ?? '00:00';
  void setCountDownCueCard(String strCount) {
    _strCountCueCard = strCount;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isReviewingPlayAnswer = false;
  bool get isReviewingPlayAnswer => _isReviewingPlayAnswer;
  void setIsReviewingPlayAnswer(bool isReviewingPlayAnswer) {
    _isReviewingPlayAnswer = isReviewingPlayAnswer;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  // bool _isReviewingPlaying = false;
  // bool get isReviewingPlaying => _isReviewingPlaying;
  // void setIsReviewingPlaying(bool status) {
  //   _isReviewingPlaying = status;
  // }

  void resetAll() {
    // _isReviewingPlaying = false;
    _isReviewingPlayAnswer = false;
    _strCountCueCard = null;
    _enableRepeatButton = true;
    _visibleRecord = false;
    _indexOfHeaderPart2 = 0;
    _indexOfHeaderPart3 = 0;
    _isLoadingVideo = false;
    _isVisibleCueCard = false;
    _isRepeatVisible = true;
    _isVisibleSave = false;
    _countRepeat = 0;
    _countDownTimer = null;
    _playerController = null;
    _currentQuestion = QuestionTopicModel();
    _indexOfCurrentQuestion = 0;
    _reviewingStatus = ReviewingStatus.none;
    resetTopicsQueue();
    clearQuestionList();
    resetReviewingCurrentIndex();
  }
}
