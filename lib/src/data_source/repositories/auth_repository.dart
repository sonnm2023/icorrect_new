import 'package:flutter/foundation.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/utils/utils.dart';

import '../api_urls.dart';
import 'package:http/http.dart' as http;
import 'app_repository.dart';

abstract class AuthRepository {
  Future<String> login(String email, String password);
  Future<String> logout();
  Future<String> getUserInfo(String deviceId, String appVersion, String os);
  Future<String> changePassword(
      String oldPassword, String newPassword, String confirmNewPassword);
  Future<String> getAppConfigInfo();
  Future<String> verifyDevice(String licence, String device_id, String deviceName);
  Future<String> loginWithClassID(String username, String classID, String licenseKey, String merchantID, String checksum);
  Future<String> getListClass(String merchantID, String checksum, int page);
  Future<String> getListStudent(String merchantID, int classID, String checksum);
  Future<String> verifyConfig(String key, String deviceID, String checksum, String merchantID);
  Future<String> changeDeviceName(String deviceID,String deviceName, String merchantID, String checksum);
}

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<String> login(String email, String password) async {
    String url = '$apiDomain$loginEP';
    if (kDebugMode) {
      print("DEBUG: step 1");
    }

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
      final int statusCode = response.statusCode;

      if (statusCode != 200 || jsonBody == null) {
        if (kDebugMode) {
          print(response.reasonPhrase);
        }
        // throw FetchDataException("StatusCode:$statusCode, Error:${response.reasonPhrase}");
      }
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
          final String jsonBody = response.body;
          final int statusCode = response.statusCode;

          if (statusCode != 200 || jsonBody == null) {
            if (kDebugMode) {
              print(response.reasonPhrase);
            }
            // throw FetchDataException("StatusCode:$statusCode, Error:${response.reasonPhrase}");
          }
          return jsonBody;
        });
  }

  @override
  Future<String> getAppConfigInfo() {
    String url = '$icorrectDomain$appConfigEP';

    return AppRepository.init()
        .sendRequest(
          RequestMethod.get,
          url,
          false,
        )
        .timeout(const Duration(seconds: 15))
        .then((http.Response response) {
      return response.body;
    });
  }

  @override
  Future<String> verifyDevice(String licence, String device_id, String deviceName) {
    String url = '$icorrectDomain$verifyLicenceEP';
    Map<String, dynamic> body = {
      'license': licence,
      'device_id': device_id,
      'device_name': deviceName
    };
    return AppRepository.init().
    sendRequest(
        RequestMethod.post,
        url, false,
        body: body
    )
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
      return response.body;
    });
  }

  @override
  Future<String> loginWithClassID(String userId, String classID, String licenseKey, String merchantID, String checksum){
    // var key = utf8.encode(licenseKey);
    // var bytes = utf8.encode('$classID|$merchantID|$userId');
    // var hmacSha256 = Hmac(sha256, key);
    // var checksum = hmacSha256.convert(bytes);
    String url = '$icorrectDomain$loginClassIDEP';
    Map<String, dynamic> body = {
      'class_id': classID,
      'user_id': userId,
      'merchant_id': merchantID,
      'check_sum': checksum
    };
    return AppRepository.init()
        .sendRequest(RequestMethod.post, url, false, body: body)
        .timeout(const Duration(seconds: 15))
        .then((http.Response response) {
      return response.body;
    });
  }

  @override
  Future<String> getListClass(String merchantID, String checksum, int page) {
    String url = '$icorrectDomain$getListClassEP?merchant_id=$merchantID&page=$page&check_sum=$checksum';
    return AppRepository.init()
        .sendRequest(RequestMethod.get, url, false)
        .timeout(const Duration(seconds: 15))
        .then((http.Response response) {
      return response.body;
    });
  }

  @override
  Future<String> getListStudent(String merchantID, int classID, String checksum){
    String url = getListStudentEP(classID, merchantID, checksum);
    return AppRepository.init()
        .sendRequest(RequestMethod.get, url, false)
        .timeout(const Duration(seconds: 15))
        .then((http.Response response) {
       return response.body;
    });
  }

  @override
  Future<String> changeDeviceName(String deviceID, String deviceName, String merchantID, String checksum){
    String url = changeDeviceNameEP(deviceID);
    Map<String, dynamic> body = {
      'device_name': deviceName,
      'merchant_id': merchantID,
      'check_sum': checksum
    };
    return AppRepository.init()
        .sendRequest(RequestMethod.put, url, false, body: body)
        .timeout(const Duration(seconds: 20))
        .then((http.Response response) {
       return response.body;
    });

  }

  @override
  Future<String> verifyConfig(String key, String deviceID, String checksum, String merchantID) async {
    String url = icorrectDomain+verifyConfigEP;
    Map<String, dynamic> body = {
      "key": key,
      "device_id": deviceID,
      "merchant_id": merchantID,
      "check_sum": checksum
    };
    return AppRepository.init()
        .sendRequest(RequestMethod.post, url, false, body: body)
        .timeout(const Duration(seconds: 20))
        .then((http.Response response) {
       return response.body;
    });
  }
}
