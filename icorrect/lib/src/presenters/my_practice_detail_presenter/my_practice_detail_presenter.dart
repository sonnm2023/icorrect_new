import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/my_test_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:http/http.dart' as http;

abstract class MyPracticeDetailViewContract {
  void onGetMyPracticeDetailSuccess(TestDetailModel myPracticeDetail);
  void onGetMyPracticeDetailError(String message);
}

class MyPracticeDetailPresenter {
  final MyPracticeDetailViewContract? _view;
  MyTestRepository? _repository;

  MyPracticeDetailPresenter(this._view) {
    _repository = Injector().getMyTestRepository();
  }

  void getMyPracticeDetail({
    required BuildContext context,
    required String activityId,
    required String testId,
  }) async {
    assert(_view != null && _repository != null);

    if (kDebugMode) {
      print('DEBUG: testId: ${testId.toString()}');
    }

    LogModel? log;
    Map<String, dynamic> dataLog = {};

    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiGetMyTestDetail);
    }

    bool isPracticeTest = activityId.isEmpty;

    try {
      _repository!.getMyTestDetail(testId, isPracticeTest).then((value) {
        Map<String, dynamic> json = jsonDecode(value) ?? {};
        dataLog[StringConstants.k_response] = json;
        if (kDebugMode) {
          print("DEBUG: getMyPracticeDetail $value");
        }
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

          _view!.onGetMyPracticeDetailSuccess(testDetailModel);
        } else {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: null,
            message:
                "Loading my test detail error: ${json[StringConstants.k_error_code]}${json[StringConstants.k_status]}",
            status: LogEvent.failed,
          );

          _view!.onGetMyPracticeDetailError(
              Utils.multiLanguage(StringConstants.common_error_message)!);
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

        _view!.onGetMyPracticeDetailError(
            Utils.multiLanguage(StringConstants.common_error_message)!);
      });
    } on TimeoutException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "TimeoutException",
        status: LogEvent.failed,
      );

      _view!.onGetMyPracticeDetailError(
          Utils.multiLanguage(StringConstants.common_error_message)!);
    } on SocketException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "SocketException",
        status: LogEvent.failed,
      );

      _view!.onGetMyPracticeDetailError(
          Utils.multiLanguage(StringConstants.common_error_message)!);
    } on http.ClientException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: "ClientException",
        status: LogEvent.failed,
      );

      _view!.onGetMyPracticeDetailError(
          Utils.multiLanguage(StringConstants.common_error_message)!);
    }
  }
}
