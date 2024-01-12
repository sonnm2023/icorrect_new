import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/simulator_test_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';

abstract class MyPracticeSettingViewContract {
  void onGetTestDetailSuccess(TestDetailModel testDetailModel);
  void onGetTestDetailError(String message);
}

class MyPracticeSettingPresenter {
  final MyPracticeSettingViewContract? _view;
  SimulatorTestRepository? _repository;
  TestDetailModel? testDetail;

  MyPracticeSettingPresenter(this._view) {
    _repository = Injector().getTestRepository();
  }

  Future getTestDetailFromMyPractice(
      {required BuildContext context,
      required Map<String, dynamic> data}) async {
    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiGetTestDetail);
    }

    _repository!.getTestDetailFromMyPractice(data: data).then((value) async {
      _handleResponse(value, log);
    });
  }

  void _handleResponse(String value, LogModel? log) {
    Map<String, dynamic> map = jsonDecode(value);
    if (map[StringConstants.k_error_code] == 200) {
      Map<String, dynamic> dataMap = map[StringConstants.k_data];
      testDetail = TestDetailModel.fromJson(dataMap);

      //Add log
      Utils.prepareLogData(
        log: log,
        data: jsonDecode(value),
        message: null,
        status: LogEvent.success,
      );

      _view!.onGetTestDetailSuccess(testDetail!);
    } else if (map[StringConstants.k_error_code] == 501) {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: null,
        message:
            "Loading homework detail error: ${map[StringConstants.k_error_code]} ${map[StringConstants.k_messages]}",
        status: LogEvent.failed,
      );

      _view!.onGetTestDetailError(map[StringConstants.k_messages]);
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
  }
}
