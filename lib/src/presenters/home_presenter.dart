import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/data_source/local/app_shared_preferences_keys.dart';
import 'package:icorrect_pc/src/data_source/local/app_shared_references.dart';
import '../data_source/constants.dart';
import '../data_source/dependency_injection.dart';
import '../data_source/repositories/auth_repository.dart';
import '../data_source/repositories/homework_repository.dart';
import '../models/homework_models/new_api_135/activities_model.dart';
import '../models/homework_models/new_api_135/new_class_model.dart';
import '../models/log_models/log_model.dart';
import '../models/user_data_models/user_data_model.dart';
import '../utils/utils.dart';
import 'package:http/http.dart' as http;

abstract class HomeWorkViewContract {
  void onGetListHomeworkComplete(List<ActivitiesModel> homeworks,
      List<NewClassModel> classes, String currentTime);
  void onGetListHomeworkError(String message);
  void onLogoutComplete();
  void onLogoutError(String message);
  void onUpdateCurrentUserInfo(UserDataModel userDataModel);
  void onCountDown(String strCount, int count);
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
    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiGetListHomework);
    }
    try {
      UserDataModel? currentUser = await Utils.instance().getCurrentUser();
      if (currentUser == null) {
        _view!.onGetListHomeworkError(Utils.instance().multiLanguage(
            StringConstants.loading_error_homeworks_list_message));
        return;
      }

      _view!.onUpdateCurrentUserInfo(currentUser);

      String email = currentUser.userInfoModel.email;
      String status = Status.allHomework.get.toString();

      _homeWorkRepository!.getHomeWorks(email, status).then((value) async {
        Map<String, dynamic> dataMap = jsonDecode(value);
        if (kDebugMode) {
          print('get homework: ${jsonEncode(dataMap).toString()}');
        }
        if (dataMap['error_code'] == 200) {
          List<NewClassModel> classes =
              await _generateListNewClass(dataMap['data']);

          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: null,
            status: LogEvent.success,
          );
          List<NewClassModel> classByID = [];
          for (NewClassModel classModel in classes) {
            String id = await AppSharedPref.instance().getString(key: AppSharedKeys.classID);
            if (classModel.id.toString() == id) {
              classByID.add(classModel);
            }
          }
          List<ActivitiesModel> homeworks =
          await _generateListHomeWork(classByID);
          _view!.onGetListHomeworkComplete(
              homeworks, classByID, dataMap['current_time']);
        } else {
          Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message:
                "${StringConstants.loading_error_homeworks_list}: ${dataMap['error_code']}${dataMap['status']}",
            status: LogEvent.failed,
          );
          _view!.onGetListHomeworkError(
              "${Utils.instance().multiLanguage(StringConstants.loading_error_homeworks_list)}: ${dataMap['error_code']}${dataMap['status']}");
        }
      }).catchError(
        // ignore: invalid_return_type_for_catch_error
        (onError) {
          Utils.instance().prepareLogData(
            log: log,
            data: null,
            message: onError.toString(),
            status: LogEvent.failed,
          );
          if (kDebugMode) {
            print("DEBUG:onGetListHomeworkError - ${onError.toString()} ");
          }
          _view!.onGetListHomeworkError(Utils.instance()
              .multiLanguage(StringConstants.network_error_message));
        },
      );
    } on TimeoutException {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: StringConstants.time_out_error_message,
        status: LogEvent.failed,
      );
      _view!.onGetListHomeworkError(Utils.instance()
          .multiLanguage(StringConstants.time_out_error_message));
    } on http.ClientException {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: StringConstants.client_error_message,
        status: LogEvent.failed,
      );
      _view!.onGetListHomeworkError(
          Utils.instance().multiLanguage(StringConstants.client_error_message));
    } on SocketException {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: StringConstants.socket_error_message,
        status: LogEvent.failed,
      );
      _view!.onGetListHomeworkError(
          Utils.instance().multiLanguage(StringConstants.socket_error_message));
    }
  }

  Future<List<NewClassModel>> _generateListNewClass(List<dynamic> data) async {
    List<NewClassModel> temp = [];
    for (int i = 0; i < data.length; i++) {
      NewClassModel item = NewClassModel.fromJson(data[i]);
      temp.add(item);
    }
    return temp;
  }

  List<ActivitiesModel> filterActivities(int classSelectedId,
      List<ActivitiesModel> activities, String status, String currentTime) {
    List<ActivitiesModel> activitiesFilter = [];
    if (classSelectedId == 0 &&
        status == Utils.instance().multiLanguage(StringConstants.all)) {
      return activities;
    }

    for (ActivitiesModel activity in activities) {
      Map<String, dynamic> activityStatus =
          Utils.instance().getHomeWorkStatus(activity, currentTime);
      if (activityStatus['title'] == status &&
          activity.classId == classSelectedId) {
        activitiesFilter.add(activity);
      } else if (classSelectedId == 0 && activityStatus['title'] == status) {
        activitiesFilter.add(activity);
      } else if (activity.classId == classSelectedId &&
          status == Utils.instance().multiLanguage(StringConstants.all)) {
        activitiesFilter.add(activity);
      }
    }
    return activitiesFilter;
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
        Utils.instance().setAccessToken('');

        //Delete current user
        Utils.instance().clearCurrentUser();

        _view!.onLogoutComplete();
      } else {
        _view!.onLogoutError(
            "${Utils.instance().multiLanguage(StringConstants.logout_error_title)}: "
            "${dataMap['error_code']}${dataMap['status']}");
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) => _view!.onLogoutError(onError.toString()),
    );
  }

  Timer startCountDown({required BuildContext context, required int count}) {
    assert(_view != null);
    const oneSec = Duration(seconds: 1);
    return Timer.periodic(oneSec, (Timer timer) {
      if (count < 0) {
        timer.cancel();
      } else {
        count = count + 1;
      }
      dynamic minutes = count ~/ 60;
      dynamic seconds = count % 60;

      dynamic minuteStr = minutes.toString().padLeft(2, '0');
      dynamic secondStr = seconds.toString().padLeft(2, '0');

      _view!.onCountDown("$minuteStr:$secondStr", count);

      if (count == 0) {
        timer.cancel();
      }
    });
  }
}
