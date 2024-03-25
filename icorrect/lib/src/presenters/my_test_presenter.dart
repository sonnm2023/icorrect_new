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
import 'package:icorrect/src/data_sources/repositories/my_test_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';

abstract class MyTestContract {
  void onGetMyTestSuccess(List<QuestionTopicModel> questions);
  void onDownloadSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total);
  void onDownloadFilesFail(AlertInfo alertInfo);
  void onGetMyTestFail(AlertInfo alertInfo);
  void onCountDown(String time, bool isLessThan2Seconds);
  void onFinishCountDown();
  void onUpdateAnswersSuccess(String message);
  void onUpdateAnswerFail(AlertInfo info);
  void onReDownload();
  void onTryAgainToDownload();
}

class MyTestPresenter {
  final MyTestContract? _view;
  MyTestRepository? _repository;

  MyTestPresenter(this._view) {
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
  bool isDownloading = false;
  CancelToken cancelToken = CancelToken();

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
    required String activityId,
    required String testId,
  }) async {
    assert(_view != null && _repository != null);

    if (kDebugMode) {
      print('DEBUG: activityId: ${activityId.toString()}');
      print('DEBUG: testId: ${testId.toString()}');
    }

    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiGetMyTestDetail);
    }

    bool isPracticeTest = activityId.isEmpty;

    _repository!.getMyTestDetail(testId, isPracticeTest).then((value) {
      Map<String, dynamic> json = jsonDecode(value) ?? {};
      if (kDebugMode) {
        print("DEBUG: getMyTestDetail $value");
      }
      if (json.isNotEmpty) {
        if (json[StringConstants.k_error_code] == 200) {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: null,
            status: LogEvent.success,
          );

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
              activityId: activityId,
              list: filesTopic!,
            );
          } else {
            //Download video
            downloadFiles(
              context: context,
              activityId: activityId,
              testDetail: testDetailModel,
              filesTopic: filesTopic!,
            );
          }

          _view!.onGetMyTestSuccess(_getQuestionsAnswer(testDetailModel));
        } else {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: null,
            message:
                "Loading my test detail error: ${json[StringConstants.k_error_code]}${json[StringConstants.k_status]}",
            status: LogEvent.failed,
          );

          _view!.onGetMyTestFail(AlertClass.notResponseLoadTestAlert);
        }
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message: "Loading my test detail error",
          status: LogEvent.failed,
        );

        _view!.onGetMyTestFail(AlertClass.getTestDetailAlert);
      }
    }).catchError(
        // ignore: invalid_return_type_for_catch_error
        (onError) {
      if (kDebugMode) {
        print("DEBUG: fail meomoe");
      }
      //Add log
      Utils.prepareLogData(
        log: log,
        data: null,
        message: onError.toString(),
        status: LogEvent.failed,
      );

      _view!.onGetMyTestFail(AlertClass.getTestDetailAlert);
    });
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
                context: context,
                activityId: activityId!,
                testDetail: testDetail,
                filesTopic: list,
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

  List<QuestionTopicModel> _getQuestionsAnswer(
      TestDetailModel testDetailModel) {
    List<QuestionTopicModel> questions = [];
    List<QuestionTopicModel> questionsAllAnswers = [];
    questions.addAll(testDetailModel.introduce.questionList);
    for (var q in testDetailModel.part1) {
      questions.addAll(q.questionList);
    }

    questions.addAll(testDetailModel.part2.questionList);
    if (testDetailModel.part3.followUp.isNotEmpty) {
      questions.addAll(testDetailModel.part3.followUp);
    }
    questions.addAll(testDetailModel.part3.questionList);

    for (var question in questions) {
      questionsAllAnswers.addAll(_questionsWithRepeat(question));
    }
    return questionsAllAnswers;
  }

  List<QuestionTopicModel> _questionsWithRepeat(QuestionTopicModel question) {
    List<QuestionTopicModel> repeatQuestions = [];
    List<FileTopicModel> filesAnswers = question.answers;
    for (int i = 0; i < filesAnswers.length - 1; i++) {
      QuestionTopicModel q = _genQuestionRepeat(question, i);
      repeatQuestions.add(q);
    }
    question.repeatIndex = filesAnswers.length - 1;
    repeatQuestions.add(question);
    return repeatQuestions;
  }

  QuestionTopicModel _genQuestionRepeat(
      QuestionTopicModel question, int index) {
    return question.copyWith(
        id: question.id,
        content: StringConstants.repeat_question,
        type: question.type,
        topicId: question.topicId,
        tips: question.tips,
        tipType: question.tipType,
        isFollowUp: question.isFollowUp,
        cueCard: question.cueCard,
        reAnswerCount: question.reAnswerCount,
        answers: question.answers,
        numPart: question.numPart,
        repeatIndex: index,
        files: question.files);
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

  void pauseDownload() {
    if (kDebugMode) {
      print("DEBUG: Paused downloading by user");
    }
    cancelToken.cancel("Paused by user");
  }

  Future downloadFiles({
    required BuildContext context,
    required String activityId,
    required TestDetailModel testDetail,
    required List<QuestionTopicModel> filesTopic,
  }) async {
    if (null != dio) {
      isDownloading = true;
      loop:
      for (int index = 0; index < filesTopic.length; index++) {
        QuestionTopicModel temp = filesTopic[index];
        String fileTopic = temp.files.first.url;
        String fileNameForDownload = Utils.reConvertFileName(fileTopic);

        if (filesTopic.isNotEmpty) {
          LogModel? log;
          if (context.mounted) {
            log = await Utils.prepareToCreateLog(context,
                action: LogEvent.callApiDownloadFile);
            Map<String, dynamic> fileDownloadInfo = {
              StringConstants.k_test_id: testDetail.testId.toString(),
              StringConstants.k_file_name: fileTopic,
              StringConstants.k_file_path: downloadFileEP(fileNameForDownload),
            };

            if (activityId.isNotEmpty) {
              fileDownloadInfo.addEntries(
                  [MapEntry(StringConstants.k_activity_id, activityId)]);
            }
            log.addData(
                key: StringConstants.k_file_download_info,
                value: json.encode(fileDownloadInfo));
          }

          String fileType = Utils.fileType(fileTopic);

          if (_mediaType(fileType) == MediaType.audio) {
            fileNameForDownload = fileTopic;
            fileTopic = Utils.convertFileName(fileTopic);
          }

          if (fileType.isNotEmpty &&
              !await Utils.isExist(fileTopic, _mediaType(fileType))) {
            String url = downloadFileEP(fileNameForDownload);

            try {
              if (null == dio) {
                return;
              }

              dio!.head(url).timeout(const Duration(seconds: 10));

              String savePath =
                  '${await FileStorageHelper.getFolderPath(_mediaType(fileType), null)}\\$fileTopic';

              if (kDebugMode) {
                print("Debug : url: $url , fileTopic : $fileTopic");
                print("Save Path: $savePath");
              }

              Response response = await dio!.download(url, savePath);
              if (response.statusCode == 200) {
                double percent = _getPercent(index + 1, filesTopic.length);

                //Add log
                Utils.prepareLogData(
                  log: log,
                  data: null,
                  message: response.statusMessage,
                  status: LogEvent.success,
                );

                _view!.onDownloadSuccess(testDetail, fileTopic, percent,
                    index + 1, filesTopic.length);
              } else {
                //Add log
                Utils.prepareLogData(
                  log: log,
                  data: null,
                  message: "Download failed!",
                  status: LogEvent.failed,
                );

                _view!.onDownloadFilesFail(AlertClass.downloadVideoErrorAlert);
                reDownloadAutomatic(
                  context: context,
                  activityId: activityId,
                  testDetail: testDetail,
                  filesTopic: filesTopic,
                );
                break loop;
              }
            } on DioException catch (e) {
              if (kDebugMode) {
                print(
                    "DEBUG: Download error: ${e.type} - message: ${e.message}");
              }

              //Add log
              Utils.prepareLogData(
                log: log,
                data: null,
                message: "Error type: ${e.type} - message: ${e.message}",
                status: LogEvent.failed,
              );

              _view!.onDownloadFilesFail(AlertClass.downloadVideoErrorAlert);
              reDownloadAutomatic(
                context: context,
                activityId: activityId,
                testDetail: testDetail,
                filesTopic: filesTopic,
              );
              break loop;
            } on TimeoutException {
              //Add log
              Utils.prepareLogData(
                log: log,
                data: null,
                message: "Download File TimeoutException",
                status: LogEvent.failed,
              );

              _view!.onDownloadFilesFail(AlertClass.downloadVideoErrorAlert);
              reDownloadAutomatic(
                context: context,
                activityId: activityId,
                testDetail: testDetail,
                filesTopic: filesTopic,
              );
              break loop;
            } on SocketException {
              //Add log
              Utils.prepareLogData(
                log: log,
                data: null,
                message: "Download File SocketException",
                status: LogEvent.failed,
              );

              _view!.onDownloadFilesFail(AlertClass.downloadVideoErrorAlert);
              reDownloadAutomatic(
                context: context,
                activityId: activityId,
                testDetail: testDetail,
                filesTopic: filesTopic,
              );
              break loop;
            } on http.ClientException {
              //Add log
              Utils.prepareLogData(
                log: log,
                data: null,
                message: "Download File ClientException",
                status: LogEvent.failed,
              );

              _view!.onDownloadFilesFail(AlertClass.downloadVideoErrorAlert);
              reDownloadAutomatic(
                context: context,
                activityId: activityId,
                testDetail: testDetail,
                filesTopic: filesTopic,
              );
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
      isDownloading = false;
      if (kDebugMode) {
        print("DEBUG: Dio is closed!");
      }
    }
  }

  void reDownloadAutomatic({
    required BuildContext context,
    required String activityId,
    required TestDetailModel testDetail,
    required List<QuestionTopicModel> filesTopic,
  }) {
    isDownloading = false;
    //Download again
    if (autoRequestDownloadTimes <= 3) {
      if (kDebugMode) {
        print("DEBUG: request to download in times: $autoRequestDownloadTimes");
      }
      downloadFiles(
        context: context,
        activityId: activityId,
        testDetail: testDetail,
        filesTopic: filesTopic,
      );
      increaseAutoRequestDownloadTimes();
    } else {
      //Close old download request
      closeClientRequest();
      _view!.onReDownload();
    }
  }

  Timer startCountDown({
    required BuildContext context,
    required int count,
    required bool isLessThan2Seconds,
  }) {
    int temp = count;
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

      if ((temp - count) >= 2) {
        isLessThan2Seconds = false;
      }

      _view!.onCountDown("$minuteStr:$secondStr", isLessThan2Seconds);

      if (count == 0 && !finishCountDown) {
        finishCountDown = true;
        _view!.onFinishCountDown();
      }
    });
  }

  Future updateMyAnswer({
    required BuildContext context,
    required String testId,
    required String activityId,
    required List<QuestionTopicModel> reQuestions,
  }) async {
    assert(_view != null && _repository != null);

    //Add log
    LogModel? log;
    Map<String, dynamic> dataLog = {};

    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiUpdateMyAnswer);
    }

    http.MultipartRequest multiRequest = await _formDataRequest(
      testId: testId,
      activityId: activityId,
      questions: reQuestions,
      dataLog: dataLog,
    );

    try {
      _repository!.updateAnswers(multiRequest).then((value) {
        Map<String, dynamic> json = jsonDecode(value) ?? {};
        dataLog[StringConstants.k_response] = json;

        if (kDebugMode) {
          print("DEBUG: error form: ${json.toString()}");
        }
        if (json[StringConstants.k_error_code] == 200 &&
            json[StringConstants.k_status] == 'success') {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: null,
            status: LogEvent.success,
          );

          _view!.onUpdateAnswersSuccess(Utils.multiLanguage(
              StringConstants.save_answer_success_message)!);
        } else {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: StringConstants.update_answer_error_message,
            status: LogEvent.failed,
          );

          _view!.onUpdateAnswerFail(AlertClass.errorWhenUpdateAnswer(
              StringConstants.update_answer_error_message));
        }
      }).catchError((onError) {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: dataLog,
          message: onError.toString(),
          status: LogEvent.failed,
        );

        _view!.onUpdateAnswerFail(AlertClass.errorWhenUpdateAnswer(
            StringConstants.update_answer_error_message));
      });
    } on TimeoutException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "TimeoutException: Has an error when update my answer!",
        status: LogEvent.failed,
      );

      _view!.onUpdateAnswerFail(AlertClass.timeOutUpdateAnswer);
    } on SocketException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "SocketException: Has an error when update my answer!",
        status: LogEvent.failed,
      );

      _view!.onUpdateAnswerFail(AlertClass.errorWhenUpdateAnswer(
          "SocketException: Has an error when update my answer!"));
    } on http.ClientException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "ClientException: Has an error when update my answer!",
        status: LogEvent.failed,
      );

      _view!.onUpdateAnswerFail(AlertClass.errorWhenUpdateAnswer(
          "ClientException: Has an error when update my answer!"));
    }
  }

  Future<http.MultipartRequest> _formDataRequest({
    required String testId,
    required String activityId,
    required List<QuestionTopicModel> questions,
    required Map<String, dynamic>? dataLog,
  }) async {
    String url = submitHomeWorkV2EP();
    if (activityId.isEmpty) {
      url = submitPractice();
    }
    http.MultipartRequest request =
        http.MultipartRequest(RequestMethod.post, Uri.parse(url));
    request.headers.addAll({
      StringConstants.k_content_type: 'multipart/form-data',
      StringConstants.k_authorization: 'Bearer ${await Utils.getAccessToken()}'
    });

    Map<String, String> formData = {};

    formData.addEntries([MapEntry(StringConstants.k_test_id, testId)]);
    if (activityId.isNotEmpty) {
      formData.addEntries(const [MapEntry(StringConstants.k_is_update, '1')]);
      formData
          .addEntries([MapEntry(StringConstants.k_activity_id, activityId)]);
    }

    if (Platform.isAndroid) {
      formData.addEntries([const MapEntry(StringConstants.k_os, "android")]);
    } else {
      formData.addEntries([const MapEntry(StringConstants.k_os, "ios")]);
    }

    String appVersion = await Utils.getAppVersion();
    formData.addEntries([MapEntry(StringConstants.k_app_version, appVersion)]);

    String format = '';
    String reanswerFormat = '';
    String endFormat = '';
    for (QuestionTopicModel q in questions) {
      String questionId = q.id.toString();
      if (kDebugMode) {
        print("DEBUG: num part : ${q.numPart.toString()}");
      }
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
        String fileName =
            Utils.convertFileName(q.answers.elementAt(i).url.toString());
        File audioFile = File(await FileStorageHelper.getFilePath(
            fileName, MediaType.audio, null));

        if (await audioFile.exists()) {
          request.files.add(
              await http.MultipartFile.fromPath(endFormat, audioFile.path));
          //  formData.addEntries([MapEntry(endFormat, audioFile.path)]);
        }
      }
    }

    if (kDebugMode) {
      print("DEBUG : form Data update submit : ${formData.toString()}");
    }

    request.fields.addAll(formData);

    if (null != dataLog) {
      dataLog[StringConstants.k_request_data] = formData.toString();
    }

    return request;
  }

  void tryAgainToDownload() async {
    if (kDebugMode) {
      print("DEBUG: MyTestPresenter tryAgainToDownload");
    }

    _view!.onTryAgainToDownload();
  }

  void reDownloadFiles(BuildContext context, String activityId) {
    downloadFiles(
      context: context,
      activityId: activityId,
      testDetail: testDetail!,
      filesTopic: filesTopic!,
    );
  }
}
