import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/repositories/simulator_test_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

abstract class TestRoomViewContract {
  void onPlayIntroduceFile(String fileName);
  void onPlayEndOfTakeNoteFile(String fileName);
  void onPlayEndOfTest(String fileName);
  void onCountDown(String countDownString);
  void onCountDownForCueCard(String countDownString);
  void onFinishAnswer(bool isPart2);
  void onSubmitTestSuccess(String msg);
  void onSubmitTestFail(String msg);
  void onClickSaveTheTest();
  void onFinishTheTest();

  void onNothingFileEndOfTest();
  void onNothingEndOfTest();
  void onNothingFileQuestion();
  void onNothingQuestion();
  void onNothingFileEndOfTakeNote();
  void onNothingEndOfTakeNote();
  void onNothingFileIntroduce();
  void onNothingIntroduce();
}

class TestRoomPresenter {
  final TestRoomViewContract? _view;
  SimulatorTestRepository? _testRepository;

  TestRoomPresenter(this._view) {
    _testRepository = Injector().getTestRepository();
  }

  Future<void> startPart(Queue<TopicModel> topicsQueue) async {
    TopicModel currentPart = topicsQueue.first;

    //Play introduce file of part
    _playIntroduce(currentPart);
  }

  Future<void> _playIntroduce(TopicModel topicModel) async {
    List<FileTopicModel> files = topicModel.files;
    if (files.isNotEmpty) {
      FileTopicModel file = files.first;
      bool isExist = await _isExist(file.url, MediaType.video, null);
      if (isExist) {
        _view!.onPlayIntroduceFile(file.url);
      } else {
        //TODO: Download again
      }
    } else {
      if (kDebugMode) print("This topic has not introduce file");
    }
  }

  //Check file is exist using file_storage
  Future<bool> _isExist(String fileName, MediaType mediaType, String? testId) async {
    bool isExist = await FileStorageHelper.checkExistFile(
        fileName, mediaType, testId);
    return isExist;
  }

  Timer startCountDown(
      {required BuildContext context,
      required int count,
      required bool isPart2}) {
    bool finishCountDown = false;
    const oneSec = Duration(seconds: 1);
    return Timer.periodic(oneSec, (Timer timer) {
      if (count < 1) {
        timer.cancel();
      } else {
        count = count - 1;
      }

      dynamic minutes = count ~/ 60;
      dynamic seconds = count % 60;

      dynamic minuteStr = minutes.toString().padLeft(2, '0');
      dynamic secondStr = seconds.toString().padLeft(2, '0');

      _view!.onCountDown("$minuteStr:$secondStr");

      if (count == 0 && !finishCountDown) {
        finishCountDown = true;
        _view!.onFinishAnswer(isPart2);
      }
    });
  }

  Timer startCountDownForCueCard(
      {required BuildContext context,
      required int count,
      required bool isPart2}) {
    bool finishCountDown = false;
    const oneSec = Duration(seconds: 1);
    return Timer.periodic(oneSec, (Timer timer) {
      if (count < 1) {
        timer.cancel();
      } else {
        count = count - 1;
      }

      dynamic minutes = count ~/ 60;
      dynamic seconds = count % 60;

      dynamic minuteStr = minutes.toString().padLeft(2, '0');
      dynamic secondStr = seconds.toString().padLeft(2, '0');

      _view!.onCountDownForCueCard("$minuteStr:$secondStr");

      if (count == 0 && !finishCountDown) {
        finishCountDown = true;
        _view!.onFinishAnswer(isPart2);
      }
    });
  }

  Future<void> playEndOfTakeNoteFile(TopicModel topic) async {
    String fileName = topic.endOfTakeNote.url;

    if (fileName.isNotEmpty) {
      bool isExist = await _isExist(fileName, MediaType.video, null);
      if (isExist) {
        _view!.onPlayEndOfTakeNoteFile(fileName);
      } else {
        //TODO: download again
      }
    } else {
      if (kDebugMode) print("This topic has not end of take note file");
    }
  }

  void clickEndReAnswer(QuestionTopicModel question, String filePath) {
    //TODO:
    if (kDebugMode) print("clickEndReAnswer");
  }

  void clickSaveTheTest() {
    _view!.onClickSaveTheTest();
  }

  Future<void> playEndOfTestFile(TopicModel topic) async {
    String fileName = topic.fileEndOfTest.url;

    if (fileName.isNotEmpty) {
      bool isExist = await _isExist(fileName, MediaType.video, null);
      if (isExist) {
        _view!.onPlayEndOfTest(fileName);
      } else {
        //TODO: Download again
      }
    } else {
      //The test has not End of test file
      _view!.onFinishTheTest();
    }
  }

  Future<void> submitTest({
    required String testId,
    required String activityId,
    required List<QuestionTopicModel> questions,
  }) async {
    assert(_view != null && _testRepository != null);

    http.MultipartRequest multiRequest = await _formDataRequest(
      testId: testId,
      activityId: activityId,
      questions: questions,
    );

    if (kDebugMode) {
      print(multiRequest.fields[testId]);
      print(multiRequest.fields[activityId]);
    }

    try {
      _testRepository!.submitTest(multiRequest).then((value) {
        Map<String, dynamic> json = jsonDecode(value) ?? {};
        if (json['error_code'] == 200) {
          _view!.onSubmitTestSuccess('Save your answers successfully!');
        } else {
          _view!.onSubmitTestFail("Has an error when submit this test!");
        }
      }).catchError((onError) =>
          // ignore: invalid_return_type_for_catch_error
          _view!.onSubmitTestFail("Has an error when submit this test!"));
    } on TimeoutException {
      _view!.onSubmitTestFail("Has an error when submit this test!");
    } on SocketException {
      _view!.onSubmitTestFail("Has an error when submit this test!");
    } on http.ClientException {
      _view!.onSubmitTestFail("Has an error when submit this test!");
    }
  }

  List<MapEntry<String, String>> _generateFormat(
      QuestionTopicModel q, String suffix) {
    List<MapEntry<String, String>> result = [];

    if (q.answers.isEmpty) return [];

    for (int i = 0; i < q.answers.length; i++) {
      result.add(MapEntry("$suffix[$i]", q.answers[i].url));
    }

    return result;
  }

  Future<http.MultipartRequest> _formDataRequest({
    required String testId,
    required String activityId,
    required List<QuestionTopicModel> questions,
  }) async {
    String url = submitHomeWorkEP();
    http.MultipartRequest request =
        http.MultipartRequest(RequestMethod.post, Uri.parse(url));
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${await Utils.getAccessToken()}'
    });

    Map<String, String> formData = {};

    formData.addEntries([MapEntry('test_id', testId)]);
    formData.addEntries([MapEntry('activity_id', activityId)]);

    if (Platform.isAndroid) {
      formData.addEntries([const MapEntry('os', "android")]);
    } else {
      formData.addEntries([const MapEntry('os', "ios")]);
    }
    formData.addEntries([const MapEntry('app_version', '2.0.2')]);

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

      List<MapEntry<String, String>> temp = _generateFormat(q, prefix);
      if (temp.isNotEmpty) {
        formData.addEntries(temp);
      }

      for (int i = 0; i < q.answers.length; i++) {
        File audioFile = File(
          await FileStorageHelper.getFilePath(
              q.answers.elementAt(i).url.toString(),
              MediaType.audio,
              testId),
        );

        if (await audioFile.exists()) {
          request.files
              .add(await http.MultipartFile.fromPath(prefix, audioFile.path));
        }
      }
    }

    request.fields.addAll(formData);

    return request;
  }
}
