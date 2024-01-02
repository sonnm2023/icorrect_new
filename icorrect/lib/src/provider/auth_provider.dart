import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';

class AuthProvider with ChangeNotifier {
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

  bool _skipAction = true;
  bool get skipAction => _skipAction;
  void setSkipAction(bool skip) {
    _skipAction = skip;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  //For Login
  bool _isLogining = false;
  bool get isLogining => _isLogining;

  void updateLoginStatus({required bool isLogining}) {
    _isLogining = isLogining;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  //For Change password
  bool _isChanging = false;
  bool get isChanging => _isChanging;

  Future<void> updateChangePasswordStatus({required bool isChanging}) async {
    _isChanging = isChanging;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isRecordAnswer = false;
  bool get isRecordAnswer => _isRecordAnswer;
  void setRecordAnswer(bool record) {
    _isRecordAnswer = record;
    if (!isDisposed) {
      notifyListeners();
    }
  }

////////////////////////////////////////////////////////////////////////////////
  final Queue<GlobalKey<ScaffoldState>> _scaffoldKeys = Queue();
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

  void resetPermissionDeniedTime() {
    _permissionDeniedTime = 0;
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
