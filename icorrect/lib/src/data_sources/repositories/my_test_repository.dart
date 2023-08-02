import '../api_urls.dart';
import 'app_repository.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

abstract class MyTestRepository {
  Future<String> getMyTestDetail(String testId);
  Future<String> getResponse(String orderId);
  Future<String> getSpecialHomeWorks(
      String email, String activityId, int status, int example);
  Future<String> updateAnswers(http.MultipartRequest multiRequest);
  Future<String> getTestDetailWithId(String testId);
}

class MyTestImpl implements MyTestRepository {
  @override
  Future<String> getMyTestDetail(String testId) {
    String url = myTestDetailEP(testId);
    return AppRepository.init()
        .sendRequest(RequestMethod.get, url, true)
        .timeout(const Duration(seconds: 15))
        .then((http.Response response) {
      final String jsonBody = response.body;
      return jsonBody;
    });
  }

  @override
  Future<String> getResponse(String orderId) {
    String url = responseEP(orderId);
    return AppRepository.init()
        .sendRequest(RequestMethod.get, url, true)
        .timeout(const Duration(seconds: 15))
        .then((http.Response response) {
      final String jsonBody = response.body;
      return jsonBody;
    });
  }

  @override
  Future<String> getSpecialHomeWorks(
      String email, String activityId, int status, int example) {
    String url = specialHomeWorksEP(email, activityId, status, example);
    return AppRepository.init()
        .sendRequest(RequestMethod.get, url, true)
        .timeout(const Duration(seconds: 15))
        .then((http.Response response) {
      final String jsonBody = response.body;
      return jsonBody;
    });
  }

  @override
  Future<String> updateAnswers(http.MultipartRequest multiRequest) async {
    return await multiRequest
        .send()
        .timeout(const Duration(seconds: 15))
        .then((http.StreamedResponse streamResponse) async {
      if (streamResponse.statusCode == 200) {
        return await http.Response.fromStream(streamResponse)
            .timeout(const Duration(seconds: 15))
            .then((http.Response response) {
          final String jsonBody = response.body;
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
    return AppRepository.init()
        .sendRequest(RequestMethod.get, url, true)
        .timeout(const Duration(seconds: 15))
        .then((http.Response response) {
      final String jsonBody = response.body;
      return jsonBody;
    });
  }
}
