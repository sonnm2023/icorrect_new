import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/repositories/app_repository.dart';
import 'package:icorrect/src/data_sources/repositories/test_repository.dart';
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
}

class SimulatorTestPresenter {
  final SimulatorTestViewContract? _view;
  TestRepository? _testRepository;

  SimulatorTestPresenter(this._view) {
    _testRepository = Injector().getTestRepository();
  }

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
        TestDetailModel testDetail = TestDetailModel(testId: 0);
        testDetail = TestDetailModel.fromJson(dataMap);

        _prepareTopicList(testDetail);

        List<FileTopicModel> filesTopic =
            _prepareFileTopicListForDownload(testDetail);

        downloadFiles(testDetail, filesTopic);

        _view!.onGetTestDetailComplete(testDetail, filesTopic.length);
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
    testDetail.introduce.numPart = PartOfTest.introduce.get;
    topicsList.add(testDetail.introduce);

    //Part 1
    for (int i = 0; i < testDetail.part1.length; i++) {
      testDetail.part1[i].numPart = PartOfTest.part1.get;
    }
    topicsList.addAll(testDetail.part1);

    //Part 2
    testDetail.part2.numPart = PartOfTest.part2.get;
    topicsList.add(testDetail.part2);

    //Part 3
    if (testDetail.part3.questionList.isNotEmpty ||
        testDetail.part3.fileEndOfTest.url.isNotEmpty) {
      testDetail.part3.numPart = PartOfTest.part3.get;
      topicsList.add(testDetail.part3);
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

  //Check file is exist using file_storage
  Future<bool> _isExist(String fileName, MediaType mediaType) async {
    bool isExist = await FileStorageHelper.checkExistFile(fileName, mediaType);
    return isExist;
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

  void downloadSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total) {
    _view!.onDownloadSuccess(testDetail, nameFile, percent, index, total);
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
        if (fileType.isNotEmpty &&
            !await _isExist(fileTopic, MediaType.video)) {
          try {
            http.Response response = await _sendRequest(fileNameForDownload);

            if (response.statusCode == 200) {
              //Save file using file_storage
              String contentString = await Utils.convertVideoToBase64(response);
              await FileStorageHelper.writeVideo(
                  contentString, fileTopic, MediaType.video);

              downloadSuccess(
                testDetail,
                fileTopic,
                _getPercent(index + 1, filesTopic.length),
                index + 1,
                filesTopic.length,
              );
            } else {
              _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert);
              break loop;
            }
          } on TimeoutException {
            _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert);
          } on SocketException {
            _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert);
          } on http.ClientException {
            _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert);
          }
        } else {
          downloadSuccess(
            testDetail,
            fileTopic,
            _getPercent(index + 1, filesTopic.length),
            index + 1,
            filesTopic.length,
          );
        }
      }
    }
  }

  void clickSaveTheTest() {
    //TODO: Submit homework
    if (kDebugMode) print("clickSaveTheTest");
  }
}
