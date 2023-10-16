import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/repositories/simulator_test_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

abstract class TestRoomViewContract {
  void onPlayIntroduce();
  void onPlayEndOfTakeNote(String fileName);
  void onPlayEndOfTest(String fileName);
  void onCountDown(String countDownString, bool isLessThan2Seconds);
  void onCountDownForCueCard(String countDownString);
  void onFinishAnswer(bool isPart2);
  void onFinishForReAnswer();
  void onCountRecordingVideo(int currentCount);
  void onLimitedRecordingVideo();
  void onSubmitTestSuccess(String msg);
  void onSubmitTestFail(String msg);
  void onUpdateReAnswersSuccess(String msg);
  void onUpdateReAnswersFail(String msg);
  void onClickSaveTheTest();
  void onFinishTheTest();
  void onReDownload();
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
      bool isExist = await FileStorageHelper.checkExistFile(
          file.url, MediaType.video, null);
      if (isExist) {
        _view!.onPlayIntroduce();
      } else {
        _view!.onReDownload();
      }
    } else {
      if (kDebugMode) {
        print("DEBUG: This topic has not introduce file");
      }
    }
  }

  Timer startCountDown(
      {required BuildContext context,
      required int count,
      required bool isPart2,
      required bool isReAnswer,
      required bool isLessThan2Seconds}) {
    int temp = count;
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

      if ((temp - count) >= 2) {
        isLessThan2Seconds = false;
      }

      _view!.onCountDown("$minuteStr:$secondStr", isLessThan2Seconds);

      if (count == 0 && !finishCountDown) {
        finishCountDown = true;
        if (isReAnswer) {
          //For Re answer
          _view!.onFinishForReAnswer();
        } else {
          //For answer
          _view!.onFinishAnswer(isPart2);
        }
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

  Timer startCountRecording({required int countFrom}) {
    bool finishCountDown = false;
    const oneSec = Duration(seconds: 1);
    return Timer.periodic(oneSec, (Timer timer) {
      if (countFrom < 1) {
        timer.cancel();
      } else {
        countFrom = countFrom - 1;
      }

      _view!.onCountRecordingVideo(countFrom);

      if (countFrom == 0 && !finishCountDown) {
        finishCountDown = true;
        _view!.onLimitedRecordingVideo();
      }
    });
  }

  Future<void> playEndOfTakeNoteFile(TopicModel topic) async {
    String fileName = topic.endOfTakeNote.url;

    if (fileName.isNotEmpty) {
      bool isExist = await FileStorageHelper.checkExistFile(
          fileName, MediaType.video, null);
      if (isExist) {
        _view!.onPlayEndOfTakeNote(fileName);
      } else {
        _view!.onReDownload();
      }
    } else {
      if (kDebugMode) {
        print("DEBUG: This topic has not end of take note file");
      }
    }
  }

  void clickSaveTheTest() {
    _view!.onClickSaveTheTest();
  }

  Future<void> playEndOfTestFile(TopicModel topic) async {
    String fileName = topic.fileEndOfTest.url;

    if (fileName.isNotEmpty) {
      bool isExist = await FileStorageHelper.checkExistFile(
          fileName, MediaType.video, null);
      if (isExist) {
        _view!.onPlayEndOfTest(fileName);
      } else {
        _view!.onReDownload();
      }
    } else {
      //The test has not End of test file
      _view!.onFinishTheTest();
    }
  }

/////////////////////////Random Topic to record video user ////////////////////
  void recodingUserDoesTestListener(
      {required TopicModel randomTopic,
      required TopicModel currentTopic,
      required QuestionTopicModel currentQuestion,
      required Function startRecordingVideo,
      required Function stopRecordingVideo}) {
    print("DEBUG: part Topic : ${randomTopic.numPart.toString()}");
    if (_canStartRecording(randomTopic, currentTopic)) {
      startRecordingVideo();
    }
    List<QuestionTopicModel> questions = randomTopic.questionList;
    QuestionTopicModel question = _questionForStopRecording(questions);
    if (_isStopRecodingVideo(currentQuestion, question)) {
      stopRecordingVideo();
    }
  }

  TopicModel getTopicModelRandom({required List<TopicModel> topicsList}) {
    Random random = Random();
    int randomIndex = random.nextInt(topicsList.length);

    return topicsList.elementAt(randomIndex);
  }

  bool _canStartRecording(TopicModel randomTopic, TopicModel currentTopic) {
    return randomTopic.id == currentTopic.id;
  }

  final _limitedMaxQuestion = 3;
  QuestionTopicModel _questionForStopRecording(
      List<QuestionTopicModel> questions) {
    return (questions.length - 1 >= _limitedMaxQuestion)
        ? questions[_limitedMaxQuestion]
        : questions[questions.length - 1];
  }

  bool _isStopRecodingVideo(
      QuestionTopicModel currentQuestion, QuestionTopicModel questionLimited) {
    return currentQuestion != QuestionTopicModel() &&
        currentQuestion.id == questionLimited.id;
  }

  Future<void> submitTest({
    required BuildContext context,
    required String testId,
    required String activityId,
    required List<QuestionTopicModel> questions,
    required bool isExam,
    required File? videoConfirmFile,
    required List<Map<String, dynamic>>? logAction,
  }) async {
    assert(_view != null && _testRepository != null);

    //Add log
    LogModel? log;
    Map<String, dynamic> dataLog = {};

    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiSubmitTest);
    }

    http.MultipartRequest multiRequest = await _formDataRequest(
      testId: testId,
      activityId: activityId,
      questions: questions,
      isUpdate: false,
      dataLog: dataLog,
      isExam: isExam,
      videoConfirmFile: videoConfirmFile,
      logAction: logAction,
    );

    if (kDebugMode) {
      print("DEBUG: submitTest");
      print("DEBUG: testId = $testId");
      print("DEBUG: activityId = $activityId");
    }

    try {
      _testRepository!.submitTest(multiRequest).then((value) {
        if (kDebugMode) {
          print("DEBUG: submit response: $value");
        }

        Map<String, dynamic> json = jsonDecode(value) ?? {};
        dataLog['response'] = json;

        if (json['error_code'] == 200) {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: null,
            status: LogEvent.success,
          );

          _view!.onSubmitTestSuccess('Save your answers successfully!');
        } else {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: "Has an error when submit this test!",
            status: LogEvent.failed,
          );

          _view!.onSubmitTestFail("Has an error when submit this test!");
        }
      }).catchError((onError) {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: dataLog,
          message: onError.toString(),
          status: LogEvent.failed,
        );

        // ignore: invalid_return_type_for_catch_error
        _view!.onSubmitTestFail(
            "invalid_return_type_for_catch_error: Has an error when submit this test!");
      });
    } on TimeoutException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "TimeoutException: Has an error when submit this test!",
        status: LogEvent.failed,
      );

      _view!.onSubmitTestFail(
          "TimeoutException: Has an error when submit this test!");
    } on SocketException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "SocketException: Has an error when submit this test!",
        status: LogEvent.failed,
      );

      _view!.onSubmitTestFail(
          "SocketException: Has an error when submit this test!");
    } on http.ClientException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "ClientException: Has an error when submit this test!",
        status: LogEvent.failed,
      );

      _view!.onSubmitTestFail(
          "ClientException: Has an error when submit this test!");
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
    required bool isUpdate,
    required Map<String, dynamic>? dataLog,
    required bool isExam,
    required File? videoConfirmFile,
    required List<Map<String, dynamic>>? logAction,
  }) async {
    String url = submitHomeWorkV2EP();

    if (isExam) {
      url = submitExam();
    }

    http.MultipartRequest request =
        http.MultipartRequest(RequestMethod.post, Uri.parse(url));
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${await Utils.getAccessToken()}'
    });

    Map<String, String> formData = {};

    formData.addEntries([MapEntry('test_id', testId)]);
    formData.addEntries([MapEntry('activity_id', activityId)]);
    formData.addEntries([MapEntry('is_update', isUpdate ? '1' : '0')]);

    if (Platform.isAndroid) {
      formData.addEntries([const MapEntry('os', "android")]);
    } else {
      formData.addEntries([const MapEntry('os', "ios")]);
    }
    String appVersion = await Utils.getAppVersion();
    formData.addEntries([MapEntry('app_version', appVersion)]);

    if (null != logAction) {
      if (logAction.isNotEmpty) {
        formData.addEntries([MapEntry('log_action', logAction.toString())]);
      } else {
        formData.addEntries([const MapEntry('log_action', '[]')]);
      }
    }

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
        String path = await FileStorageHelper.getFilePath(
            q.answers.elementAt(i).url.toString(), MediaType.audio, testId);
        File audioFile = File(path);

        if (await audioFile.exists()) {
          request.files.add(
              await http.MultipartFile.fromPath("$prefix[$i]", audioFile.path));
        }
      }
    }

    if (null != videoConfirmFile) {
      String fileName = videoConfirmFile.path.split('/').last;
      formData.addEntries([MapEntry('video_confirm', fileName)]);
      request.files.add(await http.MultipartFile.fromPath(
          'video_confirm', videoConfirmFile.path));
    }

    request.fields.addAll(formData);

    if (null != dataLog) {
      dataLog['request_data'] = formData.toString();
    }

    return request;
  }

  Future updateMyAnswer({
    required BuildContext context,
    required String testId,
    required String activityId,
    required List<QuestionTopicModel> reQuestions,
    required bool isExam,
  }) async {
    //Add log
    LogModel? log;
    Map<String, dynamic>? dataLog = {};

    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiUpdateAnswer);
    }

    http.MultipartRequest multiRequest = await _formDataRequest(
      testId: testId,
      activityId: activityId,
      questions: reQuestions,
      isUpdate: true,
      dataLog: dataLog,
      isExam: isExam,
      videoConfirmFile: null,
      logAction: null,
    );
    if (kDebugMode) {
      print("DEBUG: submitTest");
      print("DEBUG: testId = $testId");
      print("DEBUG: activityId = $activityId");
    }

    try {
      _testRepository!.submitTest(multiRequest).then((value) {
        if (kDebugMode) {
          print("DEBUG: submit response: $value");
        }

        Map<String, dynamic> json = jsonDecode(value) ?? {};
        dataLog['response'] = json;

        if (json['error_code'] == 200) {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: null,
            status: LogEvent.success,
          );

          _view!.onUpdateReAnswersSuccess('Save your answers successfully!');
        } else {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: "Has an error when submit this test!",
            status: LogEvent.failed,
          );

          _view!.onUpdateReAnswersFail("Has an error when submit this test!");
        }
      }).catchError((onError) {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: dataLog,
          message: onError.toString(),
          status: LogEvent.failed,
        );

        // ignore: invalid_return_type_for_catch_error
        _view!.onUpdateReAnswersFail(
            "invalid_return_type_for_catch_error: Has an error when submit this test!");
      });
    } on TimeoutException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "TimeoutException: Has an error when submit this test!",
        status: LogEvent.failed,
      );

      _view!.onUpdateReAnswersFail(
          "TimeoutException: Has an error when submit this test!");
    } on SocketException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "SocketException: Has an error when submit this test!",
        status: LogEvent.failed,
      );

      _view!.onUpdateReAnswersFail(
          "SocketException: Has an error when submit this test!");
    } on http.ClientException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "ClientException: Has an error when submit this test!",
        status: LogEvent.failed,
      );
      _view!.onUpdateReAnswersFail(
          "ClientException: Has an error when submit this test!");
    }
  }
}
