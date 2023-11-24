import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/repositories/app_repository.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

abstract class SimulatorTestRepository {
  Future<String> getTestDetailFromHomework({
    required String homeworkId,
    required String distributeCode,
    required String platform,
    required String appVersion,
    required String deviceId,
  });

  Future<String> getTestDetailFromPractice(
      {required int testOption,
      required List<int> topicsId,
      required int isPredict});
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
  Future<String> getTestDetailFromHomework({
    required String homeworkId,
    required String distributeCode,
    required String platform,
    required String appVersion,
    required String deviceId,
  }) {
    String url = '$apiDomain$getTestHomeWorkInfoEP';

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
  Future<String> getTestDetailFromPractice(
      {required int testOption,
      required List<int> topicsId,
      required int isPredict}) {
    Map<String, String> queryParams = {
      StringConstants.k_test_option: "$testOption",
      StringConstants.k_is_predict: "$isPredict",
    };

    String url = getTestPracticeInfoEP(queryParams);

    for (int i = 0; i < topicsId.length; i++) {
      url += "&${StringConstants.k_required_topic}=${topicsId[i]}";
      // queryParams.addEntries(
      //     [MapEntry(StringConstants.k_required_topic, "${topicsId[i]}")]);
    }

    if (kDebugMode) {
      print(
          "DEBUG: topics length: ${topicsId.length} Practice create test url: $url");
    }

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
  Future<String> callTestPosition(
      {required String email,
      required String activityId,
      required int questionIndex,
      required String user,
      required String pass}) async {
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
