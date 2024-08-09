// ignore: depend_on_referenced_packages
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../api_urls.dart';
import '../constants.dart';
import 'app_repository.dart';

abstract class SimulatorTestRepository {
  Future<String> getTestDetailByHomeWork(
      String homeworkId, String distributeCode);
  Future<String> getTestDetailByPractice(
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
  final int timeOutForSubmit = 600;
  @override
  Future<String> getTestDetailByHomeWork(
      String homeworkId, String distributeCode) {
    String url = '$apiDomain$getTestHomeWorkInfoEP';

    return AppRepository.init()
        .sendRequest(
          RequestMethod.post,
          url,
          true,
          body: <String, String>{
            'activity_id': homeworkId,
            'distribute_code': distributeCode,
            'platform': "pc_flutter",
            'app_version': '1.1.0',
            'device_id': '22344663212',
          },
        )
        .timeout(Duration(seconds: timeOutForSubmit))
        .then((http.Response response) {
          final String jsonBody = response.body;
          return jsonBody;
        });
  }

  @override
  Future<String> getTestDetailByPractice(
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
        .timeout(Duration(seconds: timeOutForSubmit))
        .then((http.StreamedResponse streamResponse) async {
      if (streamResponse.statusCode == 200) {
        return await http.Response.fromStream(streamResponse)
            .timeout(Duration(seconds: timeOutForSubmit))
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
      required String pass}) {
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
