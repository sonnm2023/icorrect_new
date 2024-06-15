import 'package:flutter/material.dart';

class PlayAnswerProvider with ChangeNotifier {
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

  int _selectedQuestionIndex = -1;
  int get selectedQuestionIndex => _selectedQuestionIndex;
  void setSelectedQuestionIndex(int i) {
    _selectedQuestionIndex = i;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void resetSelectedQuestionIndex() {
    _selectedQuestionIndex = -1;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void resetAll() {
    resetSelectedQuestionIndex();
  }
}