import 'dart:convert';

import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences_keys.dart';
import 'package:icorrect/src/data_sources/repositories/auth_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/auth_models/auth_model.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';

abstract class LoginViewContract {
  void onLoginComplete();
  void onLoginError(String message);
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
          _view!.onLoginError(authModel.message);
        } else {
          _view!.onLoginError('${authModel.errorCode}: ${authModel.status}');
        }
      }
    // ignore: invalid_return_type_for_catch_error
    }).catchError((onError) => _view!.onLoginError(onError.toString()));
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
}
