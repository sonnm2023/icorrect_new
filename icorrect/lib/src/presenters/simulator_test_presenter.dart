// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import 'package:path_provider/path_provider.dart';

abstract class SimulatorTestViewContract {
  void onGetTestDetailComplete(TestDetailModel testDetailModel, int total);
  void onGetTestDetailError(String message);
  void onDownloadSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total);
  void onDownloadFailure(AlertInfo info);
  void onSaveTopicListIntoProvider(List<TopicModel> list);
  void onSubmitTestSuccess(String msg);
  void onSubmitTestFail(String msg);
  void onReDownload();
  void onTryAgainToDownload();
  void onHandleBackButtonSystemTapped();
  void onHandleEventBackButtonSystem({required bool isQuitTheTest});
  void onPrepareListVideoSource(List<FileTopicModel> filesTopic);
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
    'Accept': 'application/json',
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

  void getTestDetail({
    required BuildContext context,
    required String homeworkId,
  }) async {
    UserDataModel? currentUser = await Utils.getCurrentUser();
    if (currentUser == null) {
      _view!.onGetTestDetailError("Loading homework detail error!");
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
        .getTestDetail(
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
      if (map['error_code'] == 200) {
        Map<String, dynamic> dataMap = map['data'];
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

        _view!.onGetTestDetailComplete(
            tempTestDetailModel, tempFilesTopic.length);
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message:
              "Loading homework detail error: ${map['error_code']}${map['status']}",
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
    _view!.onDownloadFailure(alertInfo);
  }

  Future<bool> _downloadAndSaveImage(
    BuildContext context,
    String activityId,
    String testId,
    String imageUrl,
  ) async {
    //Add log
    LogModel log =
        await Utils.prepareToCreateLog(context, action: LogEvent.imageDownload);
    //Add more information into log
    Map<String, dynamic> imageFileDownloadInfo = {
      "activity_id": activityId,
      "test_id": testId,
      "image_url": imageUrl,
    };
    log.addData(
        key: "image_file_download_info",
        value: json.encode(imageFileDownloadInfo));

    try {
      final directory = await getApplicationDocumentsDirectory();

      final isExistFolder = await directory.exists();
      if (!isExistFolder) {
        await directory.create(recursive: true);
      }

      final fileName = imageUrl.split('=').last;
      final filePath = '${directory.path}/$fileName';
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
    required String activityId,
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

  Future downloadFiles({
    required BuildContext context,
    required String activityId,
    required TestDetailModel testDetail,
    required List<FileTopicModel> filesTopic,
  }) async {
    if (null != dio) {
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
                "activity_id": activityId,
                "test_id": testDetail.testId.toString(),
                "file_name": fileTopic,
                "file_path": downloadFileEP(fileNameForDownload),
              };
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

              Response response = await dio!.download(url, savePath);

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
                //Add log
                Utils.prepareLogData(
                  log: log,
                  data: null,
                  message: "Download failed!",
                  status: LogEvent.failed,
                );

                _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert);
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

              _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert);
              reDownloadAutomatic(
                  context: context,
                  activityId: activityId,
                  testDetail: testDetail,
                  filesTopic: filesTopic);
              break loop;
            } on TimeoutException {
              //Add log
              Utils.prepareLogData(
                log: log,
                data: null,
                message: "Download File TimeoutException",
                status: LogEvent.failed,
              );

              _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert);
              reDownloadAutomatic(
                  context: context,
                  activityId: activityId,
                  testDetail: testDetail,
                  filesTopic: filesTopic);
              break loop;
            } on SocketException {
              //Add log
              Utils.prepareLogData(
                log: log,
                data: null,
                message: "Download File SocketException",
                status: LogEvent.failed,
              );

              _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert);
              //Download again
              reDownloadAutomatic(
                  context: context,
                  activityId: activityId,
                  testDetail: testDetail,
                  filesTopic: filesTopic);
              break loop;
            } on http.ClientException {
              //Add log
              Utils.prepareLogData(
                log: log,
                data: null,
                message: "Download File ClientException",
                status: LogEvent.failed,
              );

              _view!.onDownloadFailure(AlertClass.downloadVideoErrorAlert);
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
      if (kDebugMode) {
        print("DEBUG: Dio is closed!");
      }
    }
  }

  void reDownloadAutomatic({
    required BuildContext context,
    required String activityId,
    required TestDetailModel testDetail,
    required List<FileTopicModel> filesTopic,
  }) {
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

  void reDownloadFiles(BuildContext context, String activityId) {
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

    http.MultipartRequest multiRequest = await _formDataRequest(
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
    }

    try {
      _testRepository!.submitTest(multiRequest).then((value) {
        if (kDebugMode) {
          print("DEBUG: submit response: $value");
        }

        Map<String, dynamic> json = jsonDecode(value) ?? {};
        dataLog['response'] = json;

        if (json['error_code'] == 200) {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: null,
            status: LogEvent.success,
          );

          _view!.onSubmitTestSuccess('Save your answers successfully!');
        } else {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: "Has an error when submit this test!",
            status: LogEvent.failed,
          );

          _view!.onSubmitTestFail("Has an error when submit this test!");
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
        _view!.onSubmitTestFail(
            "invalid_return_type_for_catch_error: Has an error when submit this test!");
      });
    } on TimeoutException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "TimeoutException: Has an error when submit this test!",
        status: LogEvent.failed,
      );

      _view!.onSubmitTestFail(
          "TimeoutException: Has an error when submit this test!");
    } on SocketException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "SocketException: Has an error when submit this test!",
        status: LogEvent.failed,
      );

      _view!.onSubmitTestFail(
          "SocketException: Has an error when submit this test!");
    } on http.ClientException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "ClientException: Has an error when submit this test!",
        status: LogEvent.failed,
      );

      _view!.onSubmitTestFail(
          "ClientException: Has an error when submit this test!");
    }
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

  Future<http.MultipartRequest> _formDataRequest({
    required String testId,
    required String activityId,
    required List<QuestionTopicModel> questions,
    required bool isUpdate,
    required Map<String, dynamic>? dataLog,
    required bool isExam,
    required File? videoConfirmFile,
    required List<Map<String, dynamic>>? logAction,
  }) async {
    String url = submitHomeWorkV2EP();

    if (isExam) {
      url = submitExam();
    }

    http.MultipartRequest request =
        http.MultipartRequest(RequestMethod.post, Uri.parse(url));
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${await Utils.getAccessToken()}'
    });

    Map<String, String> formData = {};

    formData.addEntries([MapEntry('test_id', testId)]);
    formData.addEntries([MapEntry('activity_id', activityId)]);
    formData.addEntries([MapEntry('is_update', isUpdate ? '1' : '0')]);

    if (Platform.isAndroid) {
      formData.addEntries([const MapEntry('os', "android")]);
    } else {
      formData.addEntries([const MapEntry('os', "ios")]);
    }
    String appVersion = await Utils.getAppVersion();
    formData.addEntries([MapEntry('app_version', appVersion)]);

    if (null != logAction) {
      if (logAction.isNotEmpty) {
        formData.addEntries([MapEntry('log_action', jsonEncode(logAction))]);
      } else {
        formData.addEntries([const MapEntry('log_action', '[]')]);
      }
    }

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

      // For test: don't send answers
      for (int i = 0; i < q.answers.length; i++) {
        String path = await FileStorageHelper.getFilePath(
            q.answers.elementAt(i).url.toString(), MediaType.audio, testId);
        File audioFile = File(path);

        if (await audioFile.exists()) {
          request.files.add(
              await http.MultipartFile.fromPath("$prefix[$i]", audioFile.path));
        }
      }
    }

    if (null != videoConfirmFile) {
      String fileName = videoConfirmFile.path.split('/').last;
      formData.addEntries([MapEntry('video_confirm', fileName)]);
      request.files.add(await http.MultipartFile.fromPath(
          'video_confirm', videoConfirmFile.path));
    }

    request.fields.addAll(formData);

    if (null != dataLog) {
      dataLog['request_data'] = formData.toString();
    }

    return request;
  }

  void handleEventBackButtonSystem({required bool isQuitTheTest}) {
    _view!.onHandleEventBackButtonSystem(isQuitTheTest: isQuitTheTest);
  }

  void handleBackButtonSystemTapped() {
    _view!.onHandleBackButtonSystemTapped();
  }
}
