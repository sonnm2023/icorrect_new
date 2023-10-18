import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/repositories/app_repository.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

abstract class SimulatorTestRepository {
  Future<String> getTestDetail({
    required String homeworkId,
    required String distributeCode,
    required String platform,
    required String appVersion,
    required String deviceId,
  });
  Future<String> submitTest(http.MultipartRequest multiRequest);
}

class SimulatorTestRepositoryImpl implements SimulatorTestRepository {
  @override
  Future<String> getTestDetail({
    required String homeworkId,
    required String distributeCode,
    required String platform,
    required String appVersion,
    required String deviceId,
  }) {
    String url = '$apiDomain$getTestInfoEP';

    return AppRepository.init()
        .sendRequest(
          RequestMethod.post,
          url,
          true,
          body: <String, String>{
            'activity_id': homeworkId,
            'distribute_code': distributeCode,
            'platform': platform,
            'app_version': appVersion,
            'device_id': deviceId,
          },
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
}
