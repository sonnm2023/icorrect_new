import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/repositories/app_repository.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

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
          body: <String, String>{
            StringConstants.k_email: email,
            StringConstants.k_password: password
          },
        )
        .timeout(const Duration(seconds: 30))
        .then((http.Response response) {
          final String jsonBody = response.body;
          return jsonBody;
        })
        // ignore: body_might_complete_normally_catch_error
        .catchError((onError) {
          if (kDebugMode) {
            print("DEBUG: error: ${onError.toString()}");
          }
        });
  }

  @override
  Future<String> getUserInfo(String deviceId, String appVersion, String os) {
    String url = '$apiDomain$getUserInfoEP';

    return AppRepository.init()
        .sendRequest(
          RequestMethod.post,
          url,
          true,
          body: <String, String>{
            StringConstants.k_device_id: deviceId,
            StringConstants.k_app_version: appVersion,
            StringConstants.k_os: os
          },
        )
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
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
        )
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
      final String jsonBody = response.body;
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
          body: <String, String>{
            StringConstants.k_old_password: oldPassword,
            StringConstants.k_password: newPassword,
            StringConstants.k_confirmation_password: confirmNewPassword,
          },
        )
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
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
        )
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
      return response.body;
    });
  }
}
