// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences_keys.dart';
import 'package:icorrect/src/data_sources/repositories/auth_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/app_config_info_models/app_config_info_model.dart';
import 'package:icorrect/src/models/auth_models/auth_model.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

abstract class LoginViewContract {
  void onLoginComplete();
  void onLoginError(String message);
  void onGetAppConfigInfoSuccess();
  void onGetAppConfigInfoFail(String message);
}

class LoginPresenter {
  final LoginViewContract? _view;
  AuthRepository? _repository;
  LoginPresenter(this._view) {
    _repository = Injector().getAuthRepository();
  }

  void login(String email, String password, BuildContext context) async {
    assert(_view != null && _repository != null);

    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiLogin);
    }

    _repository!.login(email, password).then((value) async {
      AuthModel authModel = AuthModel.fromJson(jsonDecode(value));
      if (authModel.errorCode == 200) {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: authModel.message,
          status: LogEvent.success,
        );

        await _saveAccessToken(authModel.data.accessToken);
        _getUserInfo(context);
      } else if (authModel.errorCode == 401) {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: authModel.status,
          status: LogEvent.success,
        );
        _view!.onLoginError(authModel.status);
      } else {
        String message = '';
        if (authModel.message.isNotEmpty) {
          _view!.onLoginError(StringConstants.network_error_message);
          message = StringConstants.network_error_message;
        } else {
          _view!.onLoginError(StringConstants.common_error_messge);
          message = '${authModel.errorCode}: ${authModel.status}';
        }
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message: message,
          status: LogEvent.failed,
        );
      }
    }).catchError((onError) {
      String message = '';
      if (onError is http.ClientException || onError is SocketException) {
        _view!.onLoginError(StringConstants.network_error_message);
        message = StringConstants.network_error_message;
      } else {
        _view!.onLoginError(StringConstants.common_error_messge);
        message = StringConstants.common_error_messge;
      }
      //Add log
      Utils.prepareLogData(
        log: log,
        data: null,
        message: message,
        status: LogEvent.failed,
      );
    });
  }

  void getAppConfigInfo(BuildContext context) async {
    assert(_view != null && _repository != null);

    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiAppConfig);
    }

    _repository!.getAppConfigInfo().then((value) async {
      if (kDebugMode) {
        print("DEBUG: getAppConfigInfo $value");
      }
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap['error_code'] == 200) {
        AppConfigInfoModel appConfigInfoModel =
            AppConfigInfoModel.fromJson(dataMap);
        String logApiUrl = appConfigInfoModel.data.logUrl.toString();
        if (logApiUrl.isNotEmpty) {
          AppSharedPref.instance()
              .putString(key: AppSharedKeys.logApiUrl, value: logApiUrl);
        }

        String secretkey = appConfigInfoModel.data.secretkey.toString();
        if (logApiUrl.isNotEmpty) {
          AppSharedPref.instance()
              .putString(key: AppSharedKeys.secretkey, value: secretkey);
        }

        //Add log
        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: dataMap['message'],
          status: LogEvent.success,
        );

        _view!.onGetAppConfigInfoSuccess();
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message: "Login error: ${dataMap['error_code']}${dataMap['status']}",
          status: LogEvent.failed,
        );

        _view!.onLoginError(StringConstants.common_error_messge);
      }
    }).catchError((onError) {
      String message = '';
      if (onError is http.ClientException || onError is SocketException) {
        message = StringConstants.network_error_message;

        _view!.onGetAppConfigInfoFail(StringConstants.network_error_message);
      } else {
        message = StringConstants.common_error_messge;

        _view!.onGetAppConfigInfoFail(StringConstants.common_error_messge);
      }
      //Add log
      Utils.prepareLogData(
        log: log,
        data: null,
        message: message,
        status: LogEvent.failed,
      );
    });
  }

  Future<void> _saveAccessToken(String token) async {
    AppSharedPref.instance()
        .putString(key: AppSharedKeys.apiToken, value: token);
  }

  void _getUserInfo(BuildContext context) async {
    assert(_view != null && _repository != null);

    String deviceId = await Utils.getDeviceIdentifier();
    String appVersion = await Utils.getAppVersion();
    String os = await Utils.getOS();

    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiGetUserInfo);
    }

    _repository!.getUserInfo(deviceId, appVersion, os).then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap['error_code'] == 200) {
        UserDataModel userDataModel = UserDataModel.fromJson(dataMap['data']);
        Utils.setCurrentUser(userDataModel);

        //Add log
        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );

        _view!.onLoginComplete();
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message:
              "GetUserInfo error: ${dataMap['error_code']}${dataMap['status']}",
          status: LogEvent.failed,
        );

        _view!.onLoginError(StringConstants.common_error_messge);
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

        _view!.onLoginError(StringConstants.common_error_messge);
      },
    );
  }
}
