import '../api_urls.dart';
import 'app_repository.dart';
import 'package:http/http.dart' as http;

abstract class MyTestRepository {
  Future<String> getResponse(String orderId);
  Future<String> getSpecialHomeWorks(
      String email, String activityId, int status, int example);
}

class MyTestImpl implements MyTestRepository {
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
}
