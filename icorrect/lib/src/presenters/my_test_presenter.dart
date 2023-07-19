import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/my_test_repository.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';

import '../data_sources/api_urls.dart';
import '../data_sources/constant_strings.dart';
import '../data_sources/local/file_storage_helper.dart';
import '../data_sources/repositories/app_repository.dart';
import '../data_sources/utils.dart';
import '../models/simulator_test_models/topic_model.dart';
import '../models/ui_models/alert_info.dart';
import 'package:http/http.dart' as http;

abstract class MyTestConstract {
  void getMyTestSuccess(List<QuestionTopicModel> questions);
  void downloadFilesSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total);
  void downloadFilesFail(AlertInfo alertInfo);
  void getMyTestFail(AlertInfo alertInfo);
}

class MyTestPresenter {
  final MyTestConstract? _view;
  MyTestRepository? _repository;

  MyTestPresenter(this._view) {
    _repository = Injector().getMyTestRepository();
  }

  void getMyTest(String testId) {
    assert(_view != null && _repository != null);

    _repository!.getMyTestDetail(testId).then((value) {
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
    bool isExist = await FileStorageHelper.checkExistFile(fileName, mediaType);
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
    _view!.downloadFilesSuccess(testDetail, nameFile, percent, index, total);
  }

  void downloadFailure(AlertInfo alertInfo) {
    _view!.downloadFilesFail(alertInfo);
  }

  Future downloadFiles(
      TestDetailModel testDetail, List<FileTopicModel> filesTopic) async {
    loop:
    for (int index = 0; index < filesTopic.length; index++) {
      FileTopicModel temp = filesTopic[index];
      String fileTopic = temp.url;
      String fileNameForDownload = Utils.reConvertFileName(fileTopic);
      print('fileNameForDownload: ${fileNameForDownload}');
      print('fileTopic: ${fileTopic}');

      if (filesTopic.isNotEmpty) {
        String fileType = Utils.fileType(fileTopic);
        if (fileType.isNotEmpty &&
            !await _isExist(fileTopic, _mediaType(fileType))) {
          try {
            http.Response response = await _sendRequest(fileNameForDownload);

            if (response.statusCode == 200) {
              //Save file using file_storage
              String contentString = await Utils.convertVideoToBase64(response);
              await FileStorageHelper.writeVideo(
                  contentString, fileTopic, _mediaType(fileType));

              downloadSuccess(
                testDetail,
                fileTopic,
                _getPercent(index + 1, filesTopic.length),
                index + 1,
                filesTopic.length,
              );
            } else {
              _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
              break loop;
            }
          } on TimeoutException {
            _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
            break loop;
          } on SocketException {
            _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
            break loop;
          } on http.ClientException {
            _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
            break loop;
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
}
