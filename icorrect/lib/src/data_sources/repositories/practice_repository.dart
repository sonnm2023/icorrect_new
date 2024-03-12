import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:http/http.dart' as http;
import 'package:icorrect/src/data_sources/utils.dart';

import 'app_repository.dart';

abstract class PracticeRepository {
  Future<String> getPracticeTopicsList(IELTSPartType partType, String status);
  Future<String> getMyPracticeTestList(String pageNum);
  Future<String> deleteTest(String testId);
  Future<String> getMyPracticeTestDetail(String testId);
  Future<String> getBankList();
  Future<String> getListTopicOfBank(String distributeCode);
}

class PracticeReporitoryImpl implements PracticeRepository {
  @override
  Future<String> getPracticeTopicsList(IELTSPartType partType, String status) {
    Map<String, String> queryParams = {
      StringConstants.k_status: status,
    };

    List<String> topicTypeParameters = Utils.convertPartTypeToString(partType);
    for (int i = 0; i < topicTypeParameters.length; i++) {
      queryParams
          .addEntries([MapEntry(StringConstants.k_topic_type, topicTypeParameters[i])]);
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
          false,
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
          false,
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
          false,
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
          false,
        )
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
      return response.body;
    });
  }

  @override
  Future<String> getBankList() {
    String url = '$apiDomain$bankListEP';
    return AppRepository.init()
        .sendRequest(
          RequestMethod.get,
          url,
          true,
          false,
        )
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
      return response.body;
    });
  }

  @override
  Future<String> getListTopicOfBank(String distributeCode) {
    String url = getListTopicOfBankEP(distributeCode);
    return AppRepository.init()
        .sendRequest(
          RequestMethod.get,
          url,
          true,
          false,
        )
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
      return response.body;
    });
  }
}
