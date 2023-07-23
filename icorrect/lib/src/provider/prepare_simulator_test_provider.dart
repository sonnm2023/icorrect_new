import 'package:flutter/material.dart';

class PrepareSimulatorTestProvider with ChangeNotifier {
  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
  }

  @override
  void notifyListeners() {
    if (!isDisposed) {
      super.notifyListeners();
    }
  }

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;
  void updateProcessingStatus() {
    _isProcessing = !_isProcessing;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;
  void setDownloadingStatus(bool isDownloading) {
    _isDownloading = isDownloading;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _canStartNow = false;
  bool get canStartNow => _canStartNow;
  void setStartNowButtonStatus(bool available) {
    _canStartNow = available;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _total = 0;
  int get total => _total;
  void setTotal(int total) {
    _total = total;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _downloadingIndex = 1;
  int get downloadingIndex => _downloadingIndex;
  void updateDownloadingIndex(int index) {
    _downloadingIndex = index;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  double _downloadingPercent = 0.0;
  double get downloadingPercent => _downloadingPercent;
  void updateDownloadingPercent(double percent) {
    _downloadingPercent = percent;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _permissionDeniedTime = 0;
  int get permissionDeniedTime => _permissionDeniedTime;
  void setPermissionDeniedTime() {
    _permissionDeniedTime++;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isDoingTest = false;
  bool get isDoingTest => _isDoingTest;
  void setIsDoingTest(bool isDoingTest) {
    _isDoingTest = isDoingTest;
  }


  void resetAll() {
    _permissionDeniedTime = 0;
    _isProcessing = false;
    _isDownloading = false;
    _canStartNow = false;
    _total = 0;
    _downloadingIndex = 1;
    _downloadingPercent = 0.0;
  }
}