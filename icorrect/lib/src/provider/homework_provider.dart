import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences_keys.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/homework_status_model.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/new_class_model.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect/src/presenters/simulator_test_presenter.dart';

class HomeWorkProvider with ChangeNotifier {
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;
  void updateProcessingStatus() {
    _isProcessing = !_isProcessing;
    
    notifyListeners();
  }

  String _filterString = 'Add your filter!';
  String get filterString => _filterString;
  void updateFilterString(String newValue) {
    _filterString = newValue;
  }

  final List<ActivitiesModel> _listHomeWorks = [];
  List<ActivitiesModel> get listHomeWorks => _listHomeWorks;
  Future<void> setListHomeWorks(List<ActivitiesModel> list) async {
    if (_listHomeWorks.isNotEmpty) _listHomeWorks.clear();
    _listHomeWorks.addAll(list);
  }

  void resetListHomeworks() {
    _listHomeWorks.clear();
  }

  //List homework after filter
  final List<ActivitiesModel> _listFilteredHomeWorks = [];
  List<ActivitiesModel> get listFilteredHomeWorks => _listFilteredHomeWorks;
  void setListFilteredHomeWorks(List<ActivitiesModel> list) {
    _listFilteredHomeWorks.clear();
    _listFilteredHomeWorks.addAll(list);

    notifyListeners();
  }

  void resetListFilteredHomeWorks() {
    _listFilteredHomeWorks.clear();
  }

  final List<NewClassModel> _listClassForFilter = [];
  List<NewClassModel> get listClassForFilter => _listClassForFilter;
  Future<void> setListClassForFilter(List<NewClassModel> list) async {
    if (_listClassForFilter.isNotEmpty) _listClassForFilter.clear();
    _listClassForFilter.add(NewClassModel.fromJson(FilterJsonData.selectAll));
    _listClassForFilter.addAll(list);
  }

  void resetListClassForFilter() {
    _listClassForFilter.clear();
  }

  //List status (original) for filtering
  final List<HomeWorkStatusModel> _listStatusForFilter = [
    HomeWorkStatusModel.fromJson(FilterJsonData.selectAll),
    HomeWorkStatusModel.fromJson(FilterJsonData.submitted),
    HomeWorkStatusModel.fromJson(FilterJsonData.corrected),
    HomeWorkStatusModel.fromJson(FilterJsonData.notCompleted),
    HomeWorkStatusModel.fromJson(FilterJsonData.late),
    HomeWorkStatusModel.fromJson(FilterJsonData.outOfDate),
  ];
  List<HomeWorkStatusModel> get listStatusForFilter => _listStatusForFilter;

  //List selected class
  final List<NewClassModel> _listSelectedClassFilter = [];
  List<NewClassModel> get listSelectedClassFilter => _listSelectedClassFilter;
  void setListSelectedClassFilter(List<NewClassModel> list) {
    _listSelectedClassFilter.clear();
    _listSelectedClassFilter.addAll(list);
    
    notifyListeners();
  }

  //List selected class
  final List<HomeWorkStatusModel> _listSelectedStatusFilter = [];
  List<HomeWorkStatusModel> get listSelectedStatusFilter =>
      _listSelectedStatusFilter;
  void setListSelectedStatusFilter(List<HomeWorkStatusModel> list) {
    _listSelectedStatusFilter.clear();
    _listSelectedStatusFilter.addAll(list);
    
    notifyListeners();
  }

  //Current user information
  UserDataModel _currentUser = UserDataModel();
  UserDataModel get currentUser => _currentUser;
  void setCurrentUser(UserDataModel user) {
    _currentUser = user;
    
    notifyListeners();
  }

  void addSelectedClass(NewClassModel c) {
    if (!_checkClassExits(c)) {
      _listSelectedClassFilter.add(c);
      
      notifyListeners();
    }
  }

  void removeSelectedClass(NewClassModel c) {
    _listSelectedClassFilter.remove(c);
    
    notifyListeners();
  }

  bool _checkClassExits(NewClassModel c) {
    if (_listSelectedClassFilter.isEmpty) return false;

    bool hasSelectAll = _listSelectedClassFilter
        .map((e) => e.id)
        .contains(listClassForFilter.first.id);
    bool hasContain = _listSelectedClassFilter.map((e) => e.id).contains(c.id);
    if (hasSelectAll || hasContain) {
      return true;
    } else {
      return false;
    }
  }

  void addSelectedStatus(HomeWorkStatusModel s) {
    if (!_checkStatusExits(s)) {
      _listSelectedStatusFilter.add(s);
      
      notifyListeners();
    }
  }

  void removeSelectedStatus(HomeWorkStatusModel s) {
    _listSelectedStatusFilter.remove(s);
    
    notifyListeners();
  }

  bool _checkStatusExits(HomeWorkStatusModel s) {
    if (_listSelectedStatusFilter.isEmpty) return false;

    bool hasSelectAll = _listSelectedStatusFilter
        .map((e) => e.id)
        .contains(listStatusForFilter.first.id);
    bool hasContain = _listSelectedStatusFilter.map((e) => e.id).contains(s.id);
    if (hasSelectAll || hasContain) {
      return true;
    } else {
      return false;
    }
  }

  void addAllSelected(SelectType type) {
    if (type == SelectType.classType) {
      _listSelectedClassFilter.clear();
      _listSelectedClassFilter.addAll(listClassForFilter);
    } else {
      _listSelectedStatusFilter.clear();
      _listSelectedStatusFilter.addAll(listStatusForFilter);
    }
    
    notifyListeners();
  }

  void clearAllSelected(SelectType type) {
    if (type == SelectType.classType) {
      _listSelectedClassFilter.clear();
    } else {
      _listSelectedStatusFilter.clear();
    }
    
    notifyListeners();
  }

  Future<void> initializeListFilter() async {
    getListSelectedFilterFromLocal().then((value) {
      if (listSelectedClassFilter.isEmpty && listSelectedStatusFilter.isEmpty) {
        setListSelectedFilterIntoLocal();
      }
      filterHomeWork();
    });
  }

  Future<void> getListSelectedFilterFromLocal() async {
    String jsonString1 = await AppSharedPref.instance()
        .getString(key: AppSharedKeys.listClassFilter);
    if (jsonString1.isNotEmpty) {
      Iterable temp = jsonDecode(jsonString1);
      List<NewClassModel> temp1 =
          List<NewClassModel>.from(temp.map((e) => NewClassModel.fromJson(e)));
      setListSelectedClassFilter(temp1);
    }

    String jsonString2 = await AppSharedPref.instance()
        .getString(key: AppSharedKeys.listStatusFilter);
    if (jsonString2.isNotEmpty) {
      Iterable temp = jsonDecode(jsonString2);
      List<HomeWorkStatusModel> temp1 = List<HomeWorkStatusModel>.from(
          temp.map((e) => HomeWorkStatusModel.fromJson(e)));
      setListSelectedStatusFilter(temp1);
    }

    //Initialized filter data for first time
    if (jsonString1.isEmpty && jsonString2.isEmpty) {
      await setListSelectedFilterIntoLocal();
      await getListSelectedFilterFromLocal();
    }
  }

  Future<void> setListSelectedFilterIntoLocal() async {
    if (listSelectedClassFilter.isEmpty && listSelectedStatusFilter.isEmpty) {
      //Save original data for first time
      String jsonString = json.encode(listClassForFilter);
      AppSharedPref.instance()
          .putString(key: AppSharedKeys.listClassFilter, value: jsonString);

      jsonString = json.encode(listStatusForFilter);
      AppSharedPref.instance()
          .putString(key: AppSharedKeys.listStatusFilter, value: jsonString);
    } else {
      String jsonString =
          jsonEncode(listSelectedClassFilter.map((i) => i.toJson()).toList())
              .toString();
      AppSharedPref.instance()
          .putString(key: AppSharedKeys.listClassFilter, value: jsonString);

      jsonString =
          jsonEncode(listSelectedStatusFilter.map((i) => i.toJson()).toList())
              .toString();
      AppSharedPref.instance()
          .putString(key: AppSharedKeys.listStatusFilter, value: jsonString);
    }
  }

  // Future<void> resetListSelectedFilterIntoLocal() async {
  //   AppSharedPref.instance()
  //         .putString(key: AppSharedKeys.listClassFilter, value: "");
  //     AppSharedPref.instance()
  //         .putString(key: AppSharedKeys.listStatusFilter, value: "");
  // }

  void filterHomeWork() {
    bool hasSelectAllClass = listSelectedClassFilter
        .map((e) => e.id)
        .contains(listClassForFilter.first.id);
    bool hasSelectAllStatus = listSelectedStatusFilter
        .map((e) => e.id)
        .contains(listStatusForFilter.first.id);

    int numberOfSelectedClassFilter = hasSelectAllClass
        ? listSelectedClassFilter.length - 1
        : listSelectedClassFilter.length;
    int numberOfSelectedStatusFilter = hasSelectAllStatus
        ? listSelectedStatusFilter.length - 1
        : listSelectedStatusFilter.length;

    if (hasSelectAllClass && hasSelectAllStatus) {
      //Reset data
      if (_listFilteredHomeWorks.isNotEmpty) _listFilteredHomeWorks.clear();

      setListFilteredHomeWorks(listHomeWorks);
    } else {
      List<ActivitiesModel> temp1 = listHomeWorks
          .where((e1) =>
              listSelectedClassFilter.map((e2) => e2.id).contains(e1.classId))
          .toList();

      // List<ActivitiesModel> temp2 = temp1.where((e1) => listSelectedStatusFilter.map((e2) => e2.id)
      //     .contains(e1.activityStatus)).toList();
      List<ActivitiesModel> temp2 = temp1.where((e1) {
        Map<String, dynamic> activityStatusMap = Utils.getHomeWorkStatus(e1);
        return listSelectedStatusFilter
            .map((e2) => e2.name)
            .contains(activityStatusMap['title']);
      }).toList();
      setListFilteredHomeWorks(temp2);
    }

    String str =
        'Filter: class($numberOfSelectedClassFilter/${listClassForFilter.length - 1}) status: ($numberOfSelectedStatusFilter/${listStatusForFilter.length - 1})';
    updateFilterString(str);
    updateProcessingStatus();
  }

  bool checkFilterSelected() {
    if (listSelectedClassFilter.isEmpty || listSelectedStatusFilter.isEmpty) {
      return false;
    }

    setListSelectedFilterIntoLocal();

    return true;
  }

  bool _dialogShowing = false;
  bool get dialogShowing => _dialogShowing;
  void setDialogShowing(bool isShowing) {
    _dialogShowing = isShowing;
    
    notifyListeners();
  }

  int _permissionDeniedTime = 0;
  int get permissionDeniedTime => _permissionDeniedTime;
  void setPermissionDeniedTime() {
    _permissionDeniedTime++;
    
    notifyListeners();
  }

  SimulatorTestPresenter? _simulatorTestPresenter;
  SimulatorTestPresenter? get simulatorTestPresenter => _simulatorTestPresenter;
  void setSimulatorTestPresenter(SimulatorTestPresenter? presenter) {
    _simulatorTestPresenter = presenter;
  }
}
