import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';

class PrepareSimulatorTestProvider with ChangeNotifier {
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

  int _permissionDeniedTime = 0;
  int get permissionDeniedTime => _permissionDeniedTime;
  void setPermissionDeniedTime() {
    _permissionDeniedTime++;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isDoingTest = false;
  bool get isDoingTest => _isDoingTest;
  void setIsDoingTest(bool isDoingTest) {
    _isDoingTest = isDoingTest;
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

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;
  void setIsSubmitting(bool isSubmitting) {
    _isSubmitting = isSubmitting;

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



  void resetAll() {
    _answerList.clear();
    _currentTestDetail = TestDetailModel();
    _isSubmitting = false;
    _activityType = '';
    _dialogShowing = false;
    _permissionDeniedTime = 0;
    _isProcessing = false;
    _isDownloading = false;
    _canStartNow = false;
    _total = 0;
    _downloadingIndex = 1;
    _downloadingPercent = 0.0;
    resetTopicsList();
    resetTopicsQueue();
  }
}