// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/repositories/simulator_test_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activity_answer_model.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

abstract class SimulatorTestViewContract {
  void onGetTestDetailComplete(TestDetailModel testDetailModel, int total);
  void onGetTestDetailError(String message);
  void onDownloadSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total);
  void onDownloadFailure(AlertInfo info);
  void onSaveTopicListIntoProvider(List<TopicModel> list);
  void onSubmitTestSuccess(String msg, ActivityAnswer activityAnswer);
  void onSubmitTestFail(String msg);
  void onReDownload();
  void onTryAgainToDownload();
  void onHandleBackButtonSystemTapped();
  void onHandleEventBackButtonSystem({required bool isQuitTheTest});
  void onPrepareListVideoSource(List<FileTopicModel> filesTopic);
}

class SimulatorTestPresenter {
  final SimulatorTestViewContract? _view;
  SimulatorTestRepository? _testRepository;

  SimulatorTestPresenter(this._view) {
    _testRepository = Injector().getTestRepository();
  }

  int _autoRequestDownloadTimes = 0;
  int get autoRequestDownloadTimes => _autoRequestDownloadTimes;
  void increaseAutoRequestDownloadTimes() {
    _autoRequestDownloadTimes += 1;
  }

  // http.Client? client;
  Dio? dio;
  final Map<String, String> headers = {
    'Accept': 'application/json',
  };

  Future<void> initializeData() async {
    dio ??= Dio();
    resetAutoRequestDownloadTimes();
  }

  void closeClientRequest() {
    if (null != dio) {
      dio!.close();
      dio = null;
    }
  }

  void resetAutoRequestDownloadTimes() {
    _autoRequestDownloadTimes = 0;
  }

  TestDetailModel? testDetail;
  List<FileTopicModel>? filesTopic;

  void getTestDetail({
    required BuildContext context,
    required String homeworkId,
  }) async {
    UserDataModel? currentUser = await Utils.getCurrentUser();
    if (currentUser == null) {
      _view!.onGetTestDetailError("Loading homework detail error!");
      return;
    }

    String distributeCode = currentUser.userInfoModel.distributorCode;

    LogModel log = await Utils.prepareToCreateLog(context,
        action: LogEvent.callApiGetTestDetail);

    _testRepository!
        .getTestDetail(homeworkId, distributeCode)
        .then((value) async {
      Map<String, dynamic> map = jsonDecode(value);
      if (map['error_code'] == 200) {
        Map<String, dynamic> dataMap = map['data'];
        TestDetailModel tempTestDetailModel = TestDetailModel(testId: 0);
        tempTestDetailModel = TestDetailModel.fromJson(dataMap);
        testDetail = TestDetailModel.fromJson(dataMap);

        _prepareTopicList(tempTestDetailModel);

        //Add log
        log.addData(key: "response", value: value);
        Utils.addLog(log, LogEvent.success);

        //Save file info for re download
        filesTopic = _prepareFileTopicListForDownload(tempTestDetailModel);

        _view!.onPrepareListVideoSource(filesTopic!);

        List<FileTopicModel> tempFilesTopic =
            _prepareFileTopicListForDownload(tempTestDetailModel);

        downloadFiles(
            context: context,
            testDetail: tempTestDetailModel,
            filesTopic: tempFilesTopic);

        _view!.onGetTestDetailComplete(
            tempTestDetailModel, tempFilesTopic.length);
      } else {
        //Add log
        log.message =
            "Loading homework detail error: ${map['error_code']}${map['status']}";
        Utils.addLog(log, LogEvent.failed);

        _view!.onGetTestDetailError(
            "Loading homework detail error: ${map['error_code']}${map['status']}");
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) {
        //Add log
        log.message = onError.toString();
        Utils.addLog(log, LogEvent.failed);

        _view!.onGetTestDetailError(onError.toString());
      },
    );
  }

  //Prepare list of topic for save into provider
  void _prepareTopicList(TestDetailModel testDetail) {
    List<TopicModel> topicsList = [];
    //Introduce
    if (0 != testDetail.introduce.id && testDetail.introduce.title.isNotEmpty) {
      testDetail.introduce.numPart = PartOfTest.introduce.get;
      topicsList.add(testDetail.introduce);
    }

    //Part 1
    if (testDetail.part1.isNotEmpty) {
      for (int i = 0; i < testDetail.part1.length; i++) {
        testDetail.part1[i].numPart = PartOfTest.part1.get;
      }
      topicsList.addAll(testDetail.part1);
    }

    //Part 2
    if (0 != testDetail.part2.id && testDetail.part2.title.isNotEmpty) {
      testDetail.part2.numPart = PartOfTest.part2.get;
      topicsList.add(testDetail.part2);
    }

    //Part 3
    if (0 != testDetail.part3.id && testDetail.part3.title.isNotEmpty) {
      if (testDetail.part3.questionList.isNotEmpty ||
          testDetail.part3.fileEndOfTest.url.isNotEmpty) {
        testDetail.part3.numPart = PartOfTest.part3.get;
        topicsList.add(testDetail.part3);
      }
    }

    _view!.onSaveTopicListIntoProvider(topicsList);
  }

  List<FileTopicModel> _prepareFileTopicListForDownload(
      TestDetailModel testDetail) {
    List<FileTopicModel> filesTopic = [];
    //Introduce
    filesTopic.addAll(getAllFilesOfTopic(testDetail.introduce));

    //Part 1
    for (int i = 0; i < testDetail.part1.length; i++) {
      TopicModel temp = testDetail.part1[i];
      filesTopic.addAll(getAllFilesOfTopic(temp));
    }

    //Part 2
    filesTopic.addAll(getAllFilesOfTopic(testDetail.part2));

    //Part 3
    filesTopic.addAll(getAllFilesOfTopic(testDetail.part3));
    return filesTopic;
  }

  double _getPercent(int downloaded, int total) {
    return (downloaded / total);
  }

  List<FileTopicModel> getAllFilesOfTopic(TopicModel topic) {
    List<FileTopicModel> allFiles = [];
    //Add introduce file
    for (FileTopicModel file in topic.files) {
      file.numPart = topic.numPart;
      file.fileTopicType = FileTopicType.introduce;
      allFiles.add(file);
    }

    for (QuestionTopicModel q in topic.followUp) {
      q.files.first.fileTopicType = FileTopicType.followup;
      q.files.first.numPart = topic.numPart;
      allFiles.add(q.files.first);

      for (FileTopicModel a in q.answers) {
        a.numPart = topic.numPart;
        a.fileTopicType = FileTopicType.answer;
        allFiles.add(a);
      }
    }

    //Add question files
    for (QuestionTopicModel q in topic.questionList) {
      q.files.first.fileTopicType = FileTopicType.question;
      q.files.first.numPart = topic.numPart;
      allFiles.add(q.files.first);

      for (FileTopicModel a in q.answers) {
        a.numPart = topic.numPart;
        a.fileTopicType = FileTopicType.answer;
        allFiles.add(a);
      }
    }

    if (topic.endOfTakeNote.url.isNotEmpty) {
      topic.endOfTakeNote.fileTopicType = FileTopicType.end_of_take_note;
      topic.endOfTakeNote.numPart = topic.numPart;
      allFiles.add(topic.endOfTakeNote);
    }

    if (topic.fileEndOfTest.url.isNotEmpty) {
      topic.fileEndOfTest.fileTopicType = FileTopicType.end_of_test;
      topic.fileEndOfTest.numPart = topic.numPart;
      allFiles.add(topic.fileEndOfTest);
    }

    return allFiles;
  }

  void downloadFailure(AlertInfo alertInfo) {
    _view!.onDownloadFailure(alertInfo);
  }

  Future downloadFiles({
    required BuildContext context,
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
          String fileType = Utils.fileType(fileTopic);
          bool isExist = await FileStorageHelper.checkExistFile(
              fileTopic, MediaType.video, null);

          if (fileType.isNotEmpty && !isExist) {
            LogModel log = await Utils.prepareToCreateLog(context,
                action: LogEvent.callApiDownloadFile);
            log.addData(key: "file_name", value: fileTopic);

            try {
              String url = downloadFileEP(fileNameForDownload);

              if (kDebugMode) {
                print("DEBUG: download video: $url");
              }

              dio!.head(url).timeout(const Duration(seconds: 30));
              // use client.get as you would http.get

              String savePath =
                  '${await FileStorageHelper.getFolderPath(MediaType.video, null)}\\$fileTopic';

              if (kDebugMode) {
                print("DEBUG: Downloading file at index = $index");
                print("DEBUG: Save as PATH = $savePath");
              }

              Response response = await dio!.download(url, savePath);

              if (response.statusCode == 200) {
                //Save file using file_storage
                // String contentString =
                //     await Utils.convertVideoToBase64(response);
                // await FileStorageHelper.writeVideo(
                //     contentString, fileTopic, MediaType.video);
                if (kDebugMode) {
                  print('DEBUG : save Path : $savePath');
                }

                //Add log
                log.message = response.statusMessage ?? "";
                Utils.addLog(log, LogEvent.success);

                double percent = _getPercent(index + 1, filesTopic.length);
                _view!.onDownloadSuccess(testDetail, fileTopic, percent,
                    index + 1, filesTopic.length);
              } else {
                //Add log
                log.message = "Download failed!";
                Utils.addLog(log, LogEvent.failed);

                _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert);
                reDownloadAutomatic(
                    context: context,
                    testDetail: testDetail,
                    filesTopic: filesTopic);
                break loop;
              }
            } on DioException catch (e) {
              if (kDebugMode) {
                print(
                    "DEBUG: Download error: ${e.type} - message: ${e.message}");
              }

              //Add log
              log.message = "Error type: ${e.type} - message: ${e.message}";
              Utils.addLog(log, LogEvent.failed);

              _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert);
              reDownloadAutomatic(
                  context: context,
                  testDetail: testDetail,
                  filesTopic: filesTopic);
              break loop;

              /*
              switch (e.type) {
                case DioExceptionType.badResponse: {
                  break loop;
                }
                case DioExceptionType.connectionTimeout: {
                  break loop;
                }
                case DioExceptionType.sendTimeout: {
                  break loop;
                }
                case DioExceptionType.receiveTimeout: {
                  break loop;
                }
                case DioExceptionType.badCertificate: {
                  break loop;
                }
                case DioExceptionType.cancel: {
                  break loop;
                }
                case DioExceptionType.connectionError: {
                  break loop;
                }
                case DioExceptionType.unknown: {
                  break loop;
                }
              }
              */
            } on TimeoutException {
              //Add log
              log.message = "TimeoutException";
              Utils.addLog(log, LogEvent.failed);

              _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert);
              reDownloadAutomatic(
                  context: context,
                  testDetail: testDetail,
                  filesTopic: filesTopic);
              break loop;
            } on SocketException {
              //Add log
              log.message = "SocketException";
              Utils.addLog(log, LogEvent.failed);

              _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert);
              //Download again
              reDownloadAutomatic(
                  context: context,
                  testDetail: testDetail,
                  filesTopic: filesTopic);
              break loop;
            } on http.ClientException {
              //Add log
              log.message = "ClientException";
              Utils.addLog(log, LogEvent.failed);

              _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert);
              //Download again
              reDownloadAutomatic(
                  context: context,
                  testDetail: testDetail,
                  filesTopic: filesTopic);
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
    required TestDetailModel testDetail,
    required List<FileTopicModel> filesTopic,
  }) {
    //Download again
    if (autoRequestDownloadTimes <= 3) {
      if (kDebugMode) {
        print("DEBUG: request to download in times: $autoRequestDownloadTimes");
      }
      downloadFiles(
          context: context, testDetail: testDetail, filesTopic: filesTopic);
      increaseAutoRequestDownloadTimes();
    } else {
      //Close old download request
      closeClientRequest();
      _view!.onReDownload();
    }
  }

  void reDownloadFiles(BuildContext context) {
    downloadFiles(
        context: context, testDetail: testDetail!, filesTopic: filesTopic!);
  }

  void tryAgainToDownload() async {
    if (kDebugMode) {
      print("DEBUG: SimulatorTestPresenter tryAgainToDownload");
    }

    _view!.onTryAgainToDownload();
  }

  Future<void> submitTest({
    required BuildContext context,
    required String testId,
    required String activityId,
    required List<QuestionTopicModel> questions,
    required bool isUpdate,
  }) async {
    assert(_view != null && _testRepository != null);

    //Add log
    LogModel log = await Utils.prepareToCreateLog(context,
        action: LogEvent.callApiSubmitTest);

    http.MultipartRequest multiRequest = await _formDataRequest(
      testId: testId,
      activityId: activityId,
      questions: questions,
      isUpdate: isUpdate,
      log: log,
    );

    if (kDebugMode) {
      print("DEBUG: testId = $testId");
      print("DEBUG: activityId = $activityId");
    }

    try {
      _testRepository!.submitTest(multiRequest).then((value) {
        if (kDebugMode) {
          print("DEBUG: submit response: $value");
        }

        Map<String, dynamic> json = jsonDecode(value) ?? {};
        if (json['error_code'] == 200) {
          ActivityAnswer activityAnswer =
              ActivityAnswer.fromJson(json['data']['activities_answer']);

          //Add log
          log.addData(key: "response", value: value);
          Utils.addLog(log, LogEvent.success);

          _view!.onSubmitTestSuccess(
              'Save your answers successfully!', activityAnswer);
        } else {
          //Add log
          log.message = "Has an error when submit this test!";
          log.addData(key: "response", value: value);
          Utils.addLog(log, LogEvent.failed);

          _view!.onSubmitTestFail("Has an error when submit this test!");
        }
      }).catchError((onError) {
        //Add log
        log.message = onError.toString();
        Utils.addLog(log, LogEvent.failed);

        // ignore: invalid_return_type_for_catch_error
        _view!.onSubmitTestFail(
            "invalid_return_type_for_catch_error: Has an error when submit this test!");
      });
    } on TimeoutException {
      //Add log
      log.message = "TimeoutException: Has an error when submit this test!";
      Utils.addLog(log, LogEvent.failed);

      _view!.onSubmitTestFail(
          "TimeoutException: Has an error when submit this test!");
    } on SocketException {
      //Add log
      log.message = "SocketException: Has an error when submit this test!";
      Utils.addLog(log, LogEvent.failed);

      _view!.onSubmitTestFail(
          "SocketException: Has an error when submit this test!");
    } on http.ClientException {
      //Add log
      log.message = "ClientException: Has an error when submit this test!";
      Utils.addLog(log, LogEvent.failed);

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
    required LogModel log,
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
    formData.addEntries([MapEntry('activity_id', activityId)]);
    formData.addEntries([MapEntry('is_update', isUpdate ? '1' : '0')]);

    if (Platform.isAndroid) {
      formData.addEntries([const MapEntry('os', "android")]);
    } else {
      formData.addEntries([const MapEntry('os', "ios")]);
    }
    String appVersion = await Utils.getAppVersion();
    formData.addEntries([MapEntry('app_version', appVersion)]);

    for (QuestionTopicModel q in questions) {
      String part = '';
      String reanswer = '';
      switch (q.numPart) {
        case 0:
          {
            part = "introduce";
            reanswer = 'reanswer_introduce';
            break;
          }
        case 1:
          {
            part = "part1";
            reanswer = 'reanswer_part1';
            break;
          }
        case 2:
          {
            part = "part2";
            reanswer = 'reanswer_part2';
            break;
          }
        case 3:
          {
            part = "part3";
            reanswer = 'reanswer_part3';
            if (q.isFollowUp == 1) {
              part = "followup";
              reanswer = 'reanswer_followup';
            }
            break;
          }
      }

      String prefix = "$part[${q.id}]";
      String reanswerFormat = "$reanswer[${q.id}]";

      formData
          .addEntries([MapEntry(reanswerFormat, q.reAnswerCount.toString())]);

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

    request.fields.addAll(formData);

    log.addData(key: "request_data", value: formData.toString());

    return request;
  }

  void handleEventBackButtonSystem({required bool isQuitTheTest}) {
    _view!.onHandleEventBackButtonSystem(isQuitTheTest: isQuitTheTest);
  }

  void handleBackButtonSystemTapped() {
    _view!.onHandleBackButtonSystemTapped();
  }
}
