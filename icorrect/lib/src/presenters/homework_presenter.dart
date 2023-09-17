import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/auth_repository.dart';
import 'package:icorrect/src/data_sources/repositories/homework_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/new_class_model.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';

abstract class HomeWorkViewContract {
  void onGetListHomeworkComplete(
      List<ActivitiesModel> homeworks, List<NewClassModel> classes, String serverCurrentTime);

  void onGetListHomeworkError(String message);

  void onLogoutComplete();

  void onLogoutError(String message);

  void onUpdateCurrentUserInfo(UserDataModel userDataModel);

  void onRefreshListHomework();
}

class HomeWorkPresenter {
  final HomeWorkViewContract? _view;
  AuthRepository? _authRepository;
  HomeWorkRepository? _homeWorkRepository;

  HomeWorkPresenter(this._view) {
    _authRepository = Injector().getAuthRepository();
    _homeWorkRepository = Injector().getHomeWorkRepository();
  }

  void getListHomeWork() async {
    assert(_view != null && _homeWorkRepository != null);

    UserDataModel? currentUser = await Utils.getCurrentUser();
    if (currentUser == null) {
      _view!.onGetListHomeworkError("Loading list homework error");
      return;
    }

    _view!.onUpdateCurrentUserInfo(currentUser);

    String email = currentUser.userInfoModel.email;
    String status = Status.allHomework.get.toString();

    _homeWorkRepository!.getListHomeWork(email, status).then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap['error_code'] == 200) {
        List<NewClassModel> classes =
            await _generateListNewClass(dataMap['data']);

        List<ActivitiesModel> homeworks = await _generateListHomeWork(classes);

        if (kDebugMode) {
          print("DEBUG: Homework: getListHomeWork class: ${classes.length}");
          print(
              "DEBUG: Homework: getListHomeWork homework: ${homeworks.length}");
        }
        
        _view!.onGetListHomeworkComplete(homeworks, classes, dataMap['current_time']);
      } else {
        _view!.onGetListHomeworkError(
            "Loading list homework error: ${dataMap['error_code']}${dataMap['status']}");
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) => _view!.onGetListHomeworkError(onError.toString()),
    );
  }

  Future<List<NewClassModel>> _generateListNewClass(List<dynamic> data) async {
    List<NewClassModel> temp = [];
    for (int i = 0; i < data.length; i++) {
      NewClassModel item = NewClassModel.fromJson(data[i]);
      temp.add(item);
    }
    return temp;
  }

  Future<List<ActivitiesModel>> _generateListHomeWork(
      List<NewClassModel> data) async {
    List<ActivitiesModel> temp = [];
    for (int i = 0; i < data.length; i++) {
      NewClassModel classModel = data[i];
      temp.addAll(classModel.activities);
    }
    return temp;
  }

  void logout() {
    assert(_view != null && _authRepository != null);

    _authRepository!.logout().then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap['error_code'] == 200) {
        //Delete access token
        Utils.setAccessToken('');

        //Delete current user
        Utils.clearCurrentUser();

        _view!.onLogoutComplete();
      } else {
        _view!.onLogoutError(
            "Logout error: ${dataMap['error_code']}${dataMap['status']}");
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) => _view!.onLogoutError(onError.toString()),
    );
  }

  void refreshListHomework() {
    _view!.onRefreshListHomework();
  }
}
