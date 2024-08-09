import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:icorrect_pc/src/models/simulator_test_models/file_path_model.dart';

import '../data_source/api_urls.dart';
import '../data_source/constants.dart';
import '../data_source/dependency_injection.dart';
import '../data_source/local/file_storage_helper.dart';
import '../data_source/repositories/simulator_test_repository.dart';
import '../models/auth_models/video_record_exam_info.dart';
import '../models/homework_models/new_api_135/activity_answer_model.dart';
import '../models/log_models/log_model.dart';
import '../models/simulator_test_models/file_topic_model.dart';
import '../models/simulator_test_models/question_topic_model.dart';
import '../models/simulator_test_models/test_detail_model.dart';
import '../models/simulator_test_models/topic_model.dart';
import '../models/ui_models/alert_info.dart';
import '../models/user_data_models/user_data_model.dart';
import '../utils/utils.dart';

abstract class SimulatorTestViewContract {
  void onGetTestDetailComplete(TestDetailModel testDetailModel, int total);

  void onGetTestDetailError(String message);

  void onGetTestDetailCompleteForTool(String testID);

  void onGetTestDetailErrorForTool();

  void onDownloadSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total, FilePathModel filePathModel);

  void onDownloadFailure(AlertInfo info, FilePathModel filePathModel);

  void onDownloadFailureErrorTimeOut(FilePathModel filePathModel);

  void onSaveTopicListIntoProvider(List<TopicModel> list);

  void onGotoMyTestScreen(ActivityAnswer activityAnswer);

  void onSubmitTestSuccess(String msg, ActivityAnswer activityAnswer, int errorCode);

  void onSubmitTestFail(String msg, int errorCode);

  void onSubmitTestSuccessForTool();

  void onSubmitTestFailForTool();

  void onReDownload();

  void onTryAgainToDownload();

  void onHandleBackButtonSystemTapped();

  void onHandleEventBackButtonSystem({required bool isQuitTheTest});
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

  //////////////////////////GET TEST DETAIL BY HOMEWORK/////////////////////////

  void getTestDetailByHomework(BuildContext context, String homeworkId) async {
    UserDataModel? currentUser = await Utils.instance().getCurrentUser();
    if (currentUser == null) {
      _view!.onGetTestDetailError("Loading homework detail error!");
      return;
    }

    String distributeCode = currentUser.userInfoModel.distributorCode;

    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiGetTestDetail);
    }

    _testRepository!
        .getTestDetailByHomeWork(homeworkId, distributeCode)
        .then((value) async {
      Map<String, dynamic> map = jsonDecode(value);
      if (kDebugMode) {
        print("DEBUG: get detail test $value");
      }
      if (map['error_code'] == 200) {
        Map<String, dynamic> dataMap = map['data'];
        TestDetailModel tempTestDetailModel = TestDetailModel(testId: 0);
        tempTestDetailModel = TestDetailModel.fromJson(dataMap);
        testDetail = TestDetailModel.fromJson(dataMap);

        _prepareTopicList(tempTestDetailModel);

        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );

        List<FileTopicModel> tempFilesTopic =
            _prepareFileTopicListForDownload(tempTestDetailModel);

        filesTopic = _prepareFileTopicListForDownload(tempTestDetailModel);

        downloadFiles(context, tempTestDetailModel, tempFilesTopic,
            activityId: homeworkId);

        _view!.onGetTestDetailComplete(
            tempTestDetailModel, tempFilesTopic.length);
      } else {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message:
              "Loading homework detail error: ${map[StringConstants.k_error_code]} ${map[StringConstants.k_status]}",
          status: LogEvent.failed,
        );

        _view!.onGetTestDetailError(
            "${Utils.instance().multiLanguage(StringConstants.loading_error_homeworks_list)}: ${map['error_code']}${map['status']}");
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: null,
          message: onError.toString(),
          status: LogEvent.failed,
        );
        _view!.onGetTestDetailError(Utils.instance()
            .multiLanguage(StringConstants.network_error_message));
      },
    );
  }

  void getTestDetailByHomeworkForTool(BuildContext context, String homeworkId) async {
    UserDataModel? currentUser = await Utils.instance().getCurrentUser();
    if (currentUser == null) {
      _view!.onGetTestDetailErrorForTool();
      return;
    }

    String distributeCode = currentUser.userInfoModel.distributorCode;

    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiGetTestDetail);
    }

    _testRepository!
        .getTestDetailByHomeWork(homeworkId, distributeCode)
        .then((value) async {
      Map<String, dynamic> map = jsonDecode(value);
      if (kDebugMode) {
        print("DEBUG: get detail test $value");
      }
      if (map['error_code'] == 200) {
        Map<String, dynamic> dataMap = map['data'];
        TestDetailModel tempTestDetailModel = TestDetailModel(testId: 0);
        tempTestDetailModel = TestDetailModel.fromJson(dataMap);
        testDetail = TestDetailModel.fromJson(dataMap);

        _prepareTopicList(tempTestDetailModel);

        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );

        List<FileTopicModel> tempFilesTopic =
        _prepareFileTopicListForDownload(tempTestDetailModel);

        filesTopic = _prepareFileTopicListForDownload(tempTestDetailModel);

        downloadFiles(context, tempTestDetailModel, tempFilesTopic,
            activityId: homeworkId);

        _view!.onGetTestDetailCompleteForTool(testDetail!.testId.toString());
      } else {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message:
          "Loading homework detail error: ${map[StringConstants.k_error_code]} ${map[StringConstants.k_status]}",
          status: LogEvent.failed,
        );

        _view!.onGetTestDetailErrorForTool();
            }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
          (onError) {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: null,
          message: onError.toString(),
          status: LogEvent.failed,
        );
        _view!.onGetTestDetailErrorForTool();
      },
    );
  }

//////////////////////////GET TEST DETAIL BY PRACTICE/////////////////////////
  Future getTestDetailByPractice(
      {required BuildContext context,
      required int testOption,
      required List<int> topicsId,
      required int isPredict}) async {
    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiGetTestDetail);
    }

    _testRepository!
        .getTestDetailByPractice(
      testOption: testOption,
      topicsId: topicsId,
      isPredict: isPredict,
    )
        .then((value) async {
      Map<String, dynamic> map = jsonDecode(value);
      if (kDebugMode) {
        print("DEBUG: get detail test $value");
      }
      if (map['error_code'] == 200) {
        Map<String, dynamic> dataMap = map['data'];
        TestDetailModel tempTestDetailModel = TestDetailModel(testId: 0);
        tempTestDetailModel = TestDetailModel.fromJson(dataMap);
        testDetail = TestDetailModel.fromJson(dataMap);

        _prepareTopicList(tempTestDetailModel);

        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );

        List<FileTopicModel> tempFilesTopic =
            _prepareFileTopicListForDownload(tempTestDetailModel);

        filesTopic = _prepareFileTopicListForDownload(tempTestDetailModel);

        downloadFiles(context, tempTestDetailModel, tempFilesTopic);

        _view!.onGetTestDetailComplete(
            tempTestDetailModel, tempFilesTopic.length);
      } else {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: null,
          message:
              "Loading practice detail error: ${map[StringConstants.k_error_code]} "
              "${map[StringConstants.k_status]}",
          status: LogEvent.failed,
        );

        _view!.onGetTestDetailError(
            "${Utils.instance().multiLanguage(StringConstants.load_practice_detail)}:"
            " ${map['error_code']}${map['status']}");
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: null,
          message: onError.toString(),
          status: LogEvent.failed,
        );

        _view!.onGetTestDetailError(Utils.instance()
            .multiLanguage(StringConstants.common_error_message));
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
          testDetail.part3.followUp.isNotEmpty ||
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
    allFiles.addAll(topic.files);

    //Add question files
    for (QuestionTopicModel q in topic.questionList) {
      allFiles.add(q.files[0]);
      if (q.files.length > 1) {
        if (q.files[1].url.endsWith('png')) {
          allFiles.add(q.files[1]);
        }
      }
      // allFiles.addAll(q.files);
      allFiles.addAll(q.answers);
    }

    for (QuestionTopicModel q in topic.followUp) {
      allFiles.add(q.files[0]);
      // allFiles.addAll(q.files);
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

  // void downloadFailure(AlertInfo alertInfo) {
  //   _view!.onDownloadFailure(alertInfo);
  // }

  Future downloadFiles(BuildContext context, TestDetailModel testDetail,
      List<FileTopicModel> filesTopic,
      {String? activityId}) async {
    if (null != dio) {
      loop:
      for (int index = 0; index < filesTopic.length; index++) {
        FileTopicModel temp = filesTopic[index];
        String fileTopic = temp.url;
        String fileNameForDownload =
            Utils.instance().reConvertFileName(fileTopic);
        String savePath = '';

        if (filesTopic.isNotEmpty) {
          String fileType = Utils.instance().fileType(fileTopic);
          MediaType mediaType = Utils.instance().mediaType(fileTopic);
          bool isExist = await FileStorageHelper.newCheckExistFile(
              fileTopic, mediaType);
          if (fileType.isNotEmpty && !isExist) {
            savePath =
            '${await FileStorageHelper.getFolderPath(mediaType, null)}\\$fileTopic';
            LogModel? log;
            if (context.mounted) {
              log = await Utils.instance().prepareToCreateLog(context,
                  action: LogEvent.callApiDownloadFile);
              Map<String, dynamic> fileDownloadInfo = {
                StringConstants.k_test_id: testDetail.testId.toString(),
                StringConstants.k_file_name: fileTopic,
                StringConstants.k_file_path:
                    downloadFileEP(fileNameForDownload),
              };
              if (activityId != null) {
                fileDownloadInfo.addEntries(
                    [MapEntry(StringConstants.k_activity_id, activityId)]);
              }
              log.addData(
                  key: "file_download_info",
                  value: json.encode(fileDownloadInfo));
            }
            try {
              if (kDebugMode) {
                print("DEBUG: Downloading file at index = $index");
              }

              FilePathModel filePathModel = FilePathModel(savePath: savePath, isSuccess: false);

              if (dio == null) {
                _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert, filePathModel);
                return;
              }
              String url = downloadFileEP(fileNameForDownload);
              dio!.head(url).timeout(const Duration(seconds: 20));
              if (kDebugMode) {
                print('DEBUG DOWNLOAD FILE: START DOWNLOAD FILE $url');
              }
              //add savePath to list with status false
              _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert, filePathModel);

              Response response = await dio!.download(url, savePath);
              print(savePath);
              if (response.statusCode == 200) {
                //Add log
                Utils.instance().prepareLogData(
                  log: log,
                  data: null,
                  message: response.statusMessage,
                  status: LogEvent.success,
                );
                filePathModel.isSuccess = true;
                double percent = _getPercent(index + 1, filesTopic.length);
                _view!.onDownloadSuccess(testDetail, fileTopic, percent,
                    index + 1, filesTopic.length, filePathModel);
              } else {
                //Add log
                Utils.instance().prepareLogData(
                  log: log,
                  data: null,
                  message: "Download failed!",
                  status: LogEvent.failed,
                );
                _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert, filePathModel);
                // _view!.onDownloadFailureErrorTimeOut(filePathModel);
                reDownloadAutomatic(context, testDetail, filesTopic,
                    activityId: activityId);
                break loop;
              }
            } on DioException {
              _view!.onDownloadFailureErrorTimeOut(FilePathModel(savePath: savePath, isSuccess: false));
              reDownloadAutomatic(context, testDetail, filesTopic,
                  activityId: activityId);
              break loop;
            }
          } else {
            savePath = await FileStorageHelper.newGetFilePath(fileTopic, mediaType);
            print(savePath);
            double percent = _getPercent(index + 1, filesTopic.length);
            _view!.onDownloadSuccess(
                testDetail, fileTopic, percent, index + 1, filesTopic.length, FilePathModel(savePath: savePath, isSuccess: true));
          }
        }
      }
    } else {
      if (kDebugMode) {
        print("DEBUG: client is closed!");
      }
    }
  }

  void reDownloadAutomatic(BuildContext context, TestDetailModel testDetail,
      List<FileTopicModel> filesTopic,
      {String? activityId}) {
    //Download again
    if (autoRequestDownloadTimes <= 3) {
      if (kDebugMode) {
        print("DEBUG: request to download in times: $autoRequestDownloadTimes");
      }
      downloadFiles(context, testDetail, filesTopic, activityId: activityId);
      increaseAutoRequestDownloadTimes();
    } else {
      //Close old download request
      closeClientRequest();
      _view!.onReDownload();
    }
  }

  void gotoMyTestScreen(ActivityAnswer activityAnswer) {
    _view!.onGotoMyTestScreen(activityAnswer);
  }

  void reDownloadFiles(BuildContext context, {String? activityId}) {
    downloadFiles(context, testDetail!, filesTopic!, activityId: activityId);
  }

  void tryAgainToDownload() async {
    if (kDebugMode) {
      print("DEBUG: SimulatorTestPresenter tryAgainToDownload");
    }

    _view!.onTryAgainToDownload();
  }

  String randomVideoRecordExam(List<VideoExamRecordInfo> videosSaved) {
    if (videosSaved.length > 1) {
      List<VideoExamRecordInfo> prepareVideoForRandom = [];
      for (int i = 0; i < videosSaved.length; i++) {
        if (videosSaved[i].duration! >= 7) {
          prepareVideoForRandom.add(videosSaved[i]);
        }
      }
      if (prepareVideoForRandom.isEmpty) {
        return _getMaxDurationVideo(videosSaved);
      } else {
        Random random = Random();
        int elementRandom = random.nextInt(prepareVideoForRandom.length);
        return prepareVideoForRandom[elementRandom].filePath ?? "";
      }
    } else {
      return _getMaxDurationVideo(videosSaved);
    }
  }

  String _getMaxDurationVideo(List<VideoExamRecordInfo> videosSaved) {
    if (videosSaved.isNotEmpty) {
      videosSaved.sort(((a, b) => a.duration!.compareTo(b.duration!)));
      VideoExamRecordInfo maxValue = videosSaved.last;
      return maxValue.filePath ?? '';
    }
    return '';
  }

  Future<void> submitTest({
    required BuildContext context,
    required String testId,
    required String activityId,
    required List<QuestionTopicModel> questions,
    required bool isExam,
    required bool isUpdate,
    File? videoConfirmFile,
    List<Map<String, dynamic>>? logAction,
  }) async {
    assert(_view != null && _testRepository != null);

    //Add log
    LogModel? log;
    Map<String, dynamic> dataLog = {};

    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiSubmitTest);
    }

    http.MultipartRequest multiRequest = await Utils.instance()
        .formDataRequestSubmit(
            testId: testId,
            activityId: activityId,
            questions: questions,
            isUpdate: isUpdate,
            isExam: isExam,
            videoConfirmFile: videoConfirmFile,
            logAction: logAction);

    try {
      _testRepository!.submitTest(multiRequest).then((value) {
        if (kDebugMode) {
          print("DEBUG: submit response: $value");
        }

        Map<String, dynamic> json = jsonDecode(value) ?? {};
        dataLog = json;
        if (json['error_code'] == 200) {
          //ActivityAnswer activityAnswer = json[''];
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: dataLog,
            message: null,
            status: LogEvent.success,
          );
          _view!.onSubmitTestSuccess(
              Utils.instance()
                  .multiLanguage(StringConstants.save_your_answers_success),
              ActivityAnswer(), json['error_code']);
        } else {
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: dataLog,
            message: StringConstants.submit_test_error_message,
            status: LogEvent.failed,
          );
          String errorCode = "";
          if (json[StringConstants.k_error_code] != null) {
            errorCode = " [Error Code: ${json[StringConstants.k_error_code]}]";
          }
          _view!.onSubmitTestFail(
              "${Utils.instance().multiLanguage(StringConstants.has_an_error_while_submitting)} ! $errorCode", json['error_code']);
        }
      }).catchError((onError) {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: dataLog,
          message: onError.toString(),
          status: LogEvent.failed,
        );

        _view!.onSubmitTestFail(
            "${Utils.instance().multiLanguage(StringConstants.has_an_error_while_submitting)} !", 9999);
      });
    } on TimeoutException {
      //Add log
      Utils.instance().prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_timeout,
        status: LogEvent.failed,
      );
      _view!.onSubmitTestFail(Utils.instance()
          .multiLanguage(StringConstants.submit_test_error_timeout), 9999);
    } on SocketException {
      //Add log
      Utils.instance().prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_socket,
        status: LogEvent.failed,
      );
      _view!.onSubmitTestFail(Utils.instance()
          .multiLanguage(StringConstants.submit_test_error_socket), 9999);
    } on http.ClientException {
      //Add log
      Utils.instance().prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_client,
        status: LogEvent.failed,
      );
      _view!.onSubmitTestFail(Utils.instance()
          .multiLanguage(StringConstants.submit_test_error_client), 9999);
    }
  }

  Future<void> submitTestForTool({
    required BuildContext context,
    required String testId,
    required String activityId,
    required List<QuestionTopicModel> questions,
    required bool isExam,
    required bool isUpdate,
    File? videoConfirmFile,
    List<Map<String, dynamic>>? logAction,
  }) async {
    assert(_view != null && _testRepository != null);

    //Add log
    LogModel? log;
    Map<String, dynamic> dataLog = {};

    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiSubmitTest);
    }

    http.MultipartRequest multiRequest = await Utils.instance()
        .formDataRequestSubmit(
        testId: testId,
        activityId: activityId,
        questions: questions,
        isUpdate: isUpdate,
        isExam: isExam,
        videoConfirmFile: videoConfirmFile,
        logAction: logAction);

    try {
      _testRepository!.submitTest(multiRequest).then((value) {
        if (kDebugMode) {
          print("DEBUG: submit response: $value");
        }

        Map<String, dynamic> json = jsonDecode(value) ?? {};
        if (json['error_code'] == 200) {
          //ActivityAnswer activityAnswer = json[''];
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: dataLog,
            message: null,
            status: LogEvent.success,
          );
          _view!.onSubmitTestSuccessForTool();
        } else {
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: dataLog,
            message: StringConstants.submit_test_error_message,
            status: LogEvent.failed,
          );
          String errorCode = "";
          if (json[StringConstants.k_error_code] != null) {
            errorCode = " [Error Code: ${json[StringConstants.k_error_code]}]";
          }
          _view!.onSubmitTestFailForTool();
        }
      }).catchError((onError) {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: dataLog,
          message: onError.toString(),
          status: LogEvent.failed,
        );

        _view!.onSubmitTestFailForTool();
      });
    } on TimeoutException {
      //Add log
      Utils.instance().prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_timeout,
        status: LogEvent.failed,
      );
      _view!.onSubmitTestFailForTool();
    } on SocketException {
      //Add log
      Utils.instance().prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_socket,
        status: LogEvent.failed,
      );
      _view!.onSubmitTestFailForTool();
    } on http.ClientException {
      //Add log
      Utils.instance().prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_client,
        status: LogEvent.failed,
      );
      _view!.onSubmitTestFailForTool();
    }
  }

  void handleEventBackButtonSystem({required bool isQuitTheTest}) {
    _view!.onHandleEventBackButtonSystem(isQuitTheTest: isQuitTheTest);
  }

  void handleBackButtonSystemTapped() {
    _view!.onHandleBackButtonSystemTapped();
  }
}
