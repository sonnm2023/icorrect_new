import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:http/http.dart' as http;
import 'package:icorrect/src/models/my_practice_test_model/ai_option_model.dart';

import 'app_repository.dart';

abstract class PracticeRepository {
  Future<String> getPracticeTopicsList(List<String> parts, String status);
  Future<String> getMyPracticeList(String pageNum);
  Future<String> deleteTest(String testId);
  Future<String> getMyPracticeDetail(String testId);
  Future<String> getBankList();
  Future<String> getListTopicOfBank(String distributeCode);
  Future<String> getListScoringOrderWithTestId(String testId); //Api 149
  Future<String> getScoringOrderConfigInfoWithId(String testId); //Api 147
  Future<String> calculatePrice({
    required String testId,
    required int amountQuestionsPart1,
    required int amountQuestionsPart2,
    required int amountQuestionsPart3,
    required int typeScoring,
    required AiOption aiOption,
  }); //Api 146
  Future<String> createScoringOrder({required String testId}); //Api 148
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
      print('DEBUG: START - getPracticeTopicsList: $url');
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
      final String jsonBody = response.body;
      if (kDebugMode) {
        print("DEBUG: END - response: $jsonBody");
      }
      return jsonBody;
    });
  }

  @override
  Future<String> getMyPracticeList(String pageNum) {
    String url = getMyPracticeEP(pageNum);
    if (kDebugMode) {
      print('DEBUG: START - getMyPracticeList: $url');
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
      final String jsonBody = response.body;
      if (kDebugMode) {
        print("DEBUG: END - response: $jsonBody");
      }
      return jsonBody;
    });
  }

  @override
  Future<String> deleteTest(String testId) {
    String url = deleteTestEP(testId);
    if (kDebugMode) {
      print('DEBUG: START - deleteTest: $url');
    }

    return AppRepository.init()
        .sendRequest(
          RequestMethod.delete,
          url,
          true,
          false,
        )
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
  Future<String> getMyPracticeDetail(String testId) {
    String url = getMyPracticeDetailEP(testId);
    if (kDebugMode) {
      print('DEBUG: START - getMyPracticeTestDetail: $url');
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
      final String jsonBody = response.body;
      if (kDebugMode) {
        print("DEBUG: END - response: $jsonBody");
      }
      return jsonBody;
    });
  }

  @override
  Future<String> getBankList() {
    String url = '$apiDomain$bankListEP';
    if (kDebugMode) {
      print('DEBUG: START - getBankList: $url');
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
      final String jsonBody = response.body;
      if (kDebugMode) {
        print("DEBUG: END - response: $jsonBody");
      }
      return jsonBody;
    });
  }

  @override
  Future<String> getListTopicOfBank(String distributeCode) {
    String url = getListTopicOfBankEP(distributeCode);
    if (kDebugMode) {
      print('DEBUG: START - getListTopicOfBank: $url');
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
      final String jsonBody = response.body;
      if (kDebugMode) {
        print("DEBUG: END - response: $jsonBody");
      }
      return jsonBody;
    });
  }

  @override
  Future<String> getListScoringOrderWithTestId(String testId) {
    String url = getListScoringOrderWithTestIdEP(testId);
    if (kDebugMode) {
      print('DEBUG: START - getListScoringOrderWithTestId: $url');
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
      final String jsonBody = response.body;
      if (kDebugMode) {
        print("DEBUG: END - response: $jsonBody");
      }
      return jsonBody;
    });
  }

  @override
  Future<String> getScoringOrderConfigInfoWithId(String testId) {
    String url = getScoringOrderConfigInfoEP(testId);
    if (kDebugMode) {
      print('DEBUG: START - getScoringOrderConfigInfoWithId: $url');
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
      final String jsonBody = response.body;
      if (kDebugMode) {
        print("DEBUG: END - response: $jsonBody");
      }
      return jsonBody;
    });
  }

  @override
  Future<String> calculatePrice(
      {required String testId,
      required int amountQuestionsPart1,
      required int amountQuestionsPart2,
      required int amountQuestionsPart3,
      required int typeScoring,
      required AiOption aiOption}) {
    String url = calculateOrderPriceEP(testId);
    if (kDebugMode) {
      print('DEBUG: START - calculatePrice: $url');
    }
    //For test - start
    if (amountQuestionsPart2 == 0) {
      amountQuestionsPart2 += 1;
    }

    if (amountQuestionsPart3 == 0) {
      amountQuestionsPart3 += 1;
    }
    //For test - end

    return AppRepository.init()
        .sendRequest(
          RequestMethod.post,
          url,
          true,
          false,
          body: <String, String>{
            StringConstants.k_amount_questions_part1: "$amountQuestionsPart1",
            StringConstants.k_amount_questions_part2: "$amountQuestionsPart2",
            StringConstants.k_amount_questions_part3: "$amountQuestionsPart3",
            StringConstants.k_type_scoring: "$typeScoring",
            StringConstants.k_ai_option: aiOption.option.toString(),
          },
        )
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
  Future<String> createScoringOrder({required String testId}) {
    String url = createScoringOrderEP(testId);
    if (kDebugMode) {
      print('DEBUG: START - createScoringOrder: $url');
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
        print("DEBUG: END - response: $jsonBody");
      }
      return jsonBody;
    });
  }
}
