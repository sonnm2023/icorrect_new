import 'package:flutter/material.dart';

class TimerProvider with ChangeNotifier {
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

  void resetAll() {
    _strCount = '';
  }
}