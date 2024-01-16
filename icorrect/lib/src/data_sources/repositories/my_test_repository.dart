import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'app_repository.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

abstract class MyTestRepository {
  Future<String> getMyTestDetail(String testId, bool isPracticeTest);
  Future<String> getResponse(String orderId);
  Future<String> getSpecialHomeWorks(
      String email, String activityId, int status, int example);
  Future<String> updateAnswers(http.MultipartRequest multiRequest);
  Future<String> getTestDetailWithId(String testId);
}

class MyTestImpl implements MyTestRepository {
  @override
  Future<String> getMyTestDetail(String testId, bool isPracticeTest) {
    String url = myTestDetailEP(testId);
    if (isPracticeTest) {
      url = getMyPracticeDetailEP(testId);
    }
    if (kDebugMode) {
      print("DEBUG: START - getMyTestDetail: $url");
    }

    return AppRepository.init()
        .sendRequest(RequestMethod.get, url, true, false)
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
      final String jsonBody = response.body;
      if (kDebugMode) {
        print("DEBUG: END - response: $jsonBody");
      }
      return jsonBody;
    });
  }

  @override
  Future<String> getResponse(String orderId) {
    String url = responseEP(orderId);
    if (kDebugMode) {
      print("DEBUG: START - getResponse: $url");
    }

    return AppRepository.init()
        .sendRequest(RequestMethod.get, url, true, false)
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
      final String jsonBody = response.body;
      if (kDebugMode) {
        print("DEBUG: END - response: $jsonBody");
      }
      return jsonBody;
    });
  }

  @override
  Future<String> getSpecialHomeWorks(
      String email, String activityId, int status, int example) {
    String url = specialHomeWorksEP(email, activityId, status, example);

    if (kDebugMode) {
      print("DEBUG: START - getSpecialHomeWorks: $url");
    }

    return AppRepository.init()
        .sendRequest(RequestMethod.get, url, true, false)
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
      final String jsonBody = response.body;
      if (kDebugMode) {
        print("DEBUG: END - response: $jsonBody");
      }
      return jsonBody;
    });
  }

  @override
  Future<String> updateAnswers(http.MultipartRequest multiRequest) async {
    if (kDebugMode) {
      print("DEBUG: START - updateAnswers");
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
            print("DEBUG: END - response: $jsonBody");
          }
          return jsonBody;
        }).catchError((onError) {
          return '';
        });
      } else {
        return '';
      }
    }).catchError((onError) {
      return '';
    });
  }

  @override
  Future<String> getTestDetailWithId(String testId) {
    String url = getTestDetailWithIdEP(testId);

    if (kDebugMode) {
      print("DEBUG: START - getTestDetailWithId: $url");
    }

    return AppRepository.init()
        .sendRequest(RequestMethod.get, url, true, false)
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
      final String jsonBody = response.body;
      if (kDebugMode) {
        print("DEBUG: END - response: $jsonBody");
      }
      return jsonBody;
    });
  }
}
