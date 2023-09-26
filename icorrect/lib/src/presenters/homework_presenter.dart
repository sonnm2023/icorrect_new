// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/auth_repository.dart';
import 'package:icorrect/src/data_sources/repositories/homework_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/new_class_model.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
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

  void getListHomeWork(BuildContext context) async {
    assert(_view != null && _homeWorkRepository != null);

    UserDataModel? currentUser = await Utils.getCurrentUser();
    if (currentUser == null) {
      _view!.onGetListHomeworkError("Loading list homework error");
      return;
    }

    _view!.onUpdateCurrentUserInfo(currentUser);

    String email = currentUser.userInfoModel.email;
    String status = Status.allHomework.get.toString();

    LogModel? log;
    if (null != context) {
      log = await Utils.prepareToCreateLog(context, action: LogEvent.callApiGetListHomework);
    }

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

        //Add log
        if (null != log) {
          log.addData(key: "response", value: value);
          Utils.addLog(log, LogEvent.success);
        }
        
        _view!.onGetListHomeworkComplete(homeworks, classes, dataMap['current_time']);
      } else {
        //Add log
        if (null != log) {
          log.message = "Loading list homework error: ${dataMap['error_code']}${dataMap['status']}";
          Utils.addLog(log, LogEvent.failed);
        }

        _view!.onGetListHomeworkError(
            "Loading list homework error: ${dataMap['error_code']}${dataMap['status']}");
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) {
        //Add log
        if (null != log) {
          log.message = onError.toString();
          Utils.addLog(log, LogEvent.failed);
        }

        _view!.onGetListHomeworkError(onError.toString());
      } ,
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

  void logout(BuildContext context) async {
    assert(_view != null && _authRepository != null);

    LogModel? log;
    if (null != context) {
      log = await Utils.prepareToCreateLog(GlobalScaffoldKey.homeScreenScaffoldKey.currentContext!, action: LogEvent.callApiLogout);
    }

    _authRepository!.logout().then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap['error_code'] == 200) {
        //Delete access token
        Utils.setAccessToken('');

        //Delete current user
        Utils.clearCurrentUser();

        //Add log
        if (null != log) {
          log.addData(key: "response", value: value);
          Utils.addLog(log, LogEvent.success);
        }

        _view!.onLogoutComplete();
      } else {
        //Add log
        if (null != log) {
          log.message = "Logout error: ${dataMap['error_code']}${dataMap['status']}";
          Utils.addLog(log, LogEvent.failed);
        }

        _view!.onLogoutError(
            "Logout error: ${dataMap['error_code']}${dataMap['status']}");
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) {
        //Add log
        if (null != log) {
          log.message = onError.toString();
          Utils.addLog(log, LogEvent.failed);
        }

        _view!.onLogoutError(onError.toString());
      },
    );
  }

  void refreshListHomework() {
    _view!.onRefreshListHomework();
  }
}
