import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/repositories/my_test_repository.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';

abstract class OtherStudentTestContract {
  void onGetMyTestSuccess(List<QuestionTopicModel> questions);
  void onGetMyTestFail(AlertInfo alertInfo);
  void onDownloadFilesSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total);
  void onDownloadFilesFail(AlertInfo alertInfo);
  void onReDownload();
  void onTryAgainToDownload();
}

class OtherStudentTestPresenter {
  final OtherStudentTestContract? _view;
  MyTestRepository? _repository;

  OtherStudentTestPresenter(this._view) {
    _repository = Injector().getMyTestRepository();
  }

  Dio? dio;
  final Map<String, String> headers = {
    StringConstants.k_accept: 'application/json',
  };

  int _autoRequestDownloadTimes = 0;
  int get autoRequestDownloadTimes => _autoRequestDownloadTimes;
  void increaseAutoRequestDownloadTimes() {
    _autoRequestDownloadTimes += 1;
  }

  TestDetailModel? testDetail;
  List<QuestionTopicModel>? filesTopic;
  List<FileTopicModel> imageFiles = [];

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
    required String testId,
  }) {
    assert(_view != null && _repository != null);

    if (kDebugMode) {
      print('DEBUG: testId: ${testId.toString()}');
    }

    _repository!.getTestDetailWithId(testId).then((value) {
      Map<String, dynamic> json = jsonDecode(value) ?? {};
      if (kDebugMode) {
        print('DEBUG : test of other student : ${json.toString()}');
      }
      if (json.isNotEmpty) {
        if (json[StringConstants.k_error_code] == 200) {
          Map<String, dynamic> dataMap = json[StringConstants.k_data];
          TestDetailModel testDetailModel =
              TestDetailModel.fromMyTestJson(dataMap);
          testDetail = TestDetailModel.fromMyTestJson(dataMap);

          _prepareFileTopicListForDownload(testDetailModel);

          if (imageFiles.isNotEmpty) {
            //Download images
            _prepareDownloadImages(
              context: context,
              testDetail: testDetail!,
              activityId: null,
              list: filesTopic!,
            );
          } else {
            //Download video
            downloadFiles(testDetailModel, filesTopic!);
          }

          _view!.onGetMyTestSuccess(_getQuestionsAnswer(testDetailModel));
        } else {
          _view!.onGetMyTestFail(AlertClass.notResponseLoadTestAlert);
        }
      } else {
        _view!.onGetMyTestFail(AlertClass.getTestDetailAlert);
      }
    }).catchError(
        // ignore: invalid_return_type_for_catch_error

        (onError) {
      _view!.onGetMyTestFail(AlertClass.getTestDetailAlert);
    });
  }

  Future _prepareDownloadImages({
    required BuildContext context,
    String? activityId,
    required TestDetailModel testDetail,
    required List<QuestionTopicModel> list,
  }) async {
    if (null != dio) {
      int imagesDownloaded = 0;
      List<String> imageUrls = [];

      for (FileTopicModel fileTopicModel in imageFiles) {
        String url = downloadFileEP(fileTopicModel.url);
        if (!imageUrls.contains(url)) {
          imageUrls.add(url);
        }
      }

      for (String imageUrl in imageUrls) {
        await _downloadAndSaveImage(
          context,
          activityId,
          testDetail.testId.toString(),
          imageUrl,
        ).then((isDownloaded) {
          if (isDownloaded) {
            imagesDownloaded++;
            if (imagesDownloaded == imageUrls.length) {
              if (kDebugMode) {
                print('Đã tải hết ${imageUrls.length} hình ảnh');
              }
              //Start to download files (video)
              downloadFiles(
                testDetail,
                list,
              );
            }
          }
        });
      }
    } else {
      if (kDebugMode) {
        print("DEBUG: Dio is closed!");
      }
    }
  }

  Future<bool> _downloadAndSaveImage(
    BuildContext context,
    String? activityId,
    String testId,
    String imageUrl,
  ) async {
    //Add log
    LogModel log =
        await Utils.prepareToCreateLog(context, action: LogEvent.imageDownload);
    //Add more information into log
    Map<String, dynamic> imageFileDownloadInfo = {
      StringConstants.k_test_id: testId,
      StringConstants.k_image_url: imageUrl,
    };
    if (activityId != null) {
      imageFileDownloadInfo
          .addEntries([MapEntry(StringConstants.k_activity_id, activityId)]);
    }
    log.addData(
        key: "image_file_download_info",
        value: json.encode(imageFileDownloadInfo));

    try {
      String folderPath = await FileStorageHelper.getExternalDocumentPath();

      final fileName = imageUrl.split('=').last;
      final filePath = '$folderPath/$fileName';
      File file = File(filePath);

      if (await file.exists()) {
        if (kDebugMode) {
          print('Hình ảnh $fileName đã có tại: $filePath');
        }
        return true; // Trả về true khi tải thành công
      } else {
        if (kDebugMode) {
          print('Tải và lưu hình ảnh tại $filePath');
        }

        final Response response = await dio!
            .get(imageUrl, options: Options(responseType: ResponseType.bytes));
        await file.writeAsBytes(response.data);

        log.addData(key: "local_image_file_path", value: filePath);

        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message: null,
          status: LogEvent.success,
        );

        return true; // Trả về false khi có lỗi
      }
    } catch (e) {
      if (kDebugMode) {
        print('Download image file error: $e');
      }

      //Add log
      Utils.prepareLogData(
        log: log,
        data: null,
        message: 'Download image file error: $e',
        status: LogEvent.failed,
      );

      return false; // Trả về false khi có lỗi
    }
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

  void _prepareFileTopicListForDownload(TestDetailModel testDetail) {
    if (filesTopic != null) {
      if (filesTopic!.isNotEmpty) {
        filesTopic!.clear();
      }
    } else {
      filesTopic = [];
    }

    //Introduce
    filesTopic!
        .addAll(getAllFilesOfTopic(testDetail.introduce, PartOfTest.introduce));

    //Part 1
    for (int i = 0; i < testDetail.part1.length; i++) {
      TopicModel temp = testDetail.part1[i];
      filesTopic!.addAll(getAllFilesOfTopic(temp, PartOfTest.part1));
    }

    //Part 2
    filesTopic!.addAll(getAllFilesOfTopic(testDetail.part2, PartOfTest.part2));

    //Part 3
    filesTopic!.addAll(getAllFilesOfTopic(testDetail.part3, PartOfTest.part3));

    if (kDebugMode) {
      print("DEBUG: AllFiles = ${filesTopic!.length}");
    }
  }

  MediaType _mediaType(String type) {
    return (type == StringClass.audio) ? MediaType.audio : MediaType.video;
  }

  double _getPercent(int downloaded, int total) {
    return (downloaded / total);
  }

  List<QuestionTopicModel> getAllFilesOfTopic(
    TopicModel topic,
    PartOfTest partOfTest,
  ) {
    List<QuestionTopicModel> allFiles = [];

    //For Part 2 Data Error
    if (partOfTest == PartOfTest.part2) {
      if (topic.questionList.isEmpty) {
        if (kDebugMode) {
          print("DEBUG: Has no Part 2");
        }
      } else {
        allFiles = _getAllFilesOfTopic(topic, partOfTest, allFiles);
      }
    } else {
      allFiles = _getAllFilesOfTopic(topic, partOfTest, allFiles);
    }

    return allFiles;
  }

  List<QuestionTopicModel> _getAllFilesOfTopic(
    TopicModel topic,
    PartOfTest partOfTest,
    List<QuestionTopicModel> allFiles,
  ) {
    //Add all files of introduce part
    if (topic.files.isNotEmpty) {
      for (FileTopicModel file in topic.files) {
        QuestionTopicModel q = QuestionTopicModel();
        if (q.files.isEmpty) {
          q.files = [];
        }
        file.fileTopicType = FileTopicType.introduce;
        q.files.add(file);
        q.numPart = partOfTest.get;
        allFiles.add(q);

        //Add audio answer
        if (q.answers.isNotEmpty) {
          for (FileTopicModel answer in q.answers) {
            QuestionTopicModel temp = QuestionTopicModel();
            if (temp.files.isEmpty) {
              temp.files = [];
            }
            answer.fileTopicType = FileTopicType.answer;
            temp.files.add(answer);
            temp.numPart = partOfTest.get;
            allFiles.add(temp);
          }
        }
      }
    }

    //Add followup files
    if (topic.followUp.isNotEmpty) {
      for (QuestionTopicModel q in topic.followUp) {
        q.files.first.fileTopicType = FileTopicType.followup;
        q.files.first.numPart = topic.numPart;
        q.numPart = partOfTest.get;
        allFiles.add(q);

        //Add audio answer
        if (q.answers.isNotEmpty) {
          for (FileTopicModel answer in q.answers) {
            QuestionTopicModel temp = QuestionTopicModel();
            if (temp.files.isEmpty) {
              temp.files = [];
            }
            answer.fileTopicType = FileTopicType.answer;
            temp.files.add(answer);
            temp.numPart = partOfTest.get;
            allFiles.add(temp);
          }
        }
      }
    }

    //Add question files
    if (topic.questionList.isNotEmpty) {
      for (QuestionTopicModel q in topic.questionList) {
        if (q.files.isNotEmpty) {
          //Add video url
          q.files.first.fileTopicType = FileTopicType.question;
          q.files.first.numPart = topic.numPart;
          q.numPart = partOfTest.get;
          allFiles.add(q);
        }

        //Add image url
        //For question has an image
        bool hasImage = Utils.checkHasImage(question: q);
        if (hasImage) {
          imageFiles.add(q.files.elementAt(1));
        }

        //Add audio answer
        if (q.answers.isNotEmpty) {
          for (FileTopicModel answer in q.answers) {
            QuestionTopicModel temp = QuestionTopicModel();
            if (temp.files.isEmpty) {
              temp.files = [];
            }
            answer.fileTopicType = FileTopicType.answer;
            temp.files.add(answer);
            temp.numPart = partOfTest.get;
            allFiles.add(temp);
          }
        }
      }
    }

    if (topic.endOfTakeNote.url.isNotEmpty) {
      topic.endOfTakeNote.fileTopicType = FileTopicType.end_of_take_note;
      topic.endOfTakeNote.numPart = topic.numPart;
      QuestionTopicModel q = QuestionTopicModel();
      if (q.files.isEmpty) {
        q.files = [];
      }
      q.files.add(topic.endOfTakeNote);
      q.numPart = partOfTest.get;
      allFiles.add(q);
    }

    if (topic.fileEndOfTest.url.isNotEmpty) {
      topic.fileEndOfTest.fileTopicType = FileTopicType.end_of_test;
      topic.fileEndOfTest.numPart = topic.numPart;
      QuestionTopicModel q = QuestionTopicModel();
      if (q.files.isEmpty) {
        q.files = [];
      }
      q.files.add(topic.fileEndOfTest);
      q.numPart = partOfTest.get;
      allFiles.add(q);
    }
    return allFiles;
  }

  void downloadFailure(AlertInfo alertInfo) {
    _view!.onDownloadFilesFail(alertInfo);
  }

  Future downloadFiles(
      TestDetailModel testDetail, List<QuestionTopicModel> filesTopic) async {
    if (null != dio) {
      loop:
      for (int index = 0; index < filesTopic.length; index++) {
        QuestionTopicModel temp = filesTopic[index];
        String fileTopic = temp.files.first.url;
        String fileNameForDownload = Utils.reConvertFileName(fileTopic);

        if (filesTopic.isNotEmpty) {
          String fileType = Utils.fileType(fileTopic);

          if (_mediaType(fileType) == MediaType.audio) {
            fileNameForDownload = fileTopic;
            fileTopic = Utils.convertFileName(fileTopic);
          }

          if (kDebugMode) {
            print('DEBUG : download file name $fileNameForDownload');
          }

          if (fileType.isNotEmpty &&
              !await Utils.isExist(fileTopic, _mediaType(fileType))) {
            try {
              String url = downloadFileEP(fileNameForDownload);

              if (null == dio) {
                return;
              }

              dio!.head(url).timeout(const Duration(seconds: 10));
              // use client.get as you would http.get

              String savePath =
                  '${await FileStorageHelper.getFolderPath(MediaType.audio, testDetail.testId.toString())}\\$fileTopic';
              Response response = await dio!.download(url, savePath);
              if (kDebugMode) {
                print('DEBUG: Save path: $savePath');
              }

              if (response.statusCode == 200) {
                if (kDebugMode) {
                  print('DEBUG: Save Path: $savePath');
                }
                double percent = _getPercent(index + 1, filesTopic.length);
                _view!.onDownloadFilesSuccess(testDetail, fileTopic, percent,
                    index + 1, filesTopic.length);
              } else {
                _view!.onDownloadFilesFail(AlertClass.downloadVideoErrorAlert);
                reDownloadAutomatic(testDetail, filesTopic);
                break loop;
              }
            } on TimeoutException {
              _view!.onDownloadFilesFail(AlertClass.downloadVideoErrorAlert);
              reDownloadAutomatic(testDetail, filesTopic);
              break loop;
            } on SocketException {
              _view!.onDownloadFilesFail(AlertClass.downloadVideoErrorAlert);
              reDownloadAutomatic(testDetail, filesTopic);
              break loop;
            } on http.ClientException {
              _view!.onDownloadFilesFail(AlertClass.downloadVideoErrorAlert);
              reDownloadAutomatic(testDetail, filesTopic);
              break loop;
            }
          } else {
            double percent = _getPercent(index + 1, filesTopic.length);
            _view!.onDownloadFilesSuccess(
                testDetail, fileTopic, percent, index + 1, filesTopic.length);
          }
        }
      }
    } else {
      if (kDebugMode) {
        print("DEBUG: Dio is closed!");
      }
    }
  }

  void reDownloadAutomatic(
      TestDetailModel testDetail, List<QuestionTopicModel> filesTopic) {
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
