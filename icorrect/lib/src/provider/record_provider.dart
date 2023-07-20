import 'package:flutter/material.dart';

class RecordProvider with ChangeNotifier {
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

  void resetAll() {
    _visibleRecord = false;
    _timeRecord = 0;
  }
}