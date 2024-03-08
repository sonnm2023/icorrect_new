// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:icorrect/core/secure_storage.dart';
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
  void onGetListHomeworkSuccess(List<ActivitiesModel> homeworks,
      List<NewClassModel> classes, String serverCurrentTime);
  void onGetListHomeworkError(String message);
  void onGetListHomeworkErrorWithExpiredToken(String message);
  void onGetListHomeworkErrorWithNotConnect();
  void onLogoutSuccess();
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
      _view!.onGetListHomeworkError(Utils.multiLanguage(
          StringConstants.load_list_homework_error_message)!);
      return;
    }

    _view!.onUpdateCurrentUserInfo(currentUser);

    String email = currentUser.userInfoModel.email;
    String status = Status.allHomework.get.toString();

    LogModel? log;
    Map<String, dynamic> dataLog = {};
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiGetListHomework);
    }

    try {
      final String value =
          await _homeWorkRepository!.getListHomeWork(email, status);
      dataLog[StringConstants.k_response] = value;

      if (kDebugMode) {
        print("DEBUG: getListHomeWork response: $value");
      }

      try {
        Map<String, dynamic> dataMap = jsonDecode(value);
        if (dataMap[StringConstants.k_error_code] == 200) {
          List<NewClassModel> classes =
              await _generateListNewClass(dataMap[StringConstants.k_data]);

          List<ActivitiesModel> homeworks =
              await _generateListHomeWork(classes);

          if (kDebugMode) {
            print("DEBUG: Homework: getListHomeWork class: ${classes.length}");
            print(
                "DEBUG: Homework: getListHomeWork homework: ${homeworks.length}");
          }

          //Add log
          Utils.prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: null,
            status: LogEvent.success,
          );

          //For test - start: need comment success case
          _view!.onGetListHomeworkSuccess(
              homeworks, classes, dataMap[StringConstants.k_current_time]);
          // _view!.onGetListHomeworkError(
          //     Utils.multiLanguage(StringConstants.common_error_message)!);
          //For test - end
        } else if (dataMap[StringConstants.k_error_code] == 401) {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: null,
            message:
                "Loading list homework error: ${dataMap['error_code']}${dataMap['status']}",
            status: LogEvent.failed,
          );

          _view!.onGetListHomeworkErrorWithExpiredToken(
              Utils.multiLanguage(StringConstants.common_error_message)!);
        } else {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: null,
            message:
                "Loading list homework error: ${dataMap['error_code']}${dataMap['status']}",
            status: LogEvent.failed,
          );

          _view!.onGetListHomeworkError(
              Utils.multiLanguage(StringConstants.common_error_message)!);
        }
      } catch (e) {
        // Add log
        Utils.prepareLogData(
          log: log,
          data: dataLog,
          message: "${StringConstants.parse_json_error}: $e",
          status: LogEvent.failed,
        );

        _view!.onGetListHomeworkError(
            Utils.multiLanguage(StringConstants.parse_json_error)!);
      }
    } on TimeoutException catch (e) {
      // Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "${StringConstants.timeout_exception_error_message}: $e",
        status: LogEvent.failed,
      );

      _view!.onGetListHomeworkError(Utils.multiLanguage(
          StringConstants.timeout_exception_error_message)!);
    } on SocketException catch (e) {
      // Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "${StringConstants.submit_test_error_socket}: $e",
        status: LogEvent.failed,
      );

      _view!.onGetListHomeworkErrorWithNotConnect();
    } catch (e) {
      // Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: e.toString(),
        status: LogEvent.failed,
      );

      _view!.onGetListHomeworkError(
          Utils.multiLanguage(StringConstants.get_activity_list_error_other)!);
    }
  }

  /*
  void getListHomeWork(BuildContext context) async {
    assert(_view != null && _homeWorkRepository != null);

    UserDataModel? currentUser = await Utils.getCurrentUser();
    if (currentUser == null) {
      _view!.onGetListHomeworkError(Utils.multiLanguage(
          StringConstants.load_list_homework_error_message)!);
      return;
    }

    _view!.onUpdateCurrentUserInfo(currentUser);

    String email = currentUser.userInfoModel.email;
    String status = Status.allHomework.get.toString();

    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiGetListHomework);
    }

    _homeWorkRepository!.getListHomeWork(email, status).then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap[StringConstants.k_error_code] == 200) {
        List<NewClassModel> classes =
            await _generateListNewClass(dataMap[StringConstants.k_data]);

        List<ActivitiesModel> homeworks = await _generateListHomeWork(classes);

        if (kDebugMode) {
          print("DEBUG: Homework: getListHomeWork class: ${classes.length}");
          print(
              "DEBUG: Homework: getListHomeWork homework: ${homeworks.length}");
        }

        //Add log
        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );

        //For test - start: need comment success case
        _view!.onGetListHomeworkSuccess(
            homeworks, classes, dataMap[StringConstants.k_current_time]);
        // _view!.onGetListHomeworkError(
        //     Utils.multiLanguage(StringConstants.common_error_message)!);
        //For test - end
      } else if (dataMap[StringConstants.k_error_code] == 401) {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message:
              "Loading list homework error: ${dataMap['error_code']}${dataMap['status']}",
          status: LogEvent.failed,
        );

        _view!.onGetListHomeworkErrorWithExpiredToken(
            Utils.multiLanguage(StringConstants.common_error_message)!);
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message:
              "Loading list homework error: ${dataMap['error_code']}${dataMap['status']}",
          status: LogEvent.failed,
        );

        _view!.onGetListHomeworkError(
            Utils.multiLanguage(StringConstants.common_error_message)!);
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message: onError.toString(),
          status: LogEvent.failed,
        );

        _view!.onGetListHomeworkError(
            Utils.multiLanguage(StringConstants.common_error_message)!);
      },
    );
  }
  */

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
    if (context.mounted) {
      //Add action log
      LogModel actionLog = await Utils.prepareToCreateLog(context,
          action: LogEvent.actionLogout);
      Utils.addLog(actionLog, LogEvent.none);

      log = await Utils.prepareToCreateLog(
          GlobalScaffoldKey.homeScreenScaffoldKey.currentContext!,
          action: LogEvent.callApiLogout);
    }

    _authRepository!.logout().then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap[StringConstants.k_error_code] == 200) {
        //Delete access token
        Utils.setAccessToken('');

        //Delete current user
        Utils.clearCurrentUser();

        //Add log
        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );

        //Remove email & password which saved as secure
        SecureStorage.deleteCredentials();

        _view!.onLogoutSuccess();
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message: "Logout error: ${dataMap['error_code']}${dataMap['status']}",
          status: LogEvent.failed,
        );

        _view!.onLogoutError(
            Utils.multiLanguage(StringConstants.common_error_message)!);
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message: onError.toString(),
          status: LogEvent.failed,
        );

        _view!.onLogoutError(
            Utils.multiLanguage(StringConstants.common_error_message)!);
      },
    );
  }

  void refreshListHomework() {
    _view!.onRefreshListHomework();
  }

  void clickOnHomeworkItem(
      {required BuildContext context,
      required ActivitiesModel homework}) async {
    //Add action log
    LogModel actionLog = await Utils.prepareToCreateLog(context,
        action: LogEvent.actionClickOnHomeworkItem);
    actionLog.addData(
        key: StringConstants.k_activity_id,
        value: homework.activityId.toString());
    Utils.addLog(actionLog, LogEvent.none);
  }
}
