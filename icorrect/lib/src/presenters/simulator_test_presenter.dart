// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/doing_test_service.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/repositories/simulator_test_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/auth_models/video_record_exam_info.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

abstract class SimulatorTestViewContract {
  void onGetTestDetailSuccess(TestDetailModel testDetailModel, int total);
  void onGetTestDetailError(String message);
  void onDownloadSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total);
  void onDownloadError(AlertInfo info);
  void onSaveTopicListIntoProvider(List<TopicModel> list);
  void onSubmitTestSuccess(String msg);
  void onSubmitTestError(String msg);
  void onReDownload();
  void onTryAgainToDownload();
  void onHandleBackButtonSystemTapped();
  void onHandleEventBackButtonSystem({required bool isQuitTheTest});
  void onPrepareListVideoSource(List<FileTopicModel> filesTopic);
  void onUpdateHasOrderStatus(bool hasOrder);
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

  // http.Client? client;
  Dio? dio;
  final Map<String, String> headers = {
    StringConstants.k_accept: 'application/json',
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

  TestDetailModel? testDetail;
  List<FileTopicModel>? filesTopic;
  List<FileTopicModel> imageFiles = [];
  CancelToken cancelToken = CancelToken();
  bool isDownloading = false;

  //////////////////////GET TEST DETAIL FROM HOMEWORK///////////////////////////
  void getTestDetailByHomeWork({
    required BuildContext context,
    required String homeworkId,
  }) async {
    UserDataModel? currentUser = await Utils.getCurrentUser();
    if (currentUser == null) {
      _view!.onGetTestDetailError(
          StringConstants.load_detail_homework_error_message);
      return;
    }

    String distributeCode = currentUser.userInfoModel.distributorCode;

    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiGetTestDetail);
    }

    String platform = await Utils.getOS();
    String appVersion = await Utils.getAppVersion();
    String deviceId = await Utils.getDeviceIdentifier();

    _testRepository!
        .getTestDetailFromHomework(
            homeworkId: homeworkId,
            distributeCode: distributeCode,
            platform: platform,
            appVersion: appVersion,
            deviceId: deviceId)
        .then((value) async {
      Map<String, dynamic> map = jsonDecode(value);
      if (kDebugMode) {
        print(
            'DEBUG activity id : ${homeworkId.toString()}, create test : ${map.toString()}');
      }
      if (map[StringConstants.k_error_code] == 200) {
        Map<String, dynamic> dataMap = map[StringConstants.k_data];
        TestDetailModel tempTestDetailModel = TestDetailModel(testId: 0);
        tempTestDetailModel = TestDetailModel.fromJson(dataMap);
        testDetail = TestDetailModel.fromJson(dataMap);

        _prepareTopicList(tempTestDetailModel);

        //Add log
        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );

        //Save file info for re download
        filesTopic = _prepareFileTopicListForDownload(tempTestDetailModel);

        _view!.onPrepareListVideoSource(filesTopic!);

        List<FileTopicModel> tempFilesTopic =
            _prepareFileTopicListForDownload(tempTestDetailModel);

        if (imageFiles.isNotEmpty) {
          //Download images
          _prepareDownloadImages(
            context: context,
            testDetail: tempTestDetailModel,
            activityId: homeworkId,
            filesTopic: tempFilesTopic,
          );
        } else {
          //Download video
          downloadFiles(
            context: context,
            testDetail: tempTestDetailModel,
            activityId: homeworkId,
            filesTopic: tempFilesTopic,
          );
        }

        _view!.onGetTestDetailSuccess(
          tempTestDetailModel,
          tempFilesTopic.length,
        );
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message:
              "Loading homework detail error: ${map[StringConstants.k_error_code]} ${map[StringConstants.k_status]}",
          status: LogEvent.failed,
        );

        _view!.onGetTestDetailError(StringConstants.common_error_message);
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message: onError.toString(),
          status: LogEvent.failed,
        );

        _view!.onGetTestDetailError(StringConstants.common_error_message);
      },
    );
  }

  /////////////////////GET TEST DETAIL FROM PRACTICE //////////////////////////
  Future getTestDetailByPractice(
      {required BuildContext context,
      required int testOption,
      required List<int> topicsId,
      required int isPredict}) async {
    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiGetTestDetail);
    }

    _testRepository!
        .getTestDetailFromPractice(
      testOption: testOption,
      topicsId: topicsId,
      isPredict: isPredict,
    )
        .then((value) async {
      Map<String, dynamic> map = jsonDecode(value);
      if (kDebugMode) {
        print('DEBUG create practice test : ${map.toString()}');
      }
      if (map[StringConstants.k_error_code] == 200) {
        Map<String, dynamic> dataMap = map[StringConstants.k_data];
        TestDetailModel tempTestDetailModel = TestDetailModel(testId: 0);
        tempTestDetailModel = TestDetailModel.fromJson(dataMap);
        testDetail = TestDetailModel.fromJson(dataMap);

        _prepareTopicList(tempTestDetailModel);

        //Add log
        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );

        //Save file info for re download
        filesTopic = _prepareFileTopicListForDownload(tempTestDetailModel);

        _view!.onPrepareListVideoSource(filesTopic!);

        List<FileTopicModel> tempFilesTopic =
            _prepareFileTopicListForDownload(tempTestDetailModel);

        if (imageFiles.isNotEmpty) {
          //Download images
          _prepareDownloadImages(
            context: context,
            testDetail: tempTestDetailModel,
            filesTopic: tempFilesTopic,
          );
        } else {
          //Download video
          downloadFiles(
            context: context,
            testDetail: tempTestDetailModel,
            filesTopic: tempFilesTopic,
          );
        }

        _view!.onGetTestDetailSuccess(
          tempTestDetailModel,
          tempFilesTopic.length,
        );
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message:
              "Loading pratice detail error: ${map[StringConstants.k_error_code]} ${map[StringConstants.k_status]}",
          status: LogEvent.failed,
        );

        _view!.onGetTestDetailError(StringConstants.common_error_message);
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message: onError.toString(),
          status: LogEvent.failed,
        );

        _view!.onGetTestDetailError(StringConstants.common_error_message);
      },
    );
  }

  Future getTestDetailByMyPractice(
      {required BuildContext context,
      required Map<String, dynamic> data}) async {
    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiGetTestDetail);
    }

    _testRepository!
        .getTestDetailFromMyPractice(data: data)
        .then((value) async {
      Map<String, dynamic> map = jsonDecode(value);
      if (kDebugMode) {
        print('DEBUG create practice test : ${map.toString()}');
      }
      if (map[StringConstants.k_error_code] == 200) {
        Map<String, dynamic> dataMap = map[StringConstants.k_data];
        TestDetailModel tempTestDetailModel = TestDetailModel(testId: 0);
        tempTestDetailModel = TestDetailModel.fromJson(dataMap);
        testDetail = TestDetailModel.fromJson(dataMap);

        _prepareTopicList(tempTestDetailModel);

        //Add log
        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );

        //Save file info for re download
        filesTopic = _prepareFileTopicListForDownload(tempTestDetailModel);

        _view!.onPrepareListVideoSource(filesTopic!);

        List<FileTopicModel> tempFilesTopic =
            _prepareFileTopicListForDownload(tempTestDetailModel);

        if (imageFiles.isNotEmpty) {
          //Download images
          _prepareDownloadImages(
            context: context,
            testDetail: tempTestDetailModel,
            filesTopic: tempFilesTopic,
          );
        } else {
          //Download video
          downloadFiles(
            context: context,
            testDetail: tempTestDetailModel,
            filesTopic: tempFilesTopic,
          );
        }

        _view!.onGetTestDetailSuccess(
          tempTestDetailModel,
          tempFilesTopic.length,
        );
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message:
              "Loading pratice detail error: ${map[StringConstants.k_error_code]} ${map[StringConstants.k_status]}",
          status: LogEvent.failed,
        );

        _view!.onGetTestDetailError(StringConstants.common_error_message);
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message: onError.toString(),
          status: LogEvent.failed,
        );

        _view!.onGetTestDetailError(StringConstants.common_error_message);
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
    for (FileTopicModel file in topic.files) {
      file.numPart = topic.numPart;
      file.fileTopicType = FileTopicType.introduce;
      allFiles.add(file);
    }

    for (QuestionTopicModel q in topic.followUp) {
      q.files.first.fileTopicType = FileTopicType.followup;
      q.files.first.numPart = topic.numPart;
      allFiles.add(q.files.first);

      for (FileTopicModel a in q.answers) {
        a.numPart = topic.numPart;
        a.fileTopicType = FileTopicType.answer;
        allFiles.add(a);
      }
    }

    //Add question files
    for (QuestionTopicModel q in topic.questionList) {
      if (q.files.isNotEmpty) {
        //Add video url
        q.files.first.fileTopicType = FileTopicType.question;
        q.files.first.numPart = topic.numPart;
        allFiles.add(q.files.first);

        //Add image url
        //For question has an image
        bool hasImage = Utils.checkHasImage(question: q);
        if (hasImage) {
          imageFiles.add(q.files.elementAt(1));
        }
      }

      for (FileTopicModel a in q.answers) {
        a.numPart = topic.numPart;
        a.fileTopicType = FileTopicType.answer;
        allFiles.add(a);
      }
    }

    if (topic.endOfTakeNote.url.isNotEmpty) {
      topic.endOfTakeNote.fileTopicType = FileTopicType.end_of_take_note;
      topic.endOfTakeNote.numPart = topic.numPart;
      allFiles.add(topic.endOfTakeNote);
    }

    if (topic.fileEndOfTest.url.isNotEmpty) {
      topic.fileEndOfTest.fileTopicType = FileTopicType.end_of_test;
      topic.fileEndOfTest.numPart = topic.numPart;
      allFiles.add(topic.fileEndOfTest);
    }

    return allFiles;
  }

  void downloadFailure(AlertInfo alertInfo) {
    _view!.onDownloadError(alertInfo);
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
    required List<FileTopicModel> filesTopic,
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
                activityId: activityId,
                testDetail: testDetail,
                filesTopic: filesTopic,
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

  void pauseDownload() {
    if (kDebugMode) {
      print("DEBUG: Paused downloading by user");
    }
    cancelToken.cancel("Paused by user");
  }

  Future downloadFiles({
    required BuildContext context,
    String? activityId,
    required TestDetailModel testDetail,
    required List<FileTopicModel> filesTopic,
  }) async {
    if (null != dio) {
      isDownloading = true;
      loop:
      for (int index = 0; index < filesTopic.length; index++) {
        FileTopicModel temp = filesTopic[index];
        String fileTopic = temp.url;
        String fileNameForDownload = Utils.reConvertFileName(fileTopic);

        if (filesTopic.isNotEmpty) {
          String fileType = Utils.fileType(fileTopic);
          bool isExist = await FileStorageHelper.checkExistFile(
              fileTopic, MediaType.video, null);

          if (fileType.isNotEmpty && !isExist) {
            LogModel? log;
            if (context.mounted) {
              log = await Utils.prepareToCreateLog(context,
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
              String url = downloadFileEP(fileNameForDownload);

              if (kDebugMode) {
                print("DEBUG: download video: $url");
              }

              if (null == dio) {
                return;
              }

              dio!.head(url).timeout(const Duration(seconds: timeout));
              // use client.get as you would http.get

              String savePath =
                  '${await FileStorageHelper.getFolderPath(MediaType.video, null)}\\$fileTopic';

              if (kDebugMode) {
                print("DEBUG: Downloading file at index = $index");
                print("DEBUG: Save as PATH = $savePath");
              }

              Response response = await dio!.download(
                url,
                savePath,
                cancelToken: cancelToken,
              );

              if (response.statusCode == 200) {
                if (kDebugMode) {
                  print('DEBUG : save Path : $savePath');
                }

                //Add log
                Utils.prepareLogData(
                  log: log,
                  data: null,
                  message: response.statusMessage,
                  status: LogEvent.success,
                );

                double percent = _getPercent(index + 1, filesTopic.length);
                _view!.onDownloadSuccess(testDetail, fileTopic, percent,
                    index + 1, filesTopic.length);
              } else {
                if (kDebugMode) {
                  print('Download failed');
                }
                //Add log
                Utils.prepareLogData(
                  log: log,
                  data: null,
                  message: "Download failed!",
                  status: LogEvent.failed,
                );

                _view!.onDownloadError(AlertClass.downloadVideoErrorAlert);
                reDownloadAutomatic(
                    context: context,
                    activityId: activityId,
                    testDetail: testDetail,
                    filesTopic: filesTopic);
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

              _view!.onDownloadError(AlertClass.downloadVideoErrorAlert);
              reDownloadAutomatic(
                  context: context,
                  activityId: activityId,
                  testDetail: testDetail,
                  filesTopic: filesTopic);
              break loop;
            } on TimeoutException {
              if (kDebugMode) {
                print("Download File TimeoutException");
              }
              //Add log
              Utils.prepareLogData(
                log: log,
                data: null,
                message: "Download File TimeoutException",
                status: LogEvent.failed,
              );

              _view!.onDownloadError(AlertClass.downloadVideoErrorAlert);
              reDownloadAutomatic(
                  context: context,
                  activityId: activityId,
                  testDetail: testDetail,
                  filesTopic: filesTopic);
              break loop;
            } on SocketException {
              if (kDebugMode) {
                print("Download File SocketException");
              }
              //Add log
              Utils.prepareLogData(
                log: log,
                data: null,
                message: "Download File SocketException",
                status: LogEvent.failed,
              );

              _view!.onDownloadError(AlertClass.downloadVideoErrorAlert);
              //Download again
              reDownloadAutomatic(
                  context: context,
                  activityId: activityId,
                  testDetail: testDetail,
                  filesTopic: filesTopic);
              break loop;
            } on http.ClientException {
              if (kDebugMode) {
                print("Download File ClientException");
              }
              //Add log
              Utils.prepareLogData(
                log: log,
                data: null,
                message: "Download File ClientException",
                status: LogEvent.failed,
              );

              _view!.onDownloadError(AlertClass.downloadVideoErrorAlert);
              //Download again
              reDownloadAutomatic(
                  context: context,
                  activityId: activityId,
                  testDetail: testDetail,
                  filesTopic: filesTopic);
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
    String? activityId,
    required TestDetailModel testDetail,
    required List<FileTopicModel> filesTopic,
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

  void reDownloadFiles(BuildContext context, String? activityId) {
    downloadFiles(
      context: context,
      activityId: activityId,
      testDetail: testDetail!,
      filesTopic: filesTopic!,
    );
  }

  void tryAgainToDownload() async {
    if (kDebugMode) {
      print("DEBUG: SimulatorTestPresenter tryAgainToDownload");
    }

    _view!.onTryAgainToDownload();
  }

  Future<void> submitTest({
    required BuildContext context,
    required String testId,
    required String activityId,
    required List<QuestionTopicModel> questions,
    required bool isExam,
    required File? videoConfirmFile,
    required List<Map<String, dynamic>>? logAction,
  }) async {
    assert(_view != null && _testRepository != null);

    //Add log
    LogModel? log;
    Map<String, dynamic> dataLog = {};

    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiSubmitTest);
    }

    http.MultipartRequest multiRequest = await DoingTestService.formDataRequest(
      testId: testId,
      activityId: activityId,
      questions: questions,
      isUpdate: false,
      dataLog: dataLog,
      isExam: isExam,
      videoConfirmFile: videoConfirmFile,
      logAction: logAction,
    );

    if (kDebugMode) {
      print("DEBUG: submitTest");
      print("DEBUG: testId = $testId");
      print("DEBUG: activityId = $activityId");
      print("DEBUG: multirequest = ${multiRequest.toString()}");
    }

    try {
      _testRepository!.submitTest(multiRequest).then((value) {
        if (kDebugMode) {
          print("DEBUG: submit response: $value");
        }

        Map<String, dynamic> json = jsonDecode(value) ?? {};
        dataLog[StringConstants.k_response] = json;

        if (json[StringConstants.k_error_code] == 200 ||
            json[StringConstants.k_error_code] == 5013) {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: null,
            status: LogEvent.success,
          );

          bool hasOrder = false;
          if (null != json[StringConstants.k_has_order]) {
            hasOrder = json[StringConstants.k_has_order];
          }

          _view!.onUpdateHasOrderStatus(hasOrder);

          String message =
              Utils.multiLanguage(StringConstants.submit_test_success_message);
          if (json[StringConstants.k_error_code] == 5013) {
            if (!isExam) {
              message = Utils.multiLanguage(
                  StringConstants.submit_test_success_message_with_code_5013);
            }
          }

          _view!.onSubmitTestSuccess(message);
        } else {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: StringConstants.submit_test_error_message,
            status: LogEvent.failed,
          );

          String errorCode = "";
          if (json[StringConstants.k_error_code] != null) {
            errorCode = " [Error Code: ${json[StringConstants.k_error_code]}]";
          }
          _view!.onSubmitTestError(
              "${Utils.multiLanguage(StringConstants.submit_test_error_message)}\n$errorCode");
        }
      }).catchError((onError) {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: dataLog,
          message: onError.toString(),
          status: LogEvent.failed,
        );

        // ignore: invalid_return_type_for_catch_error
        _view!.onSubmitTestError(Utils.multiLanguage(
            StringConstants.submit_test_error_invalid_return_type_message));
      });
    } on TimeoutException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_timeout,
        status: LogEvent.failed,
      );

      _view!.onSubmitTestError(
          Utils.multiLanguage(StringConstants.submit_test_error_timeout));
    } on SocketException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_socket,
        status: LogEvent.failed,
      );

      _view!.onSubmitTestError(
          Utils.multiLanguage(StringConstants.submit_test_error_socket));
    } on http.ClientException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_client,
        status: LogEvent.failed,
      );

      _view!.onSubmitTestError(
          Utils.multiLanguage(StringConstants.submit_test_error_client));
    }
  }

  void handleEventBackButtonSystem({required bool isQuitTheTest}) {
    _view!.onHandleEventBackButtonSystem(isQuitTheTest: isQuitTheTest);
  }

  void handleBackButtonSystemTapped() {
    _view!.onHandleBackButtonSystemTapped();
  }
}
