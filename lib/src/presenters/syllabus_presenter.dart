import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:icorrect_pc/src/data_source/local/database_helper.dart';
import 'package:icorrect_pc/src/models/homework_models/syllabusDB_model.dart';

import '../data_source/api_urls.dart';
import '../data_source/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:icorrect_pc/src/models/homework_models/syllabus_file_model.dart';
import '../data_source/dependency_injection.dart';
import '../data_source/local/file_storage_helper.dart';
import '../data_source/repositories/homework_repository.dart';
import '../models/homework_models/syllabus_merchant_model.dart';
import '../models/log_models/log_model.dart';
import '../utils/utils.dart';

abstract class SyllabusViewContract {
  void onGetListSyllabusComplete(List<Syllabus> syllabus, int total);
  void onGetListSyllabusError(String message);
  void onGetListFileComplete(int total);
  void onGetListFileError(String msg);
  void onDownloadSuccess(int index,int to, int total, int totalCapacity);
  void onDownloadError(String msg);
  void onInsertSyllabusToDBComplete();
  void onInsertSyllabusToDBError(String msg);
  void onGetListSyllabusDBComplete(List<SyllabusDBModel> list);
  void onGetListSyllabusDBError(String msg);
}

class SyllabusPresenter {
  final SyllabusViewContract? _view;
  HomeWorkRepository? _homeWorkRepository;

  SyllabusPresenter(this._view) {
    _homeWorkRepository = Injector().getHomeWorkRepository();
  }


  int _autoRequestDownloadTimes = 0;

  int get autoRequestDownloadTimes => _autoRequestDownloadTimes;

  void increaseAutoRequestDownloadTimes() {
    _autoRequestDownloadTimes += 1;
  }

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

  void getListSyllabusMerchant(BuildContext context, int page) async {
    assert(_view != null && _homeWorkRepository != null);
    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiGetListSyllabus);
    }
    try {
      String? merchantId = await Utils.instance().getMerchantID();
      String checksum = await Utils.instance().convertHMacSha256(param1: merchantId, param2: page.toString());
      print(merchantId);
      print(checksum);
      _homeWorkRepository!.getSyllabusMerchant(merchantId!, checksum, page).then((value) async {
        print(value);
        SyllabusMerchantModel model = SyllabusMerchantModel.fromJson(jsonDecode(value));
        if(model.errorCode == 200) {
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: null,
            status: LogEvent.success,
          );
          _view!.onGetListSyllabusComplete(model.data!.data!.data!, model.data!.data!.total!);
        } else {
          _view!.onGetListSyllabusError(model.data!.message!);
        }
      }).catchError(
        // ignore: invalid_return_type_for_catch_error
            (onError) {
          Utils.instance().prepareLogData(
            log: log,
            data: null,
            message: onError.toString(),
            status: LogEvent.failed,
          );
          if (kDebugMode) {
            print("DEBUG:onGetListSyllabusError - ${onError.toString()} ");
          }
          _view!.onGetListSyllabusError(Utils.instance()
              .multiLanguage(StringConstants.network_error_message));
        },
      );
    } on TimeoutException {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: StringConstants.time_out_error_message,
        status: LogEvent.failed,
      );
      _view!.onGetListSyllabusError(Utils.instance()
          .multiLanguage(StringConstants.time_out_error_message));
    } on http.ClientException {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: StringConstants.client_error_message,
        status: LogEvent.failed,
      );
      _view!.onGetListSyllabusError(
          Utils.instance().multiLanguage(StringConstants.client_error_message));
    } on SocketException {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: StringConstants.socket_error_message,
        status: LogEvent.failed,
      );
      _view!.onGetListSyllabusError(
          Utils.instance().multiLanguage(StringConstants.socket_error_message));
    }
  }

  void insertListSyllabusToDB(List<Syllabus> list) async {
    try {
      List<SyllabusDBModel>? listDB = await DatabaseHelper.getListSyllabus();
      List<String> listSyllabusDBName = [];
      if (listDB != null) {
        listSyllabusDBName = listDB.map((e) => e.syllabusName,).toList();
      }
      for (Syllabus syllabus in list) {
        if (!listSyllabusDBName.contains(syllabus.name)) {
              SyllabusDBModel syllabusDBModel = SyllabusDBModel(
                  syllabusID: syllabus.id!,
                  syllabusName: syllabus.name!,
                  totalDownloaded: 0,
                  capacity: 0,
                  statusDownload: 0,
                  updateAt: syllabus.updatedAt!,
                  downloadAt: null);
              await DatabaseHelper.addSyllabus(syllabusDBModel);
            } else {
          for (SyllabusDBModel syllabusDB in listDB!) {
            if (syllabusDB.syllabusName == syllabus.name) {
              if (syllabus.updatedAt != syllabusDB.updateAt) {
                // await DatabaseHelper.updateTotalSyllabus(syllabus.questions!, syllabus.name!);
                await DatabaseHelper.updateUpdateAtSyllabus(syllabus.updatedAt!.toIso8601String(), syllabus.name!);
              }
            }
          }
            }
      }
      _view!.onInsertSyllabusToDBComplete();
    } on Exception {
      _view!.onInsertSyllabusToDBError('thêm giáo trình vào database thất bại');
    }
  }

  void getAllSyllabusInDB() async {
    try {
      List<SyllabusDBModel>? list = await DatabaseHelper.getListSyllabus();
      _view!.onGetListSyllabusDBComplete(list!);
    } catch (e) {
      _view!.onGetListSyllabusDBError('Danh sách giáo trình trống!');
    }
  }

  void deleteSyllabus(String syllabusName) async {
    await DatabaseHelper.deleteSyllabus(syllabusName);
    List<SyllabusDBModel>? list = await DatabaseHelper.getListSyllabus();
    if (list != null) {
      _view!.onGetListSyllabusDBComplete(list);
    } else {
      _view!.onGetListSyllabusDBComplete([]);
    }
  }

  List<Datum> list = [];
  int totalCapacity = 0;

  void getListFileSyllabus(BuildContext context, int id, int page, String syllabusName) async {
    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiGetListFileSyllabus);
    }

    String? merchantID = await Utils.instance().getMerchantID();
    String checksum = await Utils.instance().convertHMacSha256(param1: merchantID, param2: page.toString());
    _homeWorkRepository!.getFilesSyllabus(id, page, merchantID!, checksum).then((value) {
      SyllabusFileModel model = SyllabusFileModel.fromJson(jsonDecode(value));
      if (model.errorCode == 200) {
        list += model.data!.data!;
        downloadFiles(context, list,model.data!.from! - 1, model.data!.to!, model.data!.total!, syllabusName);
        Utils.instance().prepareLogData(
          log: log,
          data: null,
          message: model.messages!,
          status: LogEvent.success,
        );
        _view!.onGetListFileComplete(model.data!.total!);
      } else {
        Utils.instance().prepareLogData(
          log: log,
          data: null,
          message: model.messages ?? model.errorCode!.toString(),
          status: LogEvent.failed,
        );
        _view!.onGetListFileError(value);
      }
    },).catchError((onError) {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: onError.toString(),
        status: LogEvent.failed,
      );
      _view!.onGetListFileError(onError.toString());
    });
  }

  Future downloadFiles(BuildContext context,
      List<Datum> filesTopic,int from, int to, int total, String syllabusName) async {
    if (null != dio) {
      loop:
      for (from; from < filesTopic.length; from++) {
        Datum temp = filesTopic[from];
        String fileTopic = temp.url!;
        String fileNameForDownload = Utils.instance().reConvertFileName(fileTopic);
        String savePath = '';

        if (filesTopic.isNotEmpty) {
          String fileType = Utils.instance().fileType(fileTopic);
          MediaType mediaType = Utils.instance().mediaType(fileTopic);
          fileTopic = Utils.instance().convertFileName(fileTopic);
          bool isExist = await FileStorageHelper.newCheckExistFile(
              fileTopic, mediaType);
          savePath =
          '${await FileStorageHelper.getFolderSyllabusPath(mediaType, syllabusName)}\\$fileTopic';
          if (fileType.isNotEmpty && !isExist) {
            LogModel? log;
            try {
              if (kDebugMode) {
                print("DEBUG: Downloading file at index = $from");
              }

              if (dio == null) {
                _view!.onDownloadError('Dio null');
                return;
              }
              String url = downloadFileEP(fileNameForDownload);
              dio!.head(url).timeout(const Duration(seconds: 20));
              if (kDebugMode) {
                print('DEBUG DOWNLOAD FILE: START DOWNLOAD FILE $url');
              }
              //add savePath to list with status false
              // _view!.onDownloadError();

              Response response = await dio!.download(url, savePath);
              if (response.statusCode == 200) {
                int contentLength = int.parse(response.headers['content-length']![0]);
                totalCapacity += contentLength;
                //Add log
                Utils.instance().prepareLogData(
                  log: log,
                  data: null,
                  message: response.statusMessage,
                  status: LogEvent.success,
                );
                _view!.onDownloadSuccess(from,to, total, totalCapacity);
                if (from == total - 1) {
                  list.clear();
                  totalCapacity = 0;
                }
                if (from == to - 1) {
                  break loop;
                }
              } else {
                //Add log
                Utils.instance().prepareLogData(
                  log: log,
                  data: null,
                  message: "Download failed!",
                  status: LogEvent.failed,
                );
                _view!.onDownloadError('Download fail');
                break loop;
              }
            } on DioException {
              _view!.onDownloadError('Dio exception');
              break loop;
            }
          } else {
            _view!.onDownloadSuccess(from,to, total, totalCapacity);
            if (from == total - 1) {
              list.clear();
            }
            if (from == to -1) {
              break loop;
            }
          }
        }
      }
    } else {
      if (kDebugMode) {
        print("DEBUG: client is closed!");
      }
    }
  }
}