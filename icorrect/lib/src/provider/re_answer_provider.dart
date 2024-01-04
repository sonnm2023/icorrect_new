import 'package:flutter/material.dart';

class ReAnswerProvider with ChangeNotifier {
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
  int? _numCount;
  String get strCount => _strCount ?? '00:00';
  int get numCount => _numCount ?? 0;
  void setCountDown(String strCount, int numCount) {
    _strCount = strCount;
    _numCount = numCount;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void resetAll() {
    _strCount = '';
  }
}
