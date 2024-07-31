import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:icorrect/src/models/module_lession_models/lesson_model.dart';

import '../data_sources/api_urls.dart';
import '../data_sources/constants.dart';
import '../data_sources/local/file_storage_helper.dart';
import '../data_sources/utils.dart';
import '../models/log_models/log_model.dart';
import '../models/ui_models/alert_info.dart';

abstract class MissionTestViewContract {
  void onDownloadSuccess(String nameFile,double percent, int index, int total);
  void onDownloadError(AlertInfo info);
  void onReDownload();
  void onTryAgainToDownload();
  void onCounting(String strCount, int count);
}

class MissionTestPresenter {
  final MissionTestViewContract? _view;

  MissionTestPresenter(this._view);

  Dio? dio;
  final Map<String, String> headers = {
    StringConstants.k_accept: 'application/json',
  };

  int index = 0;
  int total = 0;

  bool isDownloading = false;

  int _autoRequestDownloadTimes = 0;
  int get autoRequestDownloadTimes => _autoRequestDownloadTimes;
  void increaseAutoRequestDownloadTimes() {
    _autoRequestDownloadTimes += 1;
  }

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

  Future<bool> _downloadAndSaveImage(
      BuildContext context,
      String? activityId,
      String imageUrl,
      ) async {
    //Add log
    LogModel log =
    await Utils.prepareToCreateLog(context, action: LogEvent.imageDownload);
    //Add more information into log
    Map<String, dynamic> imageFileDownloadInfo = {
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
        index += 1;
        _view!.onDownloadSuccess(filePath, _getPercent(index,total), index, total);
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
        index += 1;
        _view!.onDownloadSuccess(filePath, _getPercent(index,total), index, total);

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

  void prepareDataForDownload({
    required BuildContext context,
    required String? activityId,
    required FileElement fileVideo,
    FileElement? fileImage
  }) {
    if (kDebugMode) {
      print("DEBUG: prepareDataForDownload");
    }
    index = 0;
    total = 0;

    if (fileImage != null) {
      //Download images
      total = 2;
      prepareDownloadImages(
        context: context,
        activityId: activityId,fileVideo: fileVideo, fileImage: fileImage,
      );
    } else {
      total = 1;
      //Download video
      downloadFiles(
        context: context,
        activityId: activityId,
        fileVideo: fileVideo
      );
    }
  }

  Future prepareDownloadImages({
    required BuildContext context,
    String? activityId,
    required FileElement fileVideo,
    required FileElement fileImage,
  }) async {
    String url = '';
    if (null != dio) {
      url = downloadFileEP(fileImage.url!);

      await _downloadAndSaveImage(
        context,
        activityId,
        url,
      ).then((isDownloaded) {
        if (isDownloaded) {
          //Start to download files (video)
          downloadFiles(
              context: context, activityId: activityId, fileVideo: fileVideo);
        }
      });
    } else {
      if (kDebugMode) {
        print("DEBUG: Dio is closed!");
      }
    }
  }

  Future downloadFiles({
    required BuildContext context,
    String? activityId,
    required FileElement fileVideo,
  }) async {
    if (null != dio) {
      isDownloading = true;
        String fileTopic = fileVideo.url!;
        String fileNameForDownload = Utils.reConvertFileName(fileTopic);

          String fileType = Utils.fileType(fileTopic);
          bool isExist = await FileStorageHelper.checkExistFile(
              fileTopic, MediaType.video, null);

          if (fileType.isNotEmpty && !isExist) {
            LogModel? log;
            if (context.mounted) {
              log = await Utils.prepareToCreateLog(context,
                  action: LogEvent.callApiDownloadFile);
              Map<String, dynamic> fileDownloadInfo = {
                // StringConstants.k_test_id: testDetail.testId.toString(),
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

              dio!.head(url).timeout(const Duration(seconds: TIME_OUT));
              // use client.get as you would http.get

              String savePath =
                  '${await FileStorageHelper.getFolderPath(MediaType.video, null)}\\$fileTopic';

              if (kDebugMode) {
                // print("DEBUG: Downloading file at index = $index");
                print("DEBUG: Save as PATH = $savePath");
              }

              Response response = await dio!.download(
                url,
                savePath,
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
                index += 1;

                double percent = _getPercent(index, total);
                _view!.onDownloadSuccess(fileTopic, percent, index, total);
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
                    fileVideo: fileVideo);
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
                  fileVideo: fileVideo);
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
                  fileVideo: fileVideo);
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
                  fileVideo: fileVideo);
            }
            // on http.ClientException {
            //   if (kDebugMode) {
            //     print("Download File ClientException");
            //   }
            //   //Add log
            //   Utils.prepareLogData(
            //     log: log,
            //     data: null,
            //     message: "Download File ClientException",
            //     status: LogEvent.failed,
            //   );
            //
            //   _view!.onDownloadError(AlertClass.downloadVideoErrorAlert);
            //   //Download again
            //   reDownloadAutomatic(
            //       context: context,
            //       activityId: activityId,
            //       testDetail: testDetail,
            //       list: list);
            // }
          }
          else {
            index += 1;
            double percent = _getPercent(index, total);
            _view!.onDownloadSuccess(fileTopic, percent, index, total);
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
  required FileElement fileVideo
  }) {
  isDownloading = false;

  //Download again
  if (autoRequestDownloadTimes <= 3) {
    if (kDebugMode) {
      print("DEBUG: request to download in times: $autoRequestDownloadTimes");
    }
    downloadFiles(
      context: context,
      activityId: activityId, fileVideo: fileVideo,
    );
    increaseAutoRequestDownloadTimes();
  } else {
    //Close old download request
    closeClientRequest();
    _view!.onReDownload();
  }
  }

  double _getPercent(int downloaded, int total) {
  return (downloaded / 2);
  }

  Timer startCounting({required BuildContext context, required int count}) {
    assert(_view != null);
    const oneSec = Duration(seconds: 1);
    return Timer.periodic(oneSec, (Timer timer) {
      if (count < 0) {
        timer.cancel();
      } else {
        count = count + 1;
      }
      dynamic minutes = count ~/ 60;
      dynamic seconds = count % 60;

      dynamic minuteStr = minutes.toString().padLeft(2, '0');
      dynamic secondStr = seconds.toString().padLeft(2, '0');

      _view!.onCounting("$minuteStr:$secondStr", count);

      if (count == 0) {
        timer.cancel();
      }
    });
  }
}