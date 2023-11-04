import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/repositories/app_repository.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

abstract class SimulatorTestRepository {
  Future<String> getTestDetail({
    required String homeworkId,
    required String distributeCode,
    required String platform,
    required String appVersion,
    required String deviceId,
  });
  Future<String> submitTest(http.MultipartRequest multiRequest);
  Future<String> callTestPosition({
    required String email,
    required String activityId,
    required int questionIndex,
    required String user,
    required String pass,
  });
}

class SimulatorTestRepositoryImpl implements SimulatorTestRepository {
  @override
  Future<String> getTestDetail({
    required String homeworkId,
    required String distributeCode,
    required String platform,
    required String appVersion,
    required String deviceId,
  }) {
    String url = '$apiDomain$getTestInfoEP';

    return AppRepository.init()
        .sendRequest(
          RequestMethod.post,
          url,
          true,
          body: <String, String>{
            StringConstants.k_activity_id: homeworkId,
            StringConstants.k_distribute_code: distributeCode,
            StringConstants.k_platform: platform,
            StringConstants.k_app_version: appVersion,
            StringConstants.k_device_id: deviceId,
          },
        )
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
          final String jsonBody = response.body;
          return jsonBody;
        });
  }

  @override
  Future<String> submitTest(http.MultipartRequest multiRequest) async {
    return await multiRequest
        .send()
        .timeout(const Duration(seconds: timeout))
        .then((http.StreamedResponse streamResponse) async {
      if (streamResponse.statusCode == 200) {
        return await http.Response.fromStream(streamResponse)
            .timeout(const Duration(seconds: timeout))
            .then((http.Response response) {
          final String jsonBody = response.body;
          return jsonBody;
        });
      } else {
        return '';
      }
    });
  }

  @override
  Future<String> callTestPosition({
    required String email,
    required String activityId,
    required int questionIndex,
    required String user,
    required String pass
  }) async {
    return AppRepository.init()
        .sendRequest(
      RequestMethod.post,
      testPositionApi,
      false,
      body: <String, String>{
        StringConstants.k_email: email,
        StringConstants.k_activity_id: activityId,
        "question_index": questionIndex.toString(),
        "user": user,
        "pass": pass,
      },
    )
        .timeout(const Duration(seconds: timeout))
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
}
