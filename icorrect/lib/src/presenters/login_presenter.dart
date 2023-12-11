// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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

    int delayTime = 0; //For product
    // int delayTime = 10; //For test

    Future.delayed(Duration(seconds: delayTime)).then((_) {
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
          _view!.onLoginError(
            authModel.status,
          );
        } else {
          String message = '';
          if (authModel.message.isNotEmpty) {
            _view!.onLoginError(
              Utils.multiLanguage(StringConstants.network_error_message),
            );
            message = StringConstants.network_error_message;
          } else {
            _view!.onLoginError(
              Utils.multiLanguage(StringConstants.common_error_message),
            );
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
          _view!.onLoginError(
            Utils.multiLanguage(StringConstants.network_error_message),
          );
          message = StringConstants.network_error_message;
        } else {
          _view!.onLoginError(
            Utils.multiLanguage(StringConstants.common_error_message),
          );
          message = StringConstants.common_error_message;
        }
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message: message,
          status: LogEvent.failed,
        );
      });
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
      if (dataMap[StringConstants.k_error_code] == 200) {
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
          message: dataMap[StringConstants.k_message],
          status: LogEvent.success,
        );

        _view!.onGetAppConfigInfoSuccess();
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message:
              "GetAppConfigInfo error: ${dataMap[StringConstants.k_error_code]}${dataMap[StringConstants.k_status]}",
          status: LogEvent.failed,
        );

        _view!.onGetAppConfigInfoFail(Utils.multiLanguage(
            StringConstants.getting_app_config_information_error_message));
      }
    }).catchError((onError) {
      String message = '';
      if (onError is http.ClientException || onError is SocketException) {
        message = StringConstants.network_error_message;

        _view!.onGetAppConfigInfoFail(
            Utils.multiLanguage(StringConstants.network_error_message));
      } else {
        message = StringConstants.common_error_message;

        _view!.onGetAppConfigInfoFail(
            Utils.multiLanguage(StringConstants.common_error_message));
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
      if (dataMap[StringConstants.k_error_code] == 200) {
        UserDataModel userDataModel =
            UserDataModel.fromJson(dataMap[StringConstants.k_data]);
        Utils.setCurrentUser(userDataModel);

        //Add log
        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );

        //Set userid for firebase
        setUserInformation(userDataModel.userInfoModel.id.toString());

        _view!.onLoginComplete();
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message:
              "GetUserInfo error: ${dataMap[StringConstants.k_error_code]}${dataMap[StringConstants.k_status]}",
          status: LogEvent.failed,
        );

        _view!.onLoginError(
          Utils.multiLanguage(StringConstants.common_error_message),
        );
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

        _view!.onLoginError(
          Utils.multiLanguage(StringConstants.common_error_message),
        );
      },
    );
  }

  Future<void> setUserInformation(String userId) async {
    try {
      if (kDebugMode) {
        print("DEBUG: _setUserInformation with user_id: $userId");
      }
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    } on Exception catch (e, stack) {
      if (kDebugMode) {
        print("DEBUG: _setUserInformation error: $e: $stack");
      }
      FirebaseCrashlytics.instance.log('$e: $stack');
    }
  }
}
