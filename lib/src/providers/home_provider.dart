import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect_pc/src/models/homework_models/new_api_135/new_class_model.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_win/video_player_win.dart';

import '../models/user_data_models/user_data_model.dart';
import '../presenters/simulator_test_presenter.dart';

class HomeProvider extends ChangeNotifier {
  bool isDisposed = false;

  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }

  @override
  void notifyListeners() {
    if (!isDisposed) {
      super.notifyListeners();
    }
  }

  void clearData() {
    _activitiesFilter = [];
    _activitiesList = [];
    _classesList = [];
    _classSelected = NewClassModel();
    _statusActivity = Utils.instance().multiLanguage(StringConstants.all);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _currentTime = "";
  String get currentTime => _currentTime;
  void setCurrentTime(String time) {
    _currentTime = time;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<String> _statusSelections = [
    Utils.instance().multiLanguage(StringConstants.all),
    Utils.instance().multiLanguage(StringConstants.submitted),
    Utils.instance().multiLanguage(StringConstants.corrected),
    Utils.instance().multiLanguage(StringConstants.not_completed),
    Utils.instance().multiLanguage(StringConstants.late_title),
    Utils.instance().multiLanguage(StringConstants.out_of_date)
  ];

  List<String> get statusSelections => _statusSelections;
  void setStatusSelections(List<String> selections) {
    _statusSelections = selections;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<ActivitiesModel> _activitiesList = [];
  List<ActivitiesModel> get activitiesList => _activitiesList;

  void setActivitiesList(List<ActivitiesModel> list) {
    _activitiesList = list;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<ActivitiesModel> _activitiesFilter = [];
  List<ActivitiesModel> get activitiesFilter => _activitiesFilter;

  void setActivitiesFilter(List<ActivitiesModel> list) {
    _activitiesFilter = list;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<NewClassModel> _classesList = [];
  List<NewClassModel> get classesList => _classesList;

  void setClassesList(List<NewClassModel> classesList) {
    _classesList = classesList;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  NewClassModel _classSelected = NewClassModel();
  NewClassModel get classSelected => _classSelected;

  void setClassSelection(NewClassModel classModel) {
    _classSelected = classModel;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _statusActivity = Utils.instance().multiLanguage(StringConstants.all) ;
  String get statusActivity => _statusActivity;

  void setStatusActivity(String status) {
    _statusActivity = status;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  //Current user information
  UserDataModel _currentUser = UserDataModel();
  UserDataModel get currentUser => _currentUser;
  void setCurrentUser(UserDataModel user) {
    _currentUser = user;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _strCountDown = "";

  String get strCountDown => _strCountDown;

  void setStrCountDown(String count) {
    _strCountDown = count;
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

  String _description = '';
  String get descriptionRecordDialog => _description;

  void setDescriptionRecordDialog(String text) {
    _description = text;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _okTitle = '';
  String get okTitle => _okTitle;

  void setOkTitle(String text) {
    _okTitle = text;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _rightButtonTitle = '';
  String get rightButtonTitle => _rightButtonTitle;

  void setRightButtonTitle(String text) {
    _rightButtonTitle = text;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isRecord = false;
  bool get isRecord => _isRecord;

  void setIsRecord(bool isRecord) {
    _isRecord = isRecord;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  ButtonTestDevice _statusButton = ButtonTestDevice.isRecord;
  ButtonTestDevice get statusButton => _statusButton;

  void setStatusButton(ButtonTestDevice status) {
    _statusButton = status;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  ButtonTestDevice _statusButtonRight = ButtonTestDevice.isRecord;
  ButtonTestDevice get statusButtonRight => _statusButtonRight;

  void setStatusButtonRight(ButtonTestDevice status) {
    _statusButtonRight = status;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _msgToast = '';
  String get msgToast => _msgToast;

  void setMsgToast(String msg) {
    _msgToast = msg;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<double> _samples = [];
  List<double> get samples => _samples;

  void setListSamples(List<double> samples) {
    _samples.clear();
    _samples = samples;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  Duration _maxDuration = const Duration(milliseconds: 1000);
  Duration get maxDuration => _maxDuration;

  void setMaxDuration(Duration duration) {
    _maxDuration = duration;
    notifyListeners();
  }

  Duration _elapsedDuration = const Duration(milliseconds: 0);
  Duration get elapsedDuration => _elapsedDuration;

  void setElapsedDuration(Duration duration) {
    _elapsedDuration = duration;
    notifyListeners();
  }

  bool _isStartDoingTest = false;
  bool get isStartDoingTest => _isStartDoingTest;

  void setStartDoingTest(bool status) {
    _isStartDoingTest = status;

    notifyListeners();
  }

  VideoPlayerController? _videoPlayerController;
  VideoPlayerController get videoPlayerController => _videoPlayerController ?? VideoPlayerController.file(File(''));

  void setVideoPlayerController(VideoPlayerController player) {
    _videoPlayerController = player;

    notifyListeners();
  }

  void resetVideoPlayerController() {
    _videoPlayerController = null;
    notifyListeners();
  }

  bool _canDoNextStep = false;
  bool get canDoNextStep => _canDoNextStep;

  void setCanDoNextStep(bool can) {
    _canDoNextStep = can;
    notifyListeners();
  }
}
