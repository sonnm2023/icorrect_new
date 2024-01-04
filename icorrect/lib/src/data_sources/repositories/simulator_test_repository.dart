import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/repositories/app_repository.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

abstract class SimulatorTestRepository {
  Future<String> getTestDetailFromHomework({
    required String activityId,
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
  Future<String> getTestDetailFromMyPractice(
      {required Map<String, dynamic> data});
}

class SimulatorTestRepositoryImpl implements SimulatorTestRepository {
  @override
  Future<String> getTestDetailFromHomework({
    required String activityId,
    required String distributeCode,
    required String platform,
    required String appVersion,
    required String deviceId,
  }) {
    String url = '$apiDomain$getTestHomeWorkInfoEP';

    if (kDebugMode) {
      print('DEBUG: START - getTestDetailFromHomework: $url');
      var dataObj = {
        StringConstants.k_activity_id: activityId,
        StringConstants.k_distribute_code: distributeCode,
        StringConstants.k_platform: platform,
        StringConstants.k_app_version: appVersion,
        StringConstants.k_device_id: deviceId,
      };
      String jsonString = json.encode(dataObj);
      print("DEBUG: START - request data: $jsonString");
    }

    return AppRepository.init()
        .sendRequest(
          RequestMethod.post,
          url,
          true,
          false,
          body: <String, String>{
            StringConstants.k_activity_id: activityId,
            StringConstants.k_distribute_code: distributeCode,
            StringConstants.k_platform: platform,
            StringConstants.k_app_version: appVersion,
            StringConstants.k_device_id: deviceId,
          },
        )
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
          final String jsonBody = response.body;
          if (kDebugMode) {
            print("DEBUG: END - response data: $jsonBody");
          }
          return jsonBody;
        });
  }

  @override
  Future<String> getTestDetailFromPractice({
    required int testOption,
    required List<int> topicsId,
    required int isPredict,
  }) {
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
          'DEBUG: SimulatorTestRepositoryImpl - getTestDetailFromPractice: $url');
      var dataObj = {
        StringConstants.k_test_option: testOption,
        StringConstants.k_is_predict: isPredict,
        "topic_ids": topicsId,
      };
      String jsonString = json.encode(dataObj);
      print("DEBUG: request data: $jsonString");
    }

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
      if (kDebugMode) {
        print("DEBUG: END - response data: $jsonBody");
      }
      return jsonBody;
    });
  }

  @override
  Future<String> getTestDetailFromMyPractice(
      {required Map<String, dynamic> data}) {
    String url = '$apiDomain$customPracticeEP';

    var body = json.encode(data);

    if (kDebugMode) {
      print(
          'DEBUG: SimulatorTestRepositoryImpl - getTestDetailFromMyPractice: $url');
      print("DEBUG: request data: $body");
    }

    return AppRepository.init()
        .sendRequest(
          RequestMethod.post,
          url,
          true,
          true,
          body: body,
        )
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
      final String jsonBody = response.body;
      if (kDebugMode) {
        print("DEBUG: END - response data: $jsonBody");
      }
      return jsonBody;
    });
  }

  @override
  Future<String> submitTest(http.MultipartRequest multiRequest) async {
    if (kDebugMode) {
      String url = multiRequest.url.toString();
      print('DEBUG: SimulatorTestRepositoryImpl - submitTest: $url');
      Map<String, dynamic> data = multiRequest.fields;
      List<Map<String, dynamic>> files = [];
      if (multiRequest.files.isNotEmpty) {
        for (var item in multiRequest.files) {
          var obj = {
            "field": item.field,
            "file_name": item.filename,
            "length": item.length,
          };
          files.add(obj);
        }
      }
      var dataObj = {
        "data": data,
        "files": files,
      };
      String jsonString = json.encode(dataObj);
      print("DEBUG: request data: $jsonString");
    }

    return await multiRequest
        .send()
        .timeout(const Duration(seconds: timeout))
        .then((http.StreamedResponse streamResponse) async {
      if (streamResponse.statusCode == 200) {
        return await http.Response.fromStream(streamResponse)
            .timeout(const Duration(seconds: timeout))
            .then((http.Response response) {
          final String jsonBody = response.body;
          if (kDebugMode) {
            print("DEBUG: END - response data: $jsonBody");
          }
          return jsonBody;
        });
      } else {
        if (kDebugMode) {
          print("DEBUG: END - Submit ERROR");
        }
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
    if (kDebugMode) {
      print(
          'DEBUG: SimulatorTestRepositoryImpl - callTestPosition: $testPositionApi');
      var data = {
        StringConstants.k_email: email,
        StringConstants.k_activity_id: activityId,
        "question_index": questionIndex.toString(),
        "user": user,
        "pass": pass,
      };
      String jsonString = json.encode(data);
      print("DEBUG: request data: $jsonString");
    }
    return AppRepository.init()
        .sendRequest(
          RequestMethod.post,
          testPositionApi,
          false,
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
        .then(
          (http.Response response) {
            final String jsonBody = response.body;
            if (kDebugMode) {
              print("DEBUG: END - response data: $jsonBody");
            }
            return jsonBody;
          },
        )
        // ignore: body_might_complete_normally_catch_error
        .catchError(
          (onError) {
            if (kDebugMode) {
              print("DEBUG: END - error: ${onError.toString()}");
            }
          },
        );
  }
}
