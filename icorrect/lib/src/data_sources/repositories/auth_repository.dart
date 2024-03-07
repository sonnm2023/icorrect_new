import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/repositories/app_repository.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:icorrect/src/data_sources/utils.dart';

abstract class AuthRepository {
  Future<String> login(String email, String password);
  Future<String> logout();
  Future<String> getUserInfo(String deviceId, String appVersion, String os);
  Future<String> changePassword(
      String oldPassword, String newPassword, String confirmNewPassword);
  Future<String> getAppConfigInfo();
}

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<String> login(String email, String password) async {
    String url = '$apiDomain$loginEP';
    if (kDebugMode) {
      print("DEBUG: login: $url");
    }

    return AppRepository.init()
        .sendRequest(
          RequestMethod.post,
          url,
          false,
          false,
          body: <String, String>{
            StringConstants.k_email: email,
            StringConstants.k_password: password
          },
        )
        .timeout(const Duration(seconds: 30))
        .then((http.Response response) {
          final String jsonBody = response.body;
          Utils.addFirebaseLog(
            eventName: LogEvent.callApiLogin,
            parameters: {StringConstants.k_response: jsonBody},
          );
          return jsonBody;
        })
        .catchError(
          // ignore: body_might_complete_normally_catch_error
          (onError) {
            if (kDebugMode) {
              print("DEBUG: error: ${onError.toString()}");
            }
            Utils.addFirebaseLog(
              eventName: LogEvent.callApiLogin,
              parameters: {StringConstants.k_response: onError.toString()},
            );
          },
        );
  }

  @override
  Future<String> getUserInfo(String deviceId, String appVersion, String os) {
    String url = '$apiDomain$getUserInfoEP';

    return AppRepository.init()
        .sendRequest(
          RequestMethod.post,
          url,
          true,
          false,
          body: <String, String>{
            StringConstants.k_device_id: deviceId,
            StringConstants.k_app_version: appVersion,
            StringConstants.k_os: os
          },
        )
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
          Utils.addFirebaseLog(
            eventName: LogEvent.callApiGetUserInfo,
            parameters: {StringConstants.k_response: response.body},
          );
          return response.body;
        });
  }

  @override
  Future<String> logout() {
    String url = '$apiDomain$logoutEP';

    return AppRepository.init()
        .sendRequest(
          RequestMethod.post,
          url,
          true,
          false,
        )
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
      final String jsonBody = response.body;
      Utils.addFirebaseLog(
        eventName: LogEvent.callApiLogout,
        parameters: {StringConstants.k_response: jsonBody},
      );
      return jsonBody;
    });
  }

  @override
  Future<String> changePassword(
    String oldPassword,
    String newPassword,
    String confirmNewPassword,
  ) {
    String url = '$apiDomain$changePasswordEP';

    return AppRepository.init()
        .sendRequest(
          RequestMethod.post,
          url,
          true,
          false,
          body: <String, String>{
            StringConstants.k_old_password: oldPassword,
            StringConstants.k_password: newPassword,
            StringConstants.k_confirmation_password: confirmNewPassword,
          },
        )
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
          Utils.addFirebaseLog(
            eventName: LogEvent.callApiChangePassword,
            parameters: {StringConstants.k_response: response.body},
          );
          return response.body;
        });
  }

  @override
  Future<String> getAppConfigInfo() {
    String url = '$icorrectDomain$appConfigEP';
    if (kDebugMode) {
      print("DEBUG: url getAppConfigInfo: $url");
    }
    return AppRepository.init()
        .sendRequest(
          RequestMethod.get,
          url,
          false,
          false,
        )
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
      Utils.addFirebaseLog(
        eventName: LogEvent.callApiAppConfig,
        parameters: {StringConstants.k_response: response.body},
      );
      return response.body;
    });
  }
}
