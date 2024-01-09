import 'dart:convert';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';

class DoingTestService {
  static Future<http.MultipartRequest> formDataRequest({
    required String testId,
    required String activityId,
    required List<QuestionTopicModel> questions,
    required bool isUpdate,
    required Map<String, dynamic>? dataLog,
    required bool isExam,
    required File? videoConfirmFile,
    required List<Map<String, dynamic>>? logAction,
    required int duration,
  }) async {
    String url = submitHomeWorkV2EP();

    if (isExam) {
      url = submitExam();
    }

    if (activityId.isEmpty) {
      url = submitPractice();
    }

    http.MultipartRequest request =
        http.MultipartRequest(RequestMethod.post, Uri.parse(url));
    request.headers.addAll({
      StringConstants.k_content_type: 'multipart/form-data',
      StringConstants.k_authorization: 'Bearer ${await Utils.getAccessToken()}'
    });

    Map<String, String> formData = {};

    formData.addEntries([MapEntry(StringConstants.k_test_id, testId)]);
    if (activityId.isNotEmpty) {
      formData
          .addEntries([MapEntry(StringConstants.k_activity_id, activityId)]);
      formData.addEntries(
          [MapEntry(StringConstants.k_is_update, isUpdate ? '1' : '0')]);
    }

    if (Platform.isAndroid) {
      formData.addEntries([const MapEntry(StringConstants.k_os, "android")]);
    } else {
      formData.addEntries([const MapEntry(StringConstants.k_os, "ios")]);
    }
    String appVersion = await Utils.getAppVersion();
    formData.addEntries([MapEntry(StringConstants.k_app_version, appVersion)]);

    if (null != logAction) {
      if (logAction.isNotEmpty) {
        formData.addEntries(
            [MapEntry(StringConstants.k_log_action, jsonEncode(logAction))]);
      } else {
        formData
            .addEntries([const MapEntry(StringConstants.k_log_action, '[]')]);
      }
    }
    formData.addEntries([MapEntry(StringConstants.k_duration, "$duration")]);

    for (QuestionTopicModel q in questions) {
      String part = '';
      switch (q.numPart) {
        case 0:
          {
            part = "introduce";
            break;
          }
        case 1:
          {
            part = "part1";
            break;
          }
        case 2:
          {
            part = "part2";
            break;
          }
        case 3:
          {
            part = "part3";
            if (q.isFollowUp == 1) {
              part = "followup";
            }
            break;
          }
      }

      String prefix = "$part[${q.id}]";

      List<MapEntry<String, String>> temp = generateFormat(q, prefix);
      if (temp.isNotEmpty) {
        formData.addEntries(temp);
      }

      //For test: don't send answers
      for (int i = 0; i < q.answers.length; i++) {
        String path = await Utils.createNewFilePath(
            q.answers.elementAt(i).url.toString());
        File audioFile = File(path);

        if (await audioFile.exists()) {
          String audioSize = "${audioFile.lengthSync() / (1024 * 1024)} Mb";
          dataLog!.addEntries([MapEntry(q.answers[i].url, audioSize)]);

          request.files.add(
              await http.MultipartFile.fromPath("$prefix[$i]", audioFile.path));
          if (kDebugMode) {
            formData.addEntries([MapEntry("$prefix[$i]", audioFile.path)]);
          }
        }
      }
    }

    if (kDebugMode) {
      print("DEBUG: formdata: ${formData.toString()}");
    }

    if (null != videoConfirmFile) {
      String fileName = videoConfirmFile.path.split('/').last;
      formData
          .addEntries([MapEntry(StringConstants.k_video_confirm, fileName)]);
      request.files.add(await http.MultipartFile.fromPath(
          StringConstants.k_video_confirm, videoConfirmFile.path));
    }

    request.fields.addAll(formData);

    if (null != dataLog) {
      dataLog[StringConstants.k_request_data] = formData.toString();
    }

    return request;
  }

  static List<MapEntry<String, String>> generateFormat(
      QuestionTopicModel q, String suffix) {
    List<MapEntry<String, String>> result = [];

    if (q.answers.isEmpty) return [];

    for (int i = 0; i < q.answers.length; i++) {
      result.add(MapEntry("$suffix[$i]", q.answers[i].url));
    }

    return result;
  }
}
