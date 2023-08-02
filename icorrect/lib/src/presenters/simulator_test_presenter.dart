import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/repositories/app_repository.dart';
import 'package:icorrect/src/data_sources/repositories/simulator_test_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

abstract class SimulatorTestViewContract {
  void onGetTestDetailComplete(TestDetailModel testDetailModel, int total);
  void onGetTestDetailError(String message);
  void onDownloadSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total);
  void onDownloadFailure(AlertInfo info);
  void onSaveTopicListIntoProvider(List<TopicModel> list);
  void onGotoMyTestScreen();
  void onSubmitTestSuccess(String msg);
  void onSubmitTestFail(String msg);
  void onReDownload();
  void onTryAgainToDownload();
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

  void resetAutoRequestDownloadTimes() {
    _autoRequestDownloadTimes = 0;
  }

  TestDetailModel? testDetail;
  List<FileTopicModel>? filesTopic;

  void getTestDetail(String homeworkId) async {
    UserDataModel? currentUser = await Utils.getCurrentUser();
    if (currentUser == null) {
      _view!.onGetTestDetailError("Loading homework detail error!");
      return;
    }

    String distributeCode = currentUser.userInfoModel.distributorCode;

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

        List<FileTopicModel> tempFilesTopic =
            _prepareFileTopicListForDownload(tempTestDetailModel);

        filesTopic =
            _prepareFileTopicListForDownload(tempTestDetailModel);

        downloadFiles(tempTestDetailModel, tempFilesTopic);

        _view!.onGetTestDetailComplete(tempTestDetailModel, tempFilesTopic.length);
      } else {
        _view!.onGetTestDetailError(
            "Loading homework detail error: ${map['error_code']}${map['status']}");
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) => _view!.onGetTestDetailError(onError.toString()),
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

  Future<http.Response> _sendRequest(String name) async {
    String url = downloadFileEP(name);
    return await AppRepository.init()
        .sendRequest(RequestMethod.get, url, false)
        .timeout(const Duration(seconds: 10));
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
    _view!.onDownloadFailure(alertInfo);
  }

  Future downloadFiles(
      TestDetailModel testDetail, List<FileTopicModel> filesTopic) async {
    loop:
    for (int index = 0; index < filesTopic.length; index++) {
      FileTopicModel temp = filesTopic[index];
      String fileTopic = temp.url;
      String fileNameForDownload = Utils.reConvertFileName(fileTopic);

      if (filesTopic.isNotEmpty) {
        String fileType = Utils.fileType(fileTopic);
        bool isExist = await FileStorageHelper.checkExistFile(fileTopic, MediaType.video, null);
        if (fileType.isNotEmpty &&
            !isExist) {
          try {
            if (kDebugMode) {
              print("DEBUG: Downloading file at index = $index");
            }

            http.Response response = await _sendRequest(fileNameForDownload);

            if (response.statusCode == 200) {
              //Save file using file_storage
              String contentString = await Utils.convertVideoToBase64(response);
              await FileStorageHelper.writeVideo(
                  contentString, fileTopic, MediaType.video);
              double percent = _getPercent(index + 1, filesTopic.length);
              _view!.onDownloadSuccess(testDetail, fileTopic, percent, index + 1, filesTopic.length);
            } else {
              _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert);
              //Download again
              downloadFiles(testDetail, filesTopic);
              break loop;
            }
          } on TimeoutException {
            _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert);
            reDownload(testDetail, filesTopic);
            break loop;
          } on SocketException {
            _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert);
            //Download again
            reDownload(testDetail, filesTopic);
            break loop;
          } on http.ClientException {
            _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert);
            //Download again
            reDownload(testDetail, filesTopic);
            break loop;
          }
        } else {
          double percent = _getPercent(index + 1, filesTopic.length);
          _view!.onDownloadSuccess(testDetail, fileTopic, percent, index + 1, filesTopic.length);
        }
      }
    }
  }

  void reDownload(TestDetailModel testDetail, List<FileTopicModel> filesTopic) {
    //Download again
    if (autoRequestDownloadTimes <= 3) {
      if (kDebugMode) {
        print("DEBUG: request to download in times: $autoRequestDownloadTimes");
      }
      downloadFiles(testDetail, filesTopic);
      increaseAutoRequestDownloadTimes();
    } else {
      _view!.onReDownload();
    }
  }

  void gotoMyTestScreen() {
    _view!.onGotoMyTestScreen();
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

  void reDownloadFiles() {
    downloadFiles(testDetail!, filesTopic!);
  }

  void tryAgainToDownload() async {
    if (kDebugMode) {
      print("DEBUG: tryAgainToDownload");
    }

    _view!.onTryAgainToDownload();
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
  
  List<MapEntry<String, String>> _generateFormat(
      QuestionTopicModel q, String suffix) {
    List<MapEntry<String, String>> result = [];

    if (q.answers.isEmpty) return [];

    for (int i = 0; i < q.answers.length; i++) {
      result.add(MapEntry("$suffix[$i]", q.answers[i].url));
    }

    return result;
  }

}
