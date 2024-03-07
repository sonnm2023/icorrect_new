import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/doing_test_service.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/simulator_test_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/auth_models/video_record_exam_info.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';

abstract class TestRoomViewContract {
  void onCountDown(
      String countDownString, bool isLessThan2Seconds, int timeCounting);
  void onUpdateDuration(int duration);
  void onCountDownForCueCard(String countDownString);
  void onFinishAnswer(bool isPart2);
  void onFinishForReAnswer();
  void onCountRecordingVideo(int currentCount);
  void onSubmitTestSuccess(String msg);
  void onSubmitTestError(String msg);
  void onUpdateReAnswersSuccess(String msg);
  void onUpdateReAnswersError(String msg);
  void onClickSaveTheTest();
  void onFinishTheTest();
  void onReDownload();
  void onUpdateHasOrderStatus(bool hasOrder);
}

class TestRoomPresenter {
  final TestRoomViewContract? _view;
  SimulatorTestRepository? _testRepository;

  TestRoomPresenter(this._view) {
    _testRepository = Injector().getTestRepository();
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
    int duration = 0;

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

      _view!.onUpdateDuration(1);
      _view!.onCountDown("$minuteStr:$secondStr", isLessThan2Seconds, count);

      if (count == 0 && !finishCountDown) {
        finishCountDown = true;
        duration = temp - count;
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
    dynamic minutes = count ~/ 60;
    dynamic seconds = count % 60;

    dynamic minuteStr = minutes.toString().padLeft(2, '0');
    dynamic secondStr = seconds.toString().padLeft(2, '0');
    _view!.onCountDownForCueCard("$minuteStr:$secondStr");

    bool finishCountDown = false;
    const oneSec = Duration(seconds: 1);

    return Timer.periodic(oneSec, (Timer timer) {
      if (count < 1) {
        timer.cancel();
      } else {
        count = count - 1;
      }

      dynamic m = count ~/ 60;
      dynamic s = count % 60;

      dynamic mStr = m.toString().padLeft(2, '0');
      dynamic sStr = s.toString().padLeft(2, '0');
      _view!.onCountDownForCueCard("$mStr:$sStr");

      if (count == 0 && !finishCountDown) {
        finishCountDown = true;
        _view!.onFinishAnswer(isPart2);
      }
    });
  }

  void clickSaveTheTest() {
    _view!.onClickSaveTheTest();
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
    required int duration,
  }) async {
    assert(_view != null && _testRepository != null);

    // Add log
    LogModel? log;
    Map<String, dynamic> dataLog = {};

    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiSubmitTest);
    }

    http.MultipartRequest multiRequest = await DoingTestService.formDataRequest(
      testId: testId,
      activityId: activityId,
      questions: questions,
      isUpdate: false,
      dataLog: dataLog,
      isExam: isExam,
      videoConfirmFile: videoConfirmFile,
      logAction: logAction,
      duration: duration,
    );

    if (kDebugMode) {
      print("DEBUG: submitTest");
      print("DEBUG: testId = $testId");
      print("DEBUG: activityId = $activityId");
    }

    try {
      final String value = await _testRepository!.submitTest(multiRequest);
      dataLog[StringConstants.k_response] = value;

      if (kDebugMode) {
        print("DEBUG: submit response: $value");
      }
      try {
        Map<String, dynamic> json = jsonDecode(value) ?? {};
        if (json[StringConstants.k_error_code] == 200 ||
            json[StringConstants.k_error_code] == 5013) {
          // Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: null,
            status: LogEvent.success,
          );

          bool hasOrder = false;
          if (null != json[StringConstants.k_has_order]) {
            hasOrder = json[StringConstants.k_has_order];
          }

          _view!.onUpdateHasOrderStatus(hasOrder);

          String message =
              Utils.multiLanguage(StringConstants.submit_test_success_message)!;
          if (json[StringConstants.k_error_code] == 5013) {
            if (!isExam) {
              message = Utils.multiLanguage(
                  StringConstants.submit_test_success_message_with_code_5013)!;
            }
          }

          _view!.onSubmitTestSuccess(message);
        } else {
          // Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: StringConstants.submit_test_error_message,
            status: LogEvent.failed,
          );

          String errorCode = "";
          if (json[StringConstants.k_error_code] != null) {
            errorCode = " [Error Code: ${json[StringConstants.k_error_code]}]";
          }

          _view!.onSubmitTestError(
              "${Utils.multiLanguage(StringConstants.submit_test_error_message)}\n$errorCode");
        }
      } catch (e) {
        // Add log
        Utils.prepareLogData(
          log: log,
          data: dataLog,
          message: "${StringConstants.submit_test_error_parse_json}: $e",
          status: LogEvent.failed,
        );

        _view!.onSubmitTestError(
            Utils.multiLanguage(StringConstants.submit_test_error_parse_json)!);
      }
    } on TimeoutException catch (e) {
      // Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "${StringConstants.submit_test_error_timeout}: $e",
        status: LogEvent.failed,
      );

      _view!.onSubmitTestError(
          Utils.multiLanguage(StringConstants.submit_test_error_timeout)!);
    } on SocketException catch (e) {
      // Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "${StringConstants.submit_test_error_socket}: $e",
        status: LogEvent.failed,
      );

      _view!.onSubmitTestError(
          Utils.multiLanguage(StringConstants.submit_test_error_socket)!);
    } on http.ClientException catch (e) {
      // Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "${StringConstants.submit_test_error_client}: $e",
        status: LogEvent.failed,
      );

      _view!.onSubmitTestError(
          Utils.multiLanguage(StringConstants.submit_test_error_client)!);
    } catch (e) {
      // Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: e.toString(),
        status: LogEvent.failed,
      );

      _view!.onSubmitTestError(
          Utils.multiLanguage(StringConstants.submit_test_error_other)!);
    }
  }

  Future updateMyAnswer({
    required BuildContext context,
    required String testId,
    required String activityId,
    required List<QuestionTopicModel> reQuestions,
    required bool isExam,
    required int duration,
  }) async {
    //Add log
    LogModel? log;
    Map<String, dynamic>? dataLog = {};

    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiUpdateAnswer);
    }

    http.MultipartRequest multiRequest = await DoingTestService.formDataRequest(
      testId: testId,
      activityId: activityId,
      questions: reQuestions,
      isUpdate: true,
      dataLog: dataLog,
      isExam: isExam,
      videoConfirmFile: null,
      logAction: null,
      duration: duration,
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

          _view!.onUpdateReAnswersSuccess(Utils.multiLanguage(
              StringConstants.save_answer_success_message)!);
        } else {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: StringConstants.submit_test_error_message,
            status: LogEvent.failed,
          );

          String errorCode = "";
          if (json[StringConstants.k_error_code] != null) {
            errorCode = " [Error Code: ${json[StringConstants.k_error_code]}]";
          }

          _view!.onUpdateReAnswersError(
              "${Utils.multiLanguage(StringConstants.submit_test_error_message)}\n$errorCode");
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
        _view!.onUpdateReAnswersError(Utils.multiLanguage(
            StringConstants.submit_test_error_invalid_return_type_message)!);
      });
    } on TimeoutException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_timeout,
        status: LogEvent.failed,
      );

      _view!.onUpdateReAnswersError(
          Utils.multiLanguage(StringConstants.submit_test_error_timeout)!);
    } on SocketException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_socket,
        status: LogEvent.failed,
      );

      _view!.onUpdateReAnswersError(
          Utils.multiLanguage(StringConstants.submit_test_error_socket)!);
    } on http.ClientException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_client,
        status: LogEvent.failed,
      );
      _view!.onUpdateReAnswersError(
          Utils.multiLanguage(StringConstants.submit_test_error_client)!);
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
      log.addData(key: StringConstants.k_activity_id, value: activityId);
      log.addData(key: "question_index", value: questionIndex);

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
