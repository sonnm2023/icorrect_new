import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/practice_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/ai_option_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/scoring_order_model.dart';

abstract class MyPracticeScoringOrderTabViewContract {
  void onGetScoringOrderListSuccess(List<ScoringOrderModel> list);
  void onGetScoringOrderListError(String message);
  void onGetScoringOrderConfigInfoSuccess(List<AiOption> list);
  void onGetScoringOrderConfigInfoError(String message);
}

class MyPracticeScoringOrderTabPresenter {
  final MyPracticeScoringOrderTabViewContract? _view;
  PracticeRepository? _practiceRepository;

  MyPracticeScoringOrderTabPresenter(this._view) {
    _practiceRepository = Injector().getPracticeRepository();
  }

  void getListScoringOrderWithTestId(
      {required BuildContext context, required String testId}) async {
    //TODO
    // LogModel? log;
    // if (context.mounted) {
    //   log = await Utils.prepareToCreateLog(context,
    //       action: LogEvent.callApiGetListHomework);
    // }

    _practiceRepository!
        .getListScoringOrderWithTestId(testId)
        .then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap[StringConstants.k_error_code] == 200) {
        List<ScoringOrderModel> list =
            await _createListScoringOrder(dataMap[StringConstants.k_data]);

        if (kDebugMode) {
          print("DEBUG: getListScoringOrderWithTestId: ${list.length}");
        }

        //Add log
        // Utils.prepareLogData(
        //   log: log,
        //   data: jsonDecode(value),
        //   message: null,
        //   status: LogEvent.success,
        // );

        _view!.onGetScoringOrderListSuccess(list);
      } else {
        //Add log
        // Utils.prepareLogData(
        //   log: log,
        //   data: null,
        //   message:
        //       "Loading list homework error: ${dataMap['error_code']}${dataMap['status']}",
        //   status: LogEvent.failed,
        // );

        _view!.onGetScoringOrderListError(
            Utils.multiLanguage(StringConstants.common_error_message)!);
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) {
        //Add log
        // Utils.prepareLogData(
        //   log: log,
        //   data: null,
        //   message: onError.toString(),
        //   status: LogEvent.failed,
        // );

        _view!.onGetScoringOrderListError(
            Utils.multiLanguage(StringConstants.common_error_message)!);
      },
    );
  }

  void getScoringOrderConfigInfo(
      {required BuildContext context, required String testId}) {
    //TODO
    // LogModel? log;
    // if (context.mounted) {
    //   log = await Utils.prepareToCreateLog(context,
    //       action: LogEvent.callApiGetListHomework);
    // }

    _practiceRepository!
        .getScoringOrderConfigInfoWithId(testId)
        .then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap[StringConstants.k_error_code] == 200) {
        List<AiOption> list = await _createListAiOption(
            dataMap[StringConstants.k_data][StringConstants.k_ai_option]);
        //Add log
        // Utils.prepareLogData(
        //   log: log,
        //   data: jsonDecode(value),
        //   message: null,
        //   status: LogEvent.success,
        // );

        _view!.onGetScoringOrderConfigInfoSuccess(list);
      } else {
        //Add log
        // Utils.prepareLogData(
        //   log: log,
        //   data: null,
        //   message:
        //       "Loading list homework error: ${dataMap['error_code']}${dataMap['status']}",
        //   status: LogEvent.failed,
        // );

        _view!.onGetScoringOrderConfigInfoError(
            Utils.multiLanguage(StringConstants.common_error_message)!);
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) {
        //Add log
        // Utils.prepareLogData(
        //   log: log,
        //   data: null,
        //   message: onError.toString(),
        //   status: LogEvent.failed,
        // );

        _view!.onGetScoringOrderConfigInfoError(
            Utils.multiLanguage(StringConstants.common_error_message)!);
      },
    );
  }

  Future<List<ScoringOrderModel>> _createListScoringOrder(
      List<dynamic> data) async {
    if (data.isEmpty) return [];

    List<ScoringOrderModel> temp = [];
    for (int i = 0; i < data.length; i++) {
      ScoringOrderModel order = ScoringOrderModel.fromJson(data[i]);
      temp.add(order);
    }
    return temp;
  }

  Future<List<AiOption>> _createListAiOption(List<dynamic> data) async {
    if (data.isEmpty) return [];

    List<AiOption> temp = [];
    for (int i = 0; i < data.length; i++) {
      AiOption order = AiOption.fromJson(data[i]);
      temp.add(order);
    }
    return temp;
  }
}
