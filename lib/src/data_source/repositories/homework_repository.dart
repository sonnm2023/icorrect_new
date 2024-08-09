import 'package:flutter/foundation.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/utils/utils.dart';

import '../api_urls.dart';
import 'app_repository.dart';
import 'package:http/http.dart' as http;

abstract class HomeWorkRepository {
  Future<String> getHomeWorks(String email,String status);
  Future<String> getSyllabusMerchant(String merchantId, String checksum, int page);
  Future<String> getFilesSyllabus(int id, int page, String merchantID, String checksum);
}

class HomeWorkRepositoryImpl implements HomeWorkRepository {
  @override
  Future<String> getHomeWorks(String email,String status) async {

     Map<String, String> queryParameters = {'email': email, 'status': status};
    String url = getActivitiesList(1);
            
    if (kDebugMode) {
      print('DEBUG: HomeWorkRepositoryImpl - url :$url');
    }
    return AppRepository.init()
        .sendRequest(
          RequestMethod.get,
          url,
          true,
        )
        .timeout(const Duration(seconds: 20))
        .then((http.Response response) {
      return response.body;
    });
  }

  @override
  Future<String> getSyllabusMerchant(String merchantId, String checksum, int page) async {
    String url = '$icorrectDomain$getListSyllabusEP?merchant_id=$merchantId&page=$page&check_sum=$checksum';
    return AppRepository.init().sendRequest(RequestMethod.get, url, true)
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response) {
          return response.body;
    });
  }

  @override
  Future<String> getFilesSyllabus(int id, int page, String merchantID, String checksum) {
    String url = getListFilesSyllabusEP(id, page, merchantID, checksum);
    print(url);
    return AppRepository.init()
        .sendRequest(RequestMethod.get, url, false)
        .timeout(const Duration(seconds: timeout))
        .then((http.Response response){
          return response.body;
    });
  }
}
