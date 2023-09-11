import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences_keys.dart';
import 'package:icorrect/src/data_sources/repositories/auth_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/app_config_info_models/app_config_info_model.dart';
import 'package:icorrect/src/models/auth_models/auth_model.dart';
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

  void login(String email, String password) {
    assert(_view != null && _repository != null);

    _repository!.login(email, password).then((value) async {
      AuthModel authModel = AuthModel.fromJson(jsonDecode(value));
      if (authModel.errorCode == 200) {
        await _saveAccessToken(authModel.data.accessToken);
        _getUserInfo();
      } else {
        if (authModel.message.isNotEmpty) {
          _view!.onLoginError('Please check your Internet and try again !');
        } else {
          _view!.onLoginError('${authModel.errorCode}: ${authModel.status}');
        }
      }
    }).catchError((onError) {
      if (onError is http.ClientException || onError is SocketException) {
        _view!.onLoginError('Please check your Internet and try again!');
      } else {
        _view!.onLoginError("An error occur. Please try again!");
      }
    });
  }

  Future<void> _saveAccessToken(String token) async {
    AppSharedPref.instance()
        .putString(key: AppSharedKeys.apiToken, value: token);
  }

  void _getUserInfo() async {
    assert(_view != null && _repository != null);

    String deviceId = await Utils.getDeviceIdentifier();
    String appVersion = await Utils.getAppVersion();
    String os = await Utils.getOS();

    _repository!.getUserInfo(deviceId, appVersion, os).then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap['error_code'] == 200) {
        UserDataModel userDataModel = UserDataModel.fromJson(dataMap['data']);
        Utils.setCurrentUser(userDataModel);
        _view!.onLoginComplete();
      } else {
        _view!.onLoginError(
            "Login error: ${dataMap['error_code']}${dataMap['status']}");
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) => _view!.onLoginError(onError.toString()),
    );
  }

  void getAppConfigInfo() {
    assert(_view != null && _repository != null);

    _repository!.getAppConfigInfo().then((value) async {
      if (kDebugMode) {
        print("DEBUG: getAppConfigInfo $value");
      }
      Map<String, dynamic> dataMap = jsonDecode(value);
      
      if (dataMap['error_code'] == 200) {
        AppConfigInfoModel appConfigInfoModel = AppConfigInfoModel.fromJson(dataMap);
        String logApiUrl = appConfigInfoModel.data.logUrl.toString();
        if (logApiUrl.isNotEmpty) {
          AppSharedPref.instance().putString(key: AppSharedKeys.logApiUrl, value: logApiUrl);
        }

        String secretkey = appConfigInfoModel.data.secretkey.toString();
        if (logApiUrl.isNotEmpty) {
          AppSharedPref.instance().putString(key: AppSharedKeys.secretkey, value: secretkey);
        }
        
        _view!.onGetAppConfigInfoSuccess();
      } else {
       _view!.onLoginError(
            "Login error: ${dataMap['error_code']}${dataMap['status']}");
      }
    }).catchError((onError) {
      if (onError is http.ClientException || onError is SocketException) {
        _view!.onGetAppConfigInfoFail('Please check your Internet and try again!');
      } else {
        _view!.onGetAppConfigInfoFail("An error occur. Please try again!");
      }
    });
  }
}
