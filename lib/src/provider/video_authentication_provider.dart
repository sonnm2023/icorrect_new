import 'dart:io';

import 'package:flutter/foundation.dart';

class VideoAuthProvider extends ChangeNotifier {
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

  void clearData() {
    _isRecordingVideo = false;
    _currentDuration = Duration.zero;
    _strCount = '00:00';
    _isSubmitLoading = false;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isRecordingVideo = false;
  bool get isRecordingVideo => _isRecordingVideo;
  void setRecordingVideo(bool isRecording) {
    _isRecordingVideo = isRecording;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  Duration _currentDuration = Duration.zero;
  String _strCount = '00:00';
  Duration get currentDuration => _currentDuration;
  String get strCount => _strCount;
  void setCurrentDuration(Duration duration, String strCount) {
    _currentDuration = duration;
    _strCount = strCount;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isSubmitLoading = false;
  bool get isSubmitLoading => _isSubmitLoading;
  void setIsSubmitLoading(bool isSubmit) {
    _isSubmitLoading = isSubmit;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  File _savedFile = File("");
  File get savedFile => _savedFile;
  void setSavedFile(File file) {
    _savedFile = file;
    if (!isDisposed) {
      notifyListeners();
    }
  }
}
