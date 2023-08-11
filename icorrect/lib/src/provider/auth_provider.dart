import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:icorrect/src/views/screen/home/homework_screen.dart';

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

  void updateProcessingStatus() {
    _isProcessing = !_isProcessing;
    notifyListeners();
  }

  Queue<GlobalKey<ScaffoldState>> _scaffoldKeys = Queue();
  Queue<GlobalKey<ScaffoldState>> get scaffoldKeys => _scaffoldKeys;
  void setQueueScaffoldKeys(GlobalKey<ScaffoldState> key,
      {Queue<GlobalKey<ScaffoldState>>? scaffoldKeys}) {
    _scaffoldKeys.addFirst(key);
    if (scaffoldKeys != null) {
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
}
