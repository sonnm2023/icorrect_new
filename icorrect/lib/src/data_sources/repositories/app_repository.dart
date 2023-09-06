import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/utils.dart';

class AppRepository {
  AppRepository._();
  static final AppRepository _repositories = AppRepository._();
  factory AppRepository.init() => _repositories;

  Future<http.Response> sendRequest(method, String url, bool hasToken,
      {Object? body, Encoding? encoding}) async {
    Map<String, String> headers = {
      'Accept': 'application/json',
    };

    if (hasToken == true) {
      String token = await Utils.getAccessToken();
      headers['Authorization'] = 'Bearer $token';
    }

    if (method == RequestMethod.get) {
      return http.get(Uri.parse(url), headers: headers);
    }

    if (method == RequestMethod.post) {
      return http.post(Uri.parse(url),
          headers: headers, body: body, encoding: encoding);
    }

    if (method == RequestMethod.put) {
      return http.put(Uri.parse(url),
          headers: headers, body: body, encoding: encoding);
    }
    if (method == RequestMethod.patch) {
      return http.patch(Uri.parse(url),
          headers: headers, body: body, encoding: encoding);
    }

    if (method == RequestMethod.delete) {
      return http.delete(Uri.parse(url),
          headers: headers, body: body, encoding: encoding);
    }

    return http.get(Uri.parse(url), headers: headers);
  }

  Future<http.StreamedResponse> pushFileWAV(
      String url, Map<String, String> formData, List<File> files) async {
    var request = http.MultipartRequest(RequestMethod.post, Uri.parse(url));

    String accessToken = await Utils.getAccessToken();
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $accessToken'
    });

    for (File file in files) {
      File audioFile = File('${file.path}.wav');
      request.files
          .add(await http.MultipartFile.fromPath('audio', audioFile.path));
    }
    request.fields.addAll(formData);

    return await request.send();
  }
}