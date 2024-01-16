import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';

import 'app_repository.dart';
import 'package:http/http.dart' as http;

abstract class UserAuthRepository {
  Future<String> getUserAuthDetail();
  Future<String> submitAuth(http.MultipartRequest multiRequest);
}

class UserAuthRepositoryImpl implements UserAuthRepository {
  @override
  Future<String> getUserAuthDetail() {
    String url = getUserAuthDetailEP();

    if (kDebugMode) {
      print('DEBUG: START - getUserAuthDetail: $url');
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
  Future<String> submitAuth(http.MultipartRequest multiRequest) async {
    if (kDebugMode) {
      print('DEBUG: START - submitAuth');
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
}
