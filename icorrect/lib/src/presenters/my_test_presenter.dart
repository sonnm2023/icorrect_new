// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/my_test_repository.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';

import '../data_sources/api_urls.dart';
import '../data_sources/constants.dart';
import '../data_sources/local/file_storage_helper.dart';
import '../data_sources/utils.dart';
import '../models/simulator_test_models/topic_model.dart';
import '../models/ui_models/alert_info.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

abstract class MyTestContract {
  void getMyTestSuccess(List<QuestionTopicModel> questions);
  void onDownloadSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total);
  void downloadFilesFail(AlertInfo alertInfo);
  void getMyTestFail(AlertInfo alertInfo);
  void onCountDown(String time);
  void finishCountDown();
  void updateAnswersSuccess(String message);
  void updateAnswerFail(AlertInfo info);
  void onReDownload();
  void onTryAgainToDownload();
}

class MyTestPresenter {
  final MyTestContract? _view;
  MyTestRepository? _repository;

  MyTestPresenter(this._view) {
    _repository = Injector().getMyTestRepository();
  }

  Dio? dio;
  final Map<String, String> headers = {
    'Accept': 'application/json',
  };

  int _autoRequestDownloadTimes = 0;
  int get autoRequestDownloadTimes => _autoRequestDownloadTimes;
  void increaseAutoRequestDownloadTimes() {
    _autoRequestDownloadTimes += 1;
  }

  TestDetailModel? testDetail;
  List<FileTopicModel>? filesTopic;

  Future<void> initializeData() async {
    dio ??= Dio();
    resetAutoRequestDownloadTimes();
  }

  void resetAutoRequestDownloadTimes() {
    _autoRequestDownloadTimes = 0;
  }

  void closeClientRequest() {
    if (null != dio) {
      dio!.close();
      dio = null;
    }
  }

  void getMyTest({
    required BuildContext context,
    required String activityId,
    required String testId,
  }) async {
    assert(_view != null && _repository != null);

    if (kDebugMode) {
      print('DEBUG: testId: ${testId.toString()}');
    }

    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiGetMyTestDetail);
    }

    _repository!.getMyTestDetail(testId).then((value) {
      Map<String, dynamic> json = jsonDecode(value) ?? {};
      if (json.isNotEmpty) {
        if (json['error_code'] == 200) {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: null,
            status: LogEvent.success,
          );

          Map<String, dynamic> dataMap = json['data'];
          TestDetailModel testDetailModel =
              TestDetailModel.fromMyTestJson(dataMap);
          testDetail = TestDetailModel.fromMyTestJson(dataMap);

          List<FileTopicModel> tempFilesTopic =
              _prepareFileTopicListForDownload(testDetailModel);

          filesTopic = _prepareFileTopicListForDownload(testDetailModel);

          downloadFiles(
            context: context,
            activityId: activityId,
            testDetail: testDetailModel,
            filesTopic: tempFilesTopic,
          );

          _view!.getMyTestSuccess(_getQuestionsAnswer(testDetailModel));
        } else {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: null,
            message:
                "Loading my test detail error: ${json['error_code']}${json['status']}",
            status: LogEvent.failed,
          );

          _view!.getMyTestFail(AlertClass.notResponseLoadTestAlert);
        }
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message: "Loading my test detail error",
          status: LogEvent.failed,
        );

        _view!.getMyTestFail(AlertClass.getTestDetailAlert);
      }
    }).catchError(
        // ignore: invalid_return_type_for_catch_error
        (onError) {
      if (kDebugMode) {
        print("DEBUG: fail meomoe");
      }
      //Add log
      Utils.prepareLogData(
        log: log,
        data: null,
        message: onError.toString(),
        status: LogEvent.failed,
      );

      _view!.getMyTestFail(AlertClass.getTestDetailAlert);
    });
  }

  List<QuestionTopicModel> _getQuestionsAnswer(
      TestDetailModel testDetailModel) {
    List<QuestionTopicModel> questions = [];
    List<QuestionTopicModel> questionsAllAnswers = [];
    questions.addAll(testDetailModel.introduce.questionList);
    for (var q in testDetailModel.part1) {
      questions.addAll(q.questionList);
    }

    questions.addAll(testDetailModel.part2.questionList);
    questions.addAll(testDetailModel.part3.questionList);

    for (var question in questions) {
      questionsAllAnswers.addAll(_questionsWithRepeat(question));
    }
    return questionsAllAnswers;
  }

  List<QuestionTopicModel> _questionsWithRepeat(QuestionTopicModel question) {
    List<QuestionTopicModel> repeatQuestions = [];
    List<FileTopicModel> filesAnswers = question.answers;
    for (int i = 0; i < filesAnswers.length - 1; i++) {
      QuestionTopicModel q = _genQuestionRepeat(question, i);
      repeatQuestions.add(q);
    }
    question.repeatIndex = filesAnswers.length - 1;
    repeatQuestions.add(question);
    return repeatQuestions;
  }

  QuestionTopicModel _genQuestionRepeat(
      QuestionTopicModel question, int index) {
    return question.copyWith(
        id: question.id,
        content: "Ask for repeat question",
        type: question.type,
        topicId: question.topicId,
        tips: question.tips,
        tipType: question.tipType,
        isFollowUp: question.isFollowUp,
        cueCard: question.cueCard,
        reAnswerCount: question.reAnswerCount,
        answers: question.answers,
        numPart: question.numPart,
        repeatIndex: index,
        files: question.files);
  }

  List<FileTopicModel> _prepareFileTopicListForDownload(
      TestDetailModel testDetail) {
    List<FileTopicModel> filesTopic = [];
    filesTopic.addAll(getAllFilesOfTopic(testDetail.introduce));

    for (int i = 0; i < testDetail.part1.length; i++) {
      TopicModel temp = testDetail.part1[i];
      filesTopic.addAll(getAllFilesOfTopic(temp));
    }

    filesTopic.addAll(getAllFilesOfTopic(testDetail.part2));

    filesTopic.addAll(getAllFilesOfTopic(testDetail.part3));
    return filesTopic;
  }

  MediaType _mediaType(String type) {
    return (type == StringClass.audio) ? MediaType.audio : MediaType.video;
  }

  double _getPercent(int downloaded, int total) {
    return (downloaded / total);
  }

  List<FileTopicModel> getAllFilesOfTopic(TopicModel topic) {
    List<FileTopicModel> allFiles = [];
    //Add introduce file
    allFiles.addAll(topic.files);

    //Add question files
    for (QuestionTopicModel q in topic.questionList) {
      allFiles.add(q.files.first);
      allFiles.addAll(q.answers);
    }

    for (QuestionTopicModel q in topic.followUp) {
      allFiles.add(q.files.first);
      allFiles.addAll(q.answers);
    }

    if (topic.endOfTakeNote.url.isNotEmpty) {
      allFiles.add(topic.endOfTakeNote);
    }

    if (topic.fileEndOfTest.url.isNotEmpty) {
      allFiles.add(topic.fileEndOfTest);
    }

    return allFiles;
  }

  void downloadFailure(AlertInfo alertInfo) {
    _view!.downloadFilesFail(alertInfo);
  }

  Future downloadFiles({
    required BuildContext context,
    required String activityId,
    required TestDetailModel testDetail,
    required List<FileTopicModel> filesTopic,
  }) async {
    if (null != dio) {
      loop:
      for (int index = 0; index < filesTopic.length; index++) {
        FileTopicModel temp = filesTopic[index];
        String fileTopic = temp.url;
        String fileNameForDownload = Utils.reConvertFileName(fileTopic);

        if (filesTopic.isNotEmpty) {
          LogModel? log;
          if (context.mounted) {
            log = await Utils.prepareToCreateLog(context,
                action: LogEvent.callApiDownloadFile);
            Map<String, dynamic> fileDownloadInfo = {
              "activity_id": activityId,
              "test_id": testDetail.testId.toString(),
              "file_name": fileTopic,
              "file_path": downloadFileEP(fileNameForDownload),
            };
            log.addData(
                key: "file_download_info",
                value: json.encode(fileDownloadInfo));
          }

          String fileType = Utils.fileType(fileTopic);

          if (_mediaType(fileType) == MediaType.audio) {
            fileNameForDownload = fileTopic;
            fileTopic = Utils.convertFileName(fileTopic);
          }

          if (fileType.isNotEmpty &&
              !await Utils.isExist(fileTopic, _mediaType(fileType))) {
            try {
              String url = downloadFileEP(fileNameForDownload);

              if (null == dio) {
                return;
              }

              dio!.head(url).timeout(const Duration(seconds: 10));

              String savePath =
                  '${await FileStorageHelper.getFolderPath(_mediaType(fileType), null)}\\$fileTopic';

              if (kDebugMode) {
                print("Debug : url: $url , fileTopic : $fileTopic");
                print("Save Path: $savePath");
              }

              Response response = await dio!.download(url, savePath);
              if (response.statusCode == 200) {
                double percent = _getPercent(index + 1, filesTopic.length);

                //Add log
                Utils.prepareLogData(
                  log: log,
                  data: null,
                  message: response.statusMessage,
                  status: LogEvent.success,
                );

                _view!.onDownloadSuccess(testDetail, fileTopic, percent,
                    index + 1, filesTopic.length);
              } else {
                //Add log
                Utils.prepareLogData(
                  log: log,
                  data: null,
                  message: "Download failed!",
                  status: LogEvent.failed,
                );

                _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
                reDownloadAutomatic(
                  context: context,
                  activityId: activityId,
                  testDetail: testDetail,
                  filesTopic: filesTopic,
                );
                break loop;
              }
            } on DioException catch (e) {
              if (kDebugMode) {
                print(
                    "DEBUG: Download error: ${e.type} - message: ${e.message}");
              }

              //Add log
              Utils.prepareLogData(
                log: log,
                data: null,
                message: "Error type: ${e.type} - message: ${e.message}",
                status: LogEvent.failed,
              );

              _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
              reDownloadAutomatic(
                context: context,
                activityId: activityId,
                testDetail: testDetail,
                filesTopic: filesTopic,
              );
              break loop;
            } on TimeoutException {
              //Add log
              Utils.prepareLogData(
                log: log,
                data: null,
                message: "Download File TimeoutException",
                status: LogEvent.failed,
              );

              _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
              reDownloadAutomatic(
                context: context,
                activityId: activityId,
                testDetail: testDetail,
                filesTopic: filesTopic,
              );
              break loop;
            } on SocketException {
              //Add log
              Utils.prepareLogData(
                log: log,
                data: null,
                message: "Download File SocketException",
                status: LogEvent.failed,
              );

              _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
              reDownloadAutomatic(
                context: context,
                activityId: activityId,
                testDetail: testDetail,
                filesTopic: filesTopic,
              );
              break loop;
            } on http.ClientException {
              //Add log
              Utils.prepareLogData(
                log: log,
                data: null,
                message: "Download File ClientException",
                status: LogEvent.failed,
              );

              _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
              reDownloadAutomatic(
                context: context,
                activityId: activityId,
                testDetail: testDetail,
                filesTopic: filesTopic,
              );
              break loop;
            }
          } else {
            double percent = _getPercent(index + 1, filesTopic.length);
            _view!.onDownloadSuccess(
                testDetail, fileTopic, percent, index + 1, filesTopic.length);
          }
        }
      }
    } else {
      if (kDebugMode) {
        print("DEBUG: client is closed!");
      }
    }
  }

  void reDownloadAutomatic({
    required BuildContext context,
    required String activityId,
    required TestDetailModel testDetail,
    required List<FileTopicModel> filesTopic,
  }) {
    //Download again
    if (autoRequestDownloadTimes <= 3) {
      if (kDebugMode) {
        print("DEBUG: request to download in times: $autoRequestDownloadTimes");
      }
      downloadFiles(
        context: context,
        activityId: activityId,
        testDetail: testDetail,
        filesTopic: filesTopic,
      );
      increaseAutoRequestDownloadTimes();
    } else {
      //Close old download request
      closeClientRequest();
      _view!.onReDownload();
    }
  }

  Timer startCountDown(BuildContext context, int count) {
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
        _view!.finishCountDown();
      }
    });
  }

  Future updateMyAnswer({
    required BuildContext context,
    required String testId,
    required String activityId,
    required List<QuestionTopicModel> reQuestions,
  }) async {
    assert(_view != null && _repository != null);

    //Add log
    LogModel? log;
    Map<String, dynamic> dataLog = {};

    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiUpdateMyAnswer);
    }

    http.MultipartRequest multiRequest = await _formDataRequest(
      testId: testId,
      activityId: activityId,
      questions: reQuestions,
      dataLog: dataLog,
    );

    try {
      _repository!.updateAnswers(multiRequest).then((value) {
        Map<String, dynamic> json = jsonDecode(value) ?? {};
        dataLog['response'] = json;

        if (kDebugMode) {
          print("DEBUG: error form: ${json.toString()}");
        }
        if (json['error_code'] == 200 && json['status'] == 'success') {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: null,
            status: LogEvent.success,
          );

          _view!.updateAnswersSuccess('Save your answers successfully!');
        } else {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: "Has an error when update my answer!",
            status: LogEvent.failed,
          );

          _view!.updateAnswerFail(AlertClass.errorWhenUpdateAnswer);
        }
      }).catchError((onError) {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: dataLog,
          message: onError.toString(),
          status: LogEvent.failed,
        );

        _view!.updateAnswerFail(AlertClass.errorWhenUpdateAnswer);
      });
    } on TimeoutException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "TimeoutException: Has an error when update my answer!",
        status: LogEvent.failed,
      );

      _view!.updateAnswerFail(AlertClass.timeOutUpdateAnswer);
    } on SocketException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "SocketException: Has an error when update my answer!",
        status: LogEvent.failed,
      );

      _view!.updateAnswerFail(AlertClass.errorWhenUpdateAnswer);
    } on http.ClientException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "ClientException: Has an error when update my answer!",
        status: LogEvent.failed,
      );

      _view!.updateAnswerFail(AlertClass.errorWhenUpdateAnswer);
    }
  }

  Future<http.MultipartRequest> _formDataRequest({
    required String testId,
    required String activityId,
    required List<QuestionTopicModel> questions,
    required Map<String, dynamic>? dataLog,
  }) async {
    String url = submitHomeWorkV2EP();
    http.MultipartRequest request =
        http.MultipartRequest(RequestMethod.post, Uri.parse(url));
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${await Utils.getAccessToken()}'
    });

    Map<String, String> formData = {};

    formData.addEntries([MapEntry('test_id', testId)]);
    formData.addEntries(const [MapEntry('is_update', '1')]);
    formData.addEntries([MapEntry('activity_id', activityId)]);

    if (Platform.isAndroid) {
      formData.addEntries([const MapEntry('os', "android")]);
    } else {
      formData.addEntries([const MapEntry('os', "ios")]);
    }
    formData.addEntries([const MapEntry('app_version', '2.0.2')]);
    String format = '';
    String reanswerFormat = '';
    String endFormat = '';
    for (QuestionTopicModel q in questions) {
      String questionId = q.id.toString();
      if (kDebugMode) {
        print("DEBUG: num part : ${q.numPart.toString()}");
      }
      if (q.numPart == PartOfTest.introduce.get) {
        format = 'introduce[$questionId]';
        reanswerFormat = 'reanswer_introduce[$questionId]';
      }

      if (q.type == PartOfTest.part1.get) {
        format = 'part1[$questionId]';
        reanswerFormat = 'reanswer_part1[$questionId]';
      }

      if (q.type == PartOfTest.part2.get) {
        format = 'part2[$questionId]';
        reanswerFormat = 'reanswer_part2[$questionId]';
      }

      if (q.type == PartOfTest.part3.get && !q.isFollowUpQuestion()) {
        format = 'part3[$questionId]';
        reanswerFormat = 'reanswer_part3[$questionId]';
      }
      if (q.type == PartOfTest.part3.get && q.isFollowUpQuestion()) {
        format = 'followup[$questionId]';
        reanswerFormat = 'reanswer_followup[$questionId]';
      }

      formData
          .addEntries([MapEntry(reanswerFormat, q.reAnswerCount.toString())]);

      for (int i = 0; i < q.answers.length; i++) {
        endFormat = '$format[$i]';
        String fileName =
            Utils.convertFileName(q.answers.elementAt(i).url.toString());
        File audioFile = File(await FileStorageHelper.getFilePath(
            fileName, MediaType.audio, null));

        if (await audioFile.exists()) {
          request.files.add(
              await http.MultipartFile.fromPath(endFormat, audioFile.path));
          //  formData.addEntries([MapEntry(endFormat, audioFile.path)]);
        }
      }
    }

    if (kDebugMode) {
      print("DEBUG : form Data update submit : ${formData.toString()}");
    }

    request.fields.addAll(formData);

    if (null != dataLog) {
      dataLog['request_data'] = formData.toString();
    }

    return request;
  }

  void tryAgainToDownload() async {
    if (kDebugMode) {
      print("DEBUG: MyTestPresenter tryAgainToDownload");
    }

    _view!.onTryAgainToDownload();
  }

  void reDownloadFiles(BuildContext context, String activityId) {
    downloadFiles(
      context: context,
      activityId: activityId,
      testDetail: testDetail!,
      filesTopic: filesTopic!,
    );
  }
}
