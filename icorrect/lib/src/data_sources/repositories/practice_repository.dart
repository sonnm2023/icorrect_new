import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:http/http.dart' as http;

import 'app_repository.dart';

abstract class PracticeRepository {
  Future<String> getPracticeTopicsList(List<String> parts, String status);
  Future<String> getMyPracticeTestList(String pageNum);
  Future<String> deleteTest(String testId);
  Future<String> getMyPracticeTestDetail(String testId);
}

class PracticeReporitoryImpl implements PracticeRepository {
  @override
  Future<String> getPracticeTopicsList(List<String> parts, String status) {
    Map<String, String> queryParams = {
      StringConstants.k_status: status,
    };
    for (int i = 0; i < parts.length; i++) {
      queryParams
          .addEntries([MapEntry(StringConstants.k_topic_type, parts[i])]);
    }

    String url = getPracticeTopicsListEP(queryParams);

    if (kDebugMode) {
      print('DEBUG: PracticeReporitoryImpl - url :$url');
    }
    return AppRepository.init()
        .sendRequest(
          RequestMethod.get,
          url,
          true,
        )
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
      return response.body;
    });
  }

  @override
  Future<String> getMyPracticeTestList(String pageNum) {
    String url = getMyPracticeTestEP(pageNum);
    return AppRepository.init()
        .sendRequest(
          RequestMethod.get,
          url,
          true,
        )
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
      return response.body;
    });
  }

  @override
  Future<String> deleteTest(String testId) {
    String url = deleteTestEP(testId);
    return AppRepository.init()
        .sendRequest(
          RequestMethod.delete,
          url,
          true,
        )
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
      return response.body;
    });
  }

  @override
  Future<String> getMyPracticeTestDetail(String testId) {
    String url = getMyPracticeTestDetailEP(testId);
    return AppRepository.init()
        .sendRequest(
          RequestMethod.get,
          url,
          true,
        )
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
      return response.body;
    });
  }
}
