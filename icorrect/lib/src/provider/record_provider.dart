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

  String? _strCount;
  String get strCount => _strCount ?? '00:00';
  void setCountDown(String strCount) {
    _strCount = strCount;

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

  int _timeRecord = 0;
  int get timeRecord => _timeRecord;
  void setTimeRecord(int seconds) {
    _timeRecord = seconds;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void resetAll() {
    _strCount = '';
    _visibleRecord = false;
    _timeRecord = 0;
  }
}