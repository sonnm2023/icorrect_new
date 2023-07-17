import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/repositories/app_repository.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

abstract class AuthRepository {
  Future<String> login(String email, String password);
  Future<String> logout();
  Future<String> getUserInfo(String deviceId, String appVersion, String os);
  Future<String> changePassword(
      String oldPassword, String newPassword, String confirmNewPassword);
}

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<String> login(String email, String password) async {
    String url = '$apiDomain$loginEP';

    return AppRepository.init()
        .sendRequest(
          RequestMethod.post,
          url,
          false,
          body: <String, String>{'email': email, 'password': password},
        )
        .timeout(const Duration(seconds: 15))
        .then((http.Response response) {
          final String jsonBody = response.body;
          return jsonBody;
        });
  }

  @override
  Future<String> getUserInfo(String deviceId, String appVersion, String os) {
    String url = '$apiDomain$getUserInforEP';

    return AppRepository.init()
        .sendRequest(
          RequestMethod.post,
          url,
          true,
          body: <String, String>{
            'device_id': deviceId,
            'app_version': appVersion,
            'os': os
          },
        )
        .timeout(const Duration(seconds: 15))
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
        .timeout(const Duration(seconds: 15))
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
            'password_old': oldPassword,
            'password': newPassword,
            'password_confirmation': confirmNewPassword,
          },
        )
        .timeout(const Duration(seconds: 15))
        .then((http.Response response) {
          return response.body;
        });
  }
}
