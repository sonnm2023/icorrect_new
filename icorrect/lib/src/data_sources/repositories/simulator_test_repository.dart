import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/repositories/app_repository.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

abstract class SimulatorTestRepository {
  Future<String> getTestDetail(String homeworkId, String distributeCode);
  Future<String> submitTest(http.MultipartRequest multiRequest);
}

class SimulatorTestRepositoryImpl implements SimulatorTestRepository {
  @override
  Future<String> getTestDetail(String homeworkId, String distributeCode) {
    String url = '$apiDomain$getTestInfoEP';

    return AppRepository.init()
        .sendRequest(
      RequestMethod.post,
      url,
      true,
      body: <String, String>{'activity_id': homeworkId, 'distribute_code': distributeCode},
    )
        .timeout(const Duration(seconds: 15))
        .then((http.Response response) {
      final String jsonBody = response.body;
      return jsonBody;
    });
  }

  @override
  Future<String> submitTest(http.MultipartRequest multiRequest) async {
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
        });
      } else {
        return '';
      }
    });
  }

}