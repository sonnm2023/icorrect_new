import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences_keys.dart';
import 'package:icorrect/src/models/homework_models/class_model.dart';
import 'package:icorrect/src/models/homework_models/homework_model.dart';
import 'package:icorrect/src/models/homework_models/homework_status_model.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';

class HomeWorkProvider with ChangeNotifier {
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

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;
  void updateProcessingStatus() {
    _isProcessing = !_isProcessing;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _filterString = 'Add your filter!';
  String get filterString => _filterString;
  void updateFilterString(String newValue) {
    _filterString = newValue;
  }

  //Original list homeworks
  final List<HomeWorkModel> _listHomeWorks = [];
  List<HomeWorkModel> get listHomeWorks => _listHomeWorks;
  Future<void> setListHomeWorks(List<HomeWorkModel> list) async {
    if (_listHomeWorks.isNotEmpty) _listHomeWorks.clear();
    _listHomeWorks.addAll(list);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  //List homework after filter
  final List<HomeWorkModel> _listFilteredHomeWorks = [];
  List<HomeWorkModel> get listFilteredHomeWorks => _listFilteredHomeWorks;
  void setListFilteredHomeWorks(List<HomeWorkModel> list) {
    _listFilteredHomeWorks.clear();
    _listFilteredHomeWorks.addAll(list);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  //List class (original) for filtering
  final List<ClassModel> _listClassForFilter = [];
  List<ClassModel> get listClassForFilter => _listClassForFilter;
  Future<void> setListClassForFilter(List<ClassModel> list) async {
    if (_listClassForFilter.isNotEmpty) _listClassForFilter.clear();
    _listClassForFilter.add(ClassModel.fromJson(FilterJsonData.selectAll));
    _listClassForFilter.addAll(list);

    if (!isDisposed) {
      notifyListeners();
    }
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
  final List<ClassModel> _listSelectedClassFilter = [];
  List<ClassModel> get listSelectedClassFilter => _listSelectedClassFilter;
  void setListSelectedClassFilter(List<ClassModel> list) {
    _listSelectedClassFilter.clear();
    _listSelectedClassFilter.addAll(list);

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

  void addSelectedClass(ClassModel c) {
    if (!_checkClassExits(c)) {
      _listSelectedClassFilter.add(c);

      if (!isDisposed) {
        notifyListeners();
      }
    }
  }

  void removeSelectedClass(ClassModel c) {
    _listSelectedClassFilter.remove(c);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _checkClassExits(ClassModel c) {
    if (_listSelectedClassFilter.isEmpty) return false;

    bool hasSelectAll = _listSelectedClassFilter.map((e) => e.id).contains(listClassForFilter.first.id);
    bool hasContain = _listSelectedClassFilter.map((e) => e.id).contains(c.id);
    if (hasSelectAll || hasContain) {
      return true;
    } else {
      return false;
    }
  }

  //List selected class
  final List<HomeWorkStatusModel> _listSelectedStatusFilter = [];
  List<HomeWorkStatusModel> get listSelectedStatusFilter => _listSelectedStatusFilter;
  void setListSelectedStatusFilter(List<HomeWorkStatusModel> list) {
    _listSelectedStatusFilter.clear();
    _listSelectedStatusFilter.addAll(list);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addSelectedStatus(HomeWorkStatusModel s) {
    if (!_checkStatusExits(s)) {
      _listSelectedStatusFilter.add(s);

      if (!isDisposed) {
        notifyListeners();
      }
    }
  }

  void removeSelectedStatus(HomeWorkStatusModel s) {
    _listSelectedStatusFilter.remove(s);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _checkStatusExits(HomeWorkStatusModel s) {
    if (_listSelectedStatusFilter.isEmpty) return false;

    bool hasSelectAll = _listSelectedStatusFilter.map((e) => e.id).contains(listStatusForFilter.first.id);
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

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearAllSelected(SelectType type) {
    if (type == SelectType.classType) {
      _listSelectedClassFilter.clear();
    } else {
      _listSelectedStatusFilter.clear();
    }

    if (!isDisposed) {
      notifyListeners();
    }
  }

  Future<void> initializeListFilter() async {
    await getListSelectedFilterFromLocal();
    if (listSelectedClassFilter.isEmpty && listSelectedStatusFilter.isEmpty) {
      setListSelectedFilterIntoLocal();
    }
    filterHomeWork();
  }

  Future<void> getListSelectedFilterFromLocal() async {
    String jsonString1 = await AppSharedPref.instance().getString(key: AppSharedKeys.listClassFilter);
    if (jsonString1.isNotEmpty) {
      Iterable temp = jsonDecode(jsonString1);
      List<ClassModel> temp1 = List<ClassModel>.from(temp.map((e) => ClassModel.fromJson(e)));
      setListSelectedClassFilter(temp1);
    }

    String jsonString2 = await AppSharedPref.instance().getString(key: AppSharedKeys.listStatusFilter);
    if (jsonString2.isNotEmpty) {
      Iterable temp = jsonDecode(jsonString2);
      List<HomeWorkStatusModel> temp1 = List<HomeWorkStatusModel>.from(temp.map((e) => HomeWorkStatusModel.fromJson(e)));
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
      AppSharedPref.instance().putString(key: AppSharedKeys.listClassFilter, value: jsonString);

      jsonString = json.encode(listStatusForFilter);
      AppSharedPref.instance().putString(key: AppSharedKeys.listStatusFilter, value: jsonString);
    } else {
      String jsonString = jsonEncode(listSelectedClassFilter.map((i) => i.toJson()).toList()).toString();
      AppSharedPref.instance().putString(key: AppSharedKeys.listClassFilter, value: jsonString);

      jsonString = jsonEncode(listSelectedStatusFilter.map((i) => i.toJson()).toList()).toString();
      AppSharedPref.instance().putString(key: AppSharedKeys.listStatusFilter, value: jsonString);
    }
  }

  void filterHomeWork() {
    bool hasSelectAllClass = listSelectedClassFilter.map((e) => e.id).contains(listClassForFilter.first.id);
    bool hasSelectAllStatus = listSelectedStatusFilter.map((e) => e.id).contains(listStatusForFilter.first.id);

    int numberOfSelectedClassFilter = hasSelectAllClass ? listSelectedClassFilter.length - 1 : listSelectedClassFilter.length;
    int numberOfSelectedStatusFilter = hasSelectAllStatus ? listSelectedStatusFilter.length - 1 : listSelectedStatusFilter.length;

    if (hasSelectAllClass && hasSelectAllStatus) {
      //Reset data
      if (_listFilteredHomeWorks.isNotEmpty) _listFilteredHomeWorks.clear();

      setListFilteredHomeWorks(listHomeWorks);
    } else {
      List<HomeWorkModel> temp1 = listHomeWorks.where((e1) => listSelectedClassFilter.map((e2) => e2.id)
          .contains(e1.classId)).toList();

      List<HomeWorkModel> temp2 = temp1.where((e1) => listSelectedStatusFilter.map((e2) => e2.id)
          .contains(e1.completeStatus)).toList();
      setListFilteredHomeWorks(temp2);
    }

    String str = 'Filter: class($numberOfSelectedClassFilter/${listClassForFilter.length - 1}) status: ($numberOfSelectedStatusFilter/${listStatusForFilter.length - 1})';
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
}