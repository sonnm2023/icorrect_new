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
import 'package:icorrect/src/models/auth_models/video_record_exam_info.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';

abstract class TestRoomViewContract {
  void onPlayIntroduce();
  void onPlayEndOfTakeNote(String fileName);
  void onPlayEndOfTest(String fileName);
  void onCountDown(
      String countDownString, bool isLessThan2Seconds, int timeCounting);
  void onCountDownForCueCard(String countDownString);
  void onFinishAnswer(bool isPart2);
  void onFinishForReAnswer();
  void onCountRecordingVideo(int currentCount);
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

      _view!.onCountDown("$minuteStr:$secondStr", isLessThan2Seconds, count);

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

  String getVideoLongestDuration(List<VideoExamRecordInfo> videosSaved) {
    List<VideoExamRecordInfo> videosMore7s = [];
    for (int i = 0; i < videosSaved.length; i++) {
      File videoFile = File(videosSaved.elementAt(i).filePath!);
      if (videoFile.existsSync() &&
          (videoFile.lengthSync() / (1024 * 1024)) >= 40) {
        videosMore7s.add(videosSaved.elementAt(i));
      }
    }
    if (videosMore7s.isNotEmpty) {
      Random random = Random();
      int positionRandom = random.nextInt(videosMore7s.length);
      VideoExamRecordInfo randomVideo = videosMore7s.elementAt(positionRandom);
      return randomVideo.filePath ?? '';
    }

    videosSaved.sort(((a, b) => a.duration!.compareTo(b.duration!)));
    VideoExamRecordInfo maxValue = videosSaved.last;
    return maxValue.filePath ?? '';
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

  Timer startCountRecording({int? countFrom}) {
    const oneSec = Duration(seconds: 1);
    int count = countFrom ?? 0;
    return Timer.periodic(oneSec, (Timer timer) {
      count = count + 1;
      _view!.onCountRecordingVideo(count);
    });
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
        dataLog[StringConstants.k_response] = json;

        if (json[StringConstants.k_error_code] == 200) {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: null,
            status: LogEvent.success,
          );

          _view!
              .onSubmitTestSuccess(StringConstants.save_answer_success_message);
        } else {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: StringConstants.submit_test_error_message,
            status: LogEvent.failed,
          );

          _view!.onSubmitTestFail(StringConstants.submit_test_error_message);
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
            StringConstants.submit_test_error_invalid_return_type_message);
      });
    } on TimeoutException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_timeout,
        status: LogEvent.failed,
      );

      _view!.onSubmitTestFail(StringConstants.submit_test_error_timeout);
    } on SocketException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_socket,
        status: LogEvent.failed,
      );

      _view!.onSubmitTestFail(StringConstants.submit_test_error_socket);
    } on http.ClientException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_client,
        status: LogEvent.failed,
      );

      _view!.onSubmitTestFail(StringConstants.submit_test_error_client);
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
      StringConstants.k_content_type: 'multipart/form-data',
      StringConstants.k_authorization: 'Bearer ${await Utils.getAccessToken()}'
    });

    Map<String, String> formData = {};

    formData.addEntries([MapEntry(StringConstants.k_test_id, testId)]);
    formData.addEntries([MapEntry(StringConstants.k_activity_id, activityId)]);
    formData.addEntries(
        [MapEntry(StringConstants.k_is_update, isUpdate ? '1' : '0')]);

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

      //For test: don't send answers
      for (int i = 0; i < q.answers.length; i++) {
        String path = await FileStorageHelper.getFilePath(
            q.answers.elementAt(i).url.toString(), MediaType.audio, testId);
        File audioFile = File(path);

        if (await audioFile.exists()) {
          String audioSize = "${audioFile.lengthSync() / (1024 * 1024)} Mb";
          dataLog!.addEntries([MapEntry(q.answers[i].url, audioSize)]);

          request.files.add(
              await http.MultipartFile.fromPath("$prefix[$i]", audioFile.path));
        }
      }
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
      print("DEBUG: update reanswer");
      print("DEBUG: testId = $testId");
      print("DEBUG: activityId = $activityId");
    }

    try {
      _testRepository!.submitTest(multiRequest).then((value) {
        if (kDebugMode) {
          print("DEBUG: submit response: $value");
        }

        Map<String, dynamic> json = jsonDecode(value) ?? {};
        dataLog[StringConstants.k_response] = json;

        if (json[StringConstants.k_error_code] == 200) {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: null,
            status: LogEvent.success,
          );

          _view!.onUpdateReAnswersSuccess(
              StringConstants.save_answer_success_message);
        } else {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: StringConstants.submit_test_error_message,
            status: LogEvent.failed,
          );

          _view!
              .onUpdateReAnswersFail(StringConstants.submit_test_error_message);
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
            StringConstants.submit_test_error_invalid_return_type_message);
      });
    } on TimeoutException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_timeout,
        status: LogEvent.failed,
      );

      _view!.onUpdateReAnswersFail(StringConstants.submit_test_error_timeout);
    } on SocketException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_socket,
        status: LogEvent.failed,
      );

      _view!.onUpdateReAnswersFail(StringConstants.submit_test_error_socket);
    } on http.ClientException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_client,
        status: LogEvent.failed,
      );
      _view!.onUpdateReAnswersFail(StringConstants.submit_test_error_client);
    }
  }

  void callTestPositionApi(
    BuildContext context, {
    required String activityId,
    required int questionIndex,
  }) async {
    UserDataModel? currentUser = await Utils.getCurrentUser();
    if (null == currentUser) return;

    if (kDebugMode) {
      print(
          "DEBUG: callTestPositionApi: activityId $activityId - questionIndex $questionIndex");
    }

    assert(_view != null && _testRepository != null);

    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiTestPosition);
    }

    String email = currentUser.userInfoModel.email;

    _testRepository!
        .callTestPosition(
            email: email,
            activityId: activityId,
            questionIndex: questionIndex,
            user: testPositionUser,
            pass: testPositionPass)
        .then((value) async {
      if (kDebugMode) {
        print("DEBUG: callTestPosition $value");
      }

      //Add information into log
      log!.addData(key: StringConstants.k_email, value: email);
      log!.addData(key: StringConstants.k_activity_id, value: activityId);
      log!.addData(key: "question_index", value: questionIndex);

      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap[StringConstants.k_error_code] == 200) {
        if (kDebugMode) {
          print("DEBUG: callTestPosition SUCCESS");
        }
        //Add log
        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: dataMap[StringConstants.k_message],
          status: LogEvent.success,
        );
      } else {
        if (kDebugMode) {
          print("DEBUG: callTestPosition FAIL");
        }
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message:
              "CallTestPositionApi error: ${dataMap[StringConstants.k_error_code]}${dataMap[StringConstants.k_status]}",
          status: LogEvent.failed,
        );
      }
    }).catchError((onError) {
      String message = '';
      if (onError is http.ClientException || onError is SocketException) {
        message = StringConstants.network_error_message;
      } else {
        message = StringConstants.common_error_message;
      }
      //Add log
      Utils.prepareLogData(
        log: log,
        data: null,
        message: message,
        status: LogEvent.failed,
      );
    });
  }
}
