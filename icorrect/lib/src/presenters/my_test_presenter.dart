import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
        // ignore: invalid_return_type_for_catch_error
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
    bool isExist = await FileStorageHelper.checkExistFile(fileName, mediaType, null); //TODO
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

      if (filesTopic.isNotEmpty) {
        String fileType = Utils.fileType(fileTopic);

        if (_mediaType(fileType) == MediaType.audio) {
          fileNameForDownload = fileTopic;
          fileTopic = Utils.convertFileName(fileTopic);
        }

        if (fileType.isNotEmpty &&
            !await _isExist(fileTopic, _mediaType(fileType))) {
          try {
            http.Response response = await _sendRequest(fileNameForDownload);

            if (response.statusCode == 200) {
              String contentString = await Utils.convertVideoToBase64(response);
              print('content String:${contentString}');
              print('file topic :${fileTopic}');

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
    String format = '';
    String reanswerFormat = '';
    String endFormat = '';
    for (QuestionTopicModel q in questions) {
      String questionId = q.id.toString();
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
            q.answers.elementAt(i).url.toString(), MediaType.audio, null)); //TODO

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
