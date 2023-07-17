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


  void updateProcessingStatus() {
    _isProcessing = !_isProcessing;
    notifyListeners();
  }
}