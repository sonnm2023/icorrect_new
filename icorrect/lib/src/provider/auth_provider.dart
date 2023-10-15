import 'dart:collection';

import 'package:flutter/material.dart';

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
