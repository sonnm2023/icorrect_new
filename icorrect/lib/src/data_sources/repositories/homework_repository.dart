import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/repositories/app_repository.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

abstract class HomeWorkRepository {
  Future<String> getListHomeWork(String email, String status);
}

class HomeWorkRepositoryImpl implements HomeWorkRepository {
  @override
  Future<String> getListHomeWork(String email, String status) {
    Map<String, String> queryParameters = {'email': email, 'status': status};
    String url =
        '${publicDomain}api/list-activity-v2?${Uri(queryParameters: queryParameters).query}';

    return AppRepository.init()
        .sendRequest(
          RequestMethod.get,
          url,
          true,
        )
        .timeout(const Duration(seconds: 15))
        .then((http.Response response) {
      return response.body;
    });
  }
}
