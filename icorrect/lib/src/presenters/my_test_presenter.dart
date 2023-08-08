import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  void onReDownload();
  void getMyTestFail(AlertInfo alertInfo);
  void onCountDown(String time);
  void finishCountDown();
  void updateAnswersSuccess(String message);
  void updateAnswerFail(AlertInfo info);
}

class MyTestPresenter {
  final MyTestConstract? _view;
  MyTestRepository? _repository;

  MyTestPresenter(this._view) {
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

    print('testId: ${testId.toString()}');
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
        // ignore: invalid_return_type_for_catch_error

        (onError) {
      print("fail meomoe");
      _view!.getMyTestFail(AlertClass.getTestDetailAlert);
    });
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

  Future updateMyAnswer(
      {required String testId,
      required String activityId,
      required List<QuestionTopicModel> reQuestions}) async {
    assert(_view != null && _repository != null);

    http.MultipartRequest multiRequest = await _formDataRequest(
        testId: testId, activityId: activityId, questions: reQuestions);
    try {
      _repository!.updateAnswers(multiRequest).then((value) {
        Map<String, dynamic> json = jsonDecode(value) ?? {};
        print("error form: ${json.toString()}");
        if (json['error_code'] == 200 && json['status'] == 'success') {
          _view!.updateAnswersSuccess('Save your answers successfully!');
        } else {
          _view!.updateAnswerFail(AlertClass.errorWhenUpdateAnswer);
        }
      }).catchError((onError) {
        print('catchError updateAnswerFail ${onError.toString()}');
        _view!.updateAnswerFail(AlertClass.errorWhenUpdateAnswer);
      });
    } on TimeoutException {
      _view!.updateAnswerFail(AlertClass.timeOutUpdateAnswer);
    } on SocketException {
      _view!.updateAnswerFail(AlertClass.errorWhenUpdateAnswer);
    } on http.ClientException {
      _view!.updateAnswerFail(AlertClass.errorWhenUpdateAnswer);
    }
  }

  Future<http.MultipartRequest> _formDataRequest(
      {required String testId,
      required String activityId,
      required List<QuestionTopicModel> questions}) async {
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
      print("num part : ${q.numPart.toString()}");
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
        File audioFile = File(await FileStorageHelper.getFilePath(
            q.answers.elementAt(i).url.toString(), MediaType.audio, null));

        if (await audioFile.exists()) {
          request.files.add(
              await http.MultipartFile.fromPath(endFormat, audioFile.path));
        }
      }
    }

    request.fields.addAll(formData);

    return request;
  }
}
