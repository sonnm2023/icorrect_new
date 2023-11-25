import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';

import '../models/auth_models/topic_id.dart';
// import 'package:video_compress/video_compress.dart';

class AuthProvider with ChangeNotifier {
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;
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

  MediaInfo? _mediaInfo;
  MediaInfo? get mediaInfo => _mediaInfo!;
  void setMediaInfo(MediaInfo? info) {
    _mediaInfo = info;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  double _progressResize = 0.0;
  double get progressResize => _progressResize;
  void setProgressResize(double progress) {
    _progressResize = progress;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void resetProgressResize() {
    _progressResize = 0.0;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _skipAction = false;
  bool get skipAction => _skipAction;
  void setSkipAction(bool skip) {
    _skipAction = skip;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void updateProcessingStatus({required bool isProcessing}) {
    _isProcessing = isProcessing;
    notifyListeners();
  }

  bool _isRecordAnswer = false;
  bool get isRecordAnswer => _isRecordAnswer;
  void setRecordAnswer(bool record) {
    _isRecordAnswer = record;
    if (!isDisposed) {
      notifyListeners();
    }
  }

///////////////////Get Topics Id for Practice Test/////////////////////////////
  List<TopicId> _topicsId = [];
  List<TopicId> get topicsId => _topicsId;

  void setTopicsId(List<TopicId> list) {
    if (_topicsId.isNotEmpty) {
      _topicsId.clear();
    }
    _topicsId.addAll(list);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void removeTopicId(TopicId topic) {
    _topicsId.removeWhere(
        (item) => item.id == topic.id && item.testOption == topic.testOption);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addTopicId(TopicId id) {
    _topicsId.add(id);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearTopicsId() {
    if (_topicsId.isNotEmpty) {
      _topicsId.clear();
    }
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<int> getTopicsIdList() {
    List<int> topicsIdList = [];
    for (int i = 0; i < _topicsId.length; i++) {
      topicsIdList.add(_topicsId[i].id ?? 0);
    }
    return topicsIdList;
  }

////////////////////////////////////////////////////////////////////////////////
  Queue<GlobalKey<ScaffoldState>> _scaffoldKeys = Queue();
  Queue<GlobalKey<ScaffoldState>> get scaffoldKeys => _scaffoldKeys;
  void setQueueScaffoldKeys(GlobalKey<ScaffoldState> key,
      {Queue<GlobalKey<ScaffoldState>>? scaffoldKeys}) {
    _scaffoldKeys.addFirst(key);
    if (scaffoldKeys != null && scaffoldKeys.isNotEmpty) {
      _scaffoldKeys.clear();
      _scaffoldKeys.addAll(scaffoldKeys);
    }
    if (!isDisposed) {
      notifyListeners();
    }
  }

  GlobalKey<ScaffoldState> _globalScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> get globalScaffoldKey => _globalScaffoldKey;
  void setGlobalScaffoldKey(GlobalKey<ScaffoldState> key) {
    _globalScaffoldKey = key;
    setQueueScaffoldKeys(key);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isShowDialog = false;
  bool get isShowDialog => _isShowDialog;
  void setShowDialogWithGlobalScaffoldKey(
      bool isShowing, GlobalKey<ScaffoldState> key) {
    _isShowDialog = isShowing;
    setGlobalScaffoldKey(key);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _previousAction = "";
  String get previousAction => _previousAction;
  void setPreviousAction(String action) {
    _previousAction = action;
  }

  void resetPreviousAction() {
    _previousAction = "";
  }

  int _permissionDeniedTime = 0;
  int get permissionDeniedTime => _permissionDeniedTime;
  void setPermissionDeniedTime() {
    _permissionDeniedTime++;

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
}
