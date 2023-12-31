// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/auth_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';

import '../data_sources/constants.dart';

abstract class ChangePasswordViewContract {
  void onChangePasswordComplete();
  void onChangePasswordError(String message);
}

class ChangePasswordPresenter {
  final ChangePasswordViewContract? _view;
  AuthRepository? _authRepository;

  ChangePasswordPresenter(this._view) {
    _authRepository = Injector().getAuthRepository();
  }

  void changePassword(
    BuildContext context,
    String oldPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    assert(_view != null && _authRepository != null);
    LogModel? log;
    if (context.mounted) {
      //Add action log
      LogModel actionLog = await Utils.prepareToCreateLog(context,
          action: LogEvent.actionChangePassword);
      Utils.addLog(actionLog, LogEvent.none);

      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiChangePassword);
    }

    _authRepository!
        .changePassword(oldPassword, newPassword, confirmNewPassword)
        .then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap['error_code'] == 200) {
        Map<String, dynamic> map = dataMap['data'];
        String token = map['access_token'];
        Utils.setAccessToken(token);

        //Add log
        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: dataMap['message'],
          status: LogEvent.success,
        );

        _view!.onChangePasswordComplete();
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message:
              "Change password error: ${dataMap['error_code']}${dataMap['status']}",
          status: LogEvent.failed,
        );

        _view!.onChangePasswordError(StringConstants.common_error_messge);
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

        _view!.onChangePasswordError(StringConstants.common_error_messge);
      },
    );
  }
}
