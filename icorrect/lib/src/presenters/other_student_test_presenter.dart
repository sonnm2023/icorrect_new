import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/my_test_repository.dart';

import '../data_sources/api_urls.dart';
import '../data_sources/constant_strings.dart';
import '../data_sources/local/file_storage_helper.dart';
import '../data_sources/repositories/app_repository.dart';
import '../data_sources/utils.dart';
import '../models/simulator_test_models/file_topic_model.dart';
import '../models/simulator_test_models/question_topic_model.dart';
import '../models/simulator_test_models/test_detail_model.dart';
import '../models/simulator_test_models/topic_model.dart';
import '../models/ui_models/alert_info.dart';
import 'package:http/http.dart' as http;

abstract class OtherStudentTestContract {
  void getMyTestSuccess(List<QuestionTopicModel> questions);
  void getMyTestFail(AlertInfo alertInfo);
  void downloadFilesSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total);
  void downloadFilesFail(AlertInfo alertInfo);
  void onReDownload();
}

class OtherStudentTestPresenter {
  final OtherStudentTestContract? _view;
  MyTestRepository? _repository;

  OtherStudentTestPresenter(this._view) {
    _repository = Injector().getMyTestRepository();
  }
  int _autoRequestDownloadTimes = 0;
  int get autoRequestDownloadTimes => _autoRequestDownloadTimes;
  void increaseAutoRequestDownloadTimes() {
    _autoRequestDownloadTimes += 1;
  }

  http.Client? client;
  final Map<String, String> headers = {
    'Accept': 'application/json',
  };

  Future<void> initializeData() async {
    client ??= http.Client();
    resetAutoRequestDownloadTimes();
  }

  void closeClientRequest() {
    if (null != client) {
      client!.close();
      client = null;
    }
  }

  void resetAutoRequestDownloadTimes() {
    _autoRequestDownloadTimes = 0;
  }

  void getMyTest(String testId) {
    assert(_view != null && _repository != null);

    _repository!.getTestDetailWithId(testId).then((value) {
      Map<String, dynamic> json = jsonDecode(value) ?? {};
      if (json.isNotEmpty) {
        if (json['error_code'] == 200) {
          TestDetailModel testDetailModel =
              TestDetailModel.fromMyTestJson(json['data']);
          List<FileTopicModel> filesTopic =
              _prepareFileTopicListForDownload(testDetailModel);

          downloadFiles(testDetailModel, filesTopic);

          _view!.getMyTestSuccess(_getQuestionsAnswer(testDetailModel));
        } else {
          _view!.getMyTestFail(AlertClass.notResponseLoadTestAlert);
        }
      } else {
        _view!.getMyTestFail(AlertClass.getTestDetailAlert);
      }
    }).catchError(
        (onError) => _view!.getMyTestFail(AlertClass.getTestDetailAlert));
  }

  List<QuestionTopicModel> _getQuestionsAnswer(
      TestDetailModel testDetailModel) {
    List<QuestionTopicModel> questions = [];
    questions.addAll(testDetailModel.introduce.questionList);
    for (var q in testDetailModel.part1) {
      questions.addAll(q.questionList);
    }
    questions.addAll(testDetailModel.part2.questionList);
    questions.addAll(testDetailModel.part3.questionList);
    return questions;
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

  Future<http.Response> _sendRequest(String name) async {
    String url = downloadFileEP(name);
    return await AppRepository.init()
        .sendRequest(RequestMethod.get, url, false)
        .timeout(const Duration(seconds: 10));
  }

  //Check file is exist using file_storage
  Future<bool> _isExist(String fileName, MediaType mediaType) async {
    bool isExist =
        await FileStorageHelper.checkExistFile(fileName, mediaType, null);
    return isExist;
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

  void downloadSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total) {
    print("success : ${nameFile}");
    _view!.downloadFilesSuccess(testDetail, nameFile, percent, index, total);
  }

  void downloadFailure(AlertInfo alertInfo) {
    _view!.downloadFilesFail(alertInfo);
  }

  Future downloadFiles(
      TestDetailModel testDetail, List<FileTopicModel> filesTopic) async {
    if (client != null) {
      loop:
      for (int index = 0; index < filesTopic.length; index++) {
        FileTopicModel temp = filesTopic[index];
        String fileTopic = temp.url;
        String fileNameForDownload = Utils.convertFileName(fileTopic);

        if (filesTopic.isNotEmpty) {
          String fileType = Utils.fileType(fileTopic);
          bool isExist = await FileStorageHelper.checkExistFile(
              fileTopic, MediaType.video, null);
          if (fileType.isNotEmpty && !isExist) {
            try {
              if (kDebugMode) {
                print("DEBUG: Downloading file at index = $index");
              }
              // http.Response response = await _sendRequest(fileNameForDownload);
              String url = downloadFileEP(fileTopic);
              client!
                  .head(Uri.parse(url), headers: headers)
                  .timeout(const Duration(seconds: 10));
              http.Response response = await client!.get(
                Uri.parse(url),
              );

              if (response.statusCode == 200) {
                //Save file using file_storage
                String contentString =
                    await Utils.convertVideoToBase64(response);
                await FileStorageHelper.writeVideo(
                    contentString, fileNameForDownload, MediaType.audio);
                double percent = _getPercent(index + 1, filesTopic.length);
                _view!.downloadFilesSuccess(testDetail, fileTopic, percent,
                    index + 1, filesTopic.length);
              } else {
                _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
                reDownloadAutomatic(testDetail, filesTopic);
                break loop;
              }
            } on TimeoutException {
              _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
              reDownloadAutomatic(testDetail, filesTopic);
              break loop;
            } on SocketException {
              _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
              //Download again
              reDownloadAutomatic(testDetail, filesTopic);
              break loop;
            } on http.ClientException {
              _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
              //Download again
              reDownloadAutomatic(testDetail, filesTopic);
              break loop;
            }
          } else {
            double percent = _getPercent(index + 1, filesTopic.length);
            _view!.downloadFilesSuccess(
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

  void reDownloadAutomatic(
      TestDetailModel testDetail, List<FileTopicModel> filesTopic) {
    //Download again
    if (autoRequestDownloadTimes <= 3) {
      if (kDebugMode) {
        print("DEBUG: request to download in times: $autoRequestDownloadTimes");
      }
      downloadFiles(testDetail, filesTopic);
      increaseAutoRequestDownloadTimes();
    } else {
      //Close old download request
      closeClientRequest();
      _view!.onReDownload();
    }
  }
}
