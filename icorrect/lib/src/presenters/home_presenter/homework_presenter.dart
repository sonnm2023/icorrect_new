// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/auth_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';

abstract class HomeWorkViewContract {
  void onLogoutSuccess();
  void onLogoutError(String message);
  void onUpdateCurrentUserInfoSuccess(UserDataModel userDataModel);
  void onUpdateCurrentUserInfoError(String message);
}

class HomeWorkPresenter {
  final HomeWorkViewContract? _view;
  AuthRepository? _authRepository;

  HomeWorkPresenter(this._view) {
    _authRepository = Injector().getAuthRepository();
  }

  void getCurrentUserInfo() async {
    UserDataModel? currentUser = await Utils.getCurrentUser();
    if (currentUser == null) {
      _view!.onUpdateCurrentUserInfoError(Utils.multiLanguage(
          StringConstants.load_list_homework_error_message)!);
      return;
    }

    _view!.onUpdateCurrentUserInfoSuccess(currentUser);
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

  void addLogWhenListActivityItemTapped({
    required BuildContext context,
    required ActivitiesModel activity,
  }) async {
    //Add action log
    LogModel actionLog = await Utils.prepareToCreateLog(context,
        action: LogEvent.actionClickOnHomeworkItem);
    actionLog.addData(
        key: StringConstants.k_activity_id,
        value: activity.activityId.toString());
    Utils.addLog(actionLog, LogEvent.none);
  }
}
