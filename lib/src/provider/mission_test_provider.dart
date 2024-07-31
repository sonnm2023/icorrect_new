import 'package:flutter/cupertino.dart';
import 'package:icorrect/src/models/module_lession_models/lesson_model.dart';

class MissionTestProvider extends ChangeNotifier {

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

  Mission? _currentMission;
  Mission? get currentMission => _currentMission;

  void setCurrentMission(Mission mission) {
    _currentMission = mission;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  FileElement? _fileVideo;
  FileElement? get fileVideo => _fileVideo;

  void setListFileVideo(FileElement e) {
    _fileVideo = e;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  FileElement? _fileImage;
  FileElement? get fileImage => _fileImage;

  void setListFileImage(FileElement e) {
    _fileImage = e;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _strCounting = "";

  String get strCounting=> _strCounting;

  void setStrCounting(String count) {
    _strCounting = count;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _currentCount = 0;

  int get currentCount => _currentCount;

  void setCurrentCount(int count) {
    _currentCount = count;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isDownloadProgressing = false;
  bool get isDownloadProgressing => _isDownloadProgressing;
  void setDownloadProgressingStatus(bool isDownloading) {
    _isDownloadProgressing = isDownloading;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _startNowAvailable = false;
  bool get startNowAvailable => _startNowAvailable;
  void setStartNowStatus(bool available) {
    _startNowAvailable = available;

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



  int _downloadingIndex = 0;
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
}