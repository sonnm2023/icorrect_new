// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:icorrect/src/data_sources/dependency_injection.dart';
// import 'package:icorrect/src/data_sources/repositories/my_test_repository.dart';

// import '../data_sources/api_urls.dart';
// import '../data_sources/constants.dart';
// import '../data_sources/local/file_storage_helper.dart';
// import '../data_sources/repositories/app_repository.dart';
// import '../data_sources/utils.dart';
// import '../models/simulator_test_models/file_topic_model.dart';
// import '../models/simulator_test_models/question_topic_model.dart';
// import '../models/simulator_test_models/test_detail_model.dart';
// import '../models/simulator_test_models/topic_model.dart';
// import '../models/ui_models/alert_info.dart';
// import 'package:http/http.dart' as http;

// abstract class OtherStudentTestContract {
//   void getMyTestSuccess(List<QuestionTopicModel> questions);
//   void getMyTestFail(AlertInfo alertInfo);
//   void downloadFilesSuccess(TestDetailModel testDetail, String nameFile,
//       double percent, int index, int total);
//   void downloadFilesFail(AlertInfo alertInfo);
// }

// class OtherStudentTestPresenter {
//   final OtherStudentTestContract? _view;
//   MyTestRepository? _repository;

//   OtherStudentTestPresenter(this._view) {
//     _repository = Injector().getMyTestRepository();
//   }

//   void getMyTest(String testId) {
//     assert(_view != null && _repository != null);

//     // print('testId: ${testId.toString()}');
//     // _repository!.getMyTestDetail(testId).then((value) {
//     //   if (value != null) {
//     //     print('dadas: ${value.toString()}');
//     //     Map<String, dynamic> json = jsonDecode(value) ?? {};
//     //     if (json.isNotEmpty) {
//     //       if (json['error_code'] == 200) {
//     //         TestDetailModel testDetailModel =
//     //             TestDetailModel.fromMyTestJson(json['data']);
//     //         List<FileTopicModel> filesTopic =
//     //             _prepareFileTopicListForDownload(testDetailModel);

//     //         downloadFiles(testDetailModel, filesTopic);

//     //         _view!.getMyTestSuccess(_getQuestionsAnswer(testDetailModel));
//     //       } else {
//     //         _view!.getMyTestFail(AlertClass.notResponseLoadTestAlert);
//     //       }
//     //     } else {
//     //       _view!.getMyTestFail(AlertClass.getTestDetailAlert);
//     //     }
//     //   }
//     // }).catchError(
//     //     // ignore: invalid_return_type_for_catch_error

//     //     (onError) {
//     //   print("fail meomoe : ${onError.toString()}");
//     //   _view!.getMyTestFail(AlertClass.getTestDetailAlert);
//     // });

//     _repository!.getTestDetailWithId(testId).then((value) {
//       Map<String, dynamic> json = jsonDecode(value) ?? {};
//       if (json.isNotEmpty) {
//         if (json['error_code'] == 200) {
//           TestDetailModel testDetailModel =
//               TestDetailModel.fromMyTestJson(json['data']);
//           List<FileTopicModel> filesTopic =
//               _prepareFileTopicListForDownload(testDetailModel);

//           downloadFiles(testDetailModel, filesTopic);

//           _view!.getMyTestSuccess(_getQuestionsAnswer(testDetailModel));
//         } else {
//           _view!.getMyTestFail(AlertClass.notResponseLoadTestAlert);
//         }
//       } else {
//         _view!.getMyTestFail(AlertClass.getTestDetailAlert);
//       }
//     }).catchError(
//         // ignore: invalid_return_type_for_catch_error
//         (onError) => _view!.getMyTestFail(AlertClass.getTestDetailAlert));
//   }

//   List<QuestionTopicModel> _getQuestionsAnswer(
//       TestDetailModel testDetailModel) {
//     List<QuestionTopicModel> questions = [];
//     questions.addAll(testDetailModel.introduce.questionList);
//     for (var q in testDetailModel.part1) {
//       questions.addAll(q.questionList);
//     }
//     questions.addAll(testDetailModel.part2.questionList);
//     questions.addAll(testDetailModel.part3.questionList);
//     return questions;
//   }

//   List<FileTopicModel> _prepareFileTopicListForDownload(
//       TestDetailModel testDetail) {
//     List<FileTopicModel> filesTopic = [];
//     filesTopic.addAll(getAllFilesOfTopic(testDetail.introduce));

//     for (int i = 0; i < testDetail.part1.length; i++) {
//       TopicModel temp = testDetail.part1[i];
//       filesTopic.addAll(getAllFilesOfTopic(temp));
//     }

//     filesTopic.addAll(getAllFilesOfTopic(testDetail.part2));

//     filesTopic.addAll(getAllFilesOfTopic(testDetail.part3));
//     return filesTopic;
//   }

//   Future<http.Response> _sendRequest(String name) async {
//     String url = downloadFileEP(name);
//     return await AppRepository.init()
//         .sendRequest(RequestMethod.get, url, false)
//         .timeout(const Duration(seconds: 10));
//   }

//   //Check file is exist using file_storage
//   Future<bool> _isExist(String fileName, MediaType mediaType) async {
//     bool isExist =
//         await FileStorageHelper.checkExistFile(fileName, mediaType, null);
//     return isExist;
//   }

//   MediaType _mediaType(String type) {
//     return (type == StringClass.audio) ? MediaType.audio : MediaType.video;
//   }

//   double _getPercent(int downloaded, int total) {
//     return (downloaded / total);
//   }

//   List<FileTopicModel> getAllFilesOfTopic(TopicModel topic) {
//     List<FileTopicModel> allFiles = [];
//     //Add introduce file
//     allFiles.addAll(topic.files);

//     //Add question files
//     for (QuestionTopicModel q in topic.questionList) {
//       allFiles.add(q.files.first);
//       allFiles.addAll(q.answers);
//     }

//     for (QuestionTopicModel q in topic.followUp) {
//       allFiles.add(q.files.first);
//       allFiles.addAll(q.answers);
//     }

//     if (topic.endOfTakeNote.url.isNotEmpty) {
//       allFiles.add(topic.endOfTakeNote);
//     }

//     if (topic.fileEndOfTest.url.isNotEmpty) {
//       allFiles.add(topic.fileEndOfTest);
//     }

//     return allFiles;
//   }

//   void downloadSuccess(TestDetailModel testDetail, String nameFile,
//       double percent, int index, int total) {
//     if (kDebugMode) {
//       print("DEBUG: success : $nameFile");
//     }
//     _view!.downloadFilesSuccess(testDetail, nameFile, percent, index, total);
//   }

//   void downloadFailure(AlertInfo alertInfo) {
//     _view!.downloadFilesFail(alertInfo);
//   }

//   Future downloadFiles(
//       TestDetailModel testDetail, List<FileTopicModel> filesTopic) async {
//     loop:
//     for (int index = 0; index < filesTopic.length; index++) {
//       FileTopicModel temp = filesTopic[index];
//       String fileTopic = temp.url;
//       String fileNameForDownload = Utils.reConvertFileName(fileTopic);

//       if (filesTopic.isNotEmpty) {
//         String fileType = Utils.fileType(fileTopic);

//         if (_mediaType(fileType) == MediaType.audio) {
//           fileNameForDownload = fileTopic;
//           fileTopic = Utils.convertFileName(fileTopic);
//         }

//         if (fileType.isNotEmpty &&
//             !await _isExist(fileTopic, _mediaType(fileType))) {
//           try {
//             http.Response response = await _sendRequest(fileNameForDownload);

//             if (response.statusCode == 200) {
//               String contentString = await Utils.convertVideoToBase64(response);
//               if (kDebugMode) {
//                 print('DEBUG: content String:$contentString');
//                 print('DEBUG: file topic :$fileTopic');
//               }

//               await FileStorageHelper.writeVideo(
//                   contentString, fileTopic, _mediaType(fileType));

//               downloadSuccess(
//                 testDetail,
//                 fileTopic,
//                 _getPercent(index + 1, filesTopic.length),
//                 index + 1,
//                 filesTopic.length,
//               );
//             } else {
//               _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
//               //Download again
//               downloadFiles(testDetail, filesTopic);
//               break loop;
//             }
//           } on TimeoutException {
//             _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
//             //Download again
//             downloadFiles(testDetail, filesTopic);
//             break loop;
//           } on SocketException {
//             _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
//             //Download again
//             downloadFiles(testDetail, filesTopic);
//             break loop;
//           } on http.ClientException {
//             _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
//             //Download again
//             downloadFiles(testDetail, filesTopic);
//             break loop;
//           }
//         } else {
//           downloadSuccess(
//             testDetail,
//             fileTopic,
//             _getPercent(index + 1, filesTopic.length),
//             index + 1,
//             filesTopic.length,
//           );
//         }
//       }
//     }
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/my_test_repository.dart';

import '../data_sources/api_urls.dart';
import '../data_sources/constants.dart';
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
  void onTryAgainToDownload();
}

class OtherStudentTestPresenter {
  final OtherStudentTestContract? _view;
  MyTestRepository? _repository;

  OtherStudentTestPresenter(this._view) {
    _repository = Injector().getMyTestRepository();
  }

  http.Client? client;
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
    client ??= http.Client();
    resetAutoRequestDownloadTimes();
  }

  void resetAutoRequestDownloadTimes() {
    _autoRequestDownloadTimes = 0;
  }

  void closeClientRequest() {
    if (null != client) {
      client!.close();
      client = null;
    }
  }

  void getMyTest(String testId) {
    assert(_view != null && _repository != null);

    if (kDebugMode) {
      print('DEBUG: testId: ${testId.toString()}');
    }

    _repository!.getTestDetailWithId(testId).then((value) {
      Map<String, dynamic> json = jsonDecode(value) ?? {};
      if (json.isNotEmpty) {
        if (json['error_code'] == 200) {
          Map<String, dynamic> dataMap = json['data'];
          TestDetailModel testDetailModel =
              TestDetailModel.fromMyTestJson(dataMap);
          testDetail = TestDetailModel.fromMyTestJson(dataMap);

          List<FileTopicModel> tempFilesTopic =
              _prepareFileTopicListForDownload(testDetailModel);

          filesTopic = _prepareFileTopicListForDownload(testDetailModel);

          downloadFiles(testDetailModel, tempFilesTopic);

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
      if (kDebugMode) {
        print("DEBUG: fail meomoe");
      }

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

  void downloadFailure(AlertInfo alertInfo) {
    _view!.downloadFilesFail(alertInfo);
  }

  Future downloadFiles(
      TestDetailModel testDetail, List<FileTopicModel> filesTopic) async {
    if (null != client) {
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
                String contentString =
                    await Utils.convertVideoToBase64(response);
                if (kDebugMode) {
                  print('DEBUG: content String:$contentString');
                  print('DEBUG: file topic :$fileTopic');
                }

                await FileStorageHelper.writeVideo(
                    contentString, fileTopic, _mediaType(fileType));

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
              reDownloadAutomatic(testDetail, filesTopic);
              break loop;
            } on http.ClientException {
              _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
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

  void tryAgainToDownload() async {
    if (kDebugMode) {
      print("DEBUG: MyTestPresenter tryAgainToDownload");
    }

    _view!.onTryAgainToDownload();
  }

  void reDownloadFiles() {
    downloadFiles(testDetail!, filesTopic!);
  }
}
