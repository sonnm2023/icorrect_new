import 'package:flutter/foundation.dart';

import '../models/module_lession_models/lesson_model.dart';

class LessonProvider extends ChangeNotifier {
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

  List<LessonModel> _listLesson = [];
  List<LessonModel> get listLesson => _listLesson;

  List<Mission> _listMission = [];
  List<Mission> get listMission => _listMission;

  void setListLesson(List<LessonModel> list) {
    _listLesson = list;

    if(!isDisposed) {
      notifyListeners();
    }
  }

  void setListMission(List<Mission> list) {
    _listMission = list;
    if(!isDisposed) {
      notifyListeners();
    }
  }
}