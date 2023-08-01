import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';

class SimulatorTestProvider with ChangeNotifier {
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

  bool _isProcessing = true;
  bool get isProcessing => _isProcessing;
  void updateProcessingStatus(bool isProcessing) {
    _isProcessing = isProcessing;

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

  int _permissionDeniedTime = 0;
  int get permissionDeniedTime => _permissionDeniedTime;
  void setPermissionDeniedTime() {
    _permissionDeniedTime++;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  DoingStatus _doingStatus = DoingStatus.none;
  DoingStatus get doingStatus => _doingStatus;
  void updateDoingStatus(DoingStatus status) {
    _doingStatus = status;

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

  final Queue<TopicModel> _topicsQueue = Queue<TopicModel>();
  Queue<TopicModel> get topicsQueue => _topicsQueue;
  void setTopicsQueue(Queue<TopicModel> queue) {
    _topicsQueue.addAll(queue);
  }

  void resetTopicsQueue() {
    _topicsQueue.clear();
  }

  bool _dialogShowing = false;
  bool get dialogShowing => _dialogShowing;
  void setDialogShowing(bool isShowing) {
    _dialogShowing = isShowing;

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

  final List<QuestionTopicModel> _questionList = [];
  List<QuestionTopicModel> get questionList => _questionList;
  void setQuestionList(List<QuestionTopicModel> list) {
    _questionList.clear();
    _questionList.addAll(list);
  }

  void clearQuestionList() {
    _questionList.clear();
  }

  bool _isLoadingVideo = false;
  bool get isLoadingVideo => _isLoadingVideo;
  void setIsLoadingVideo(bool isLoading) {
    _isLoadingVideo = isLoading;

    if (!isDisposed) {
      notifyListeners();
    }
  }


  void resetAll() {
    _isLoadingVideo = false;
    _answerList.clear();
    _currentTestDetail = TestDetailModel();
    _doingStatus = DoingStatus.none;
    _submitStatus = SubmitStatus.none;
    _activityType = '';
    _dialogShowing = false;
    _permissionDeniedTime = 0;
    _isProcessing = true;
    _isDownloading = false;
    _canStartNow = false;
    _total = 0;
    _downloadingIndex = 1;
    _downloadingPercent = 0.0;
    resetTopicsList();
    resetTopicsQueue();
    clearQuestionList();
  }
}