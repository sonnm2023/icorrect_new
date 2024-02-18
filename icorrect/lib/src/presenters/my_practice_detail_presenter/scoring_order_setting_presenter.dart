import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/practice_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/ai_option_model.dart';

abstract class ScoringOrderSettingViewContract {
  void onCalculatePriceSuccess(int totalPrice);
  void onCalculatePriceError(String message);
  void onCreateScoringOrderSuccess();
  void onCreateScoringOrderError(String message);
}

class ScoringOrderSettingPresenter {
  final ScoringOrderSettingViewContract? _view;
  PracticeRepository? _practiceRepository;

  ScoringOrderSettingPresenter(this._view) {
    _practiceRepository = Injector().getPracticeRepository();
  }

  void calculatePrice({
    required BuildContext context,
    required String testId,
    required int amountQuestionsPart1,
    required int amountQuestionsPart2,
    required int amountQuestionsPart3,
    required int typeScoring, //type_scoring : 2(chấm gộp), 1(chấm lẻ từng câu),
    required AiOption aiOption,
  }) async {
    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiCalculatePrice);
    }

    _practiceRepository!
        .calculatePrice(
      testId: testId,
      amountQuestionsPart1: amountQuestionsPart1,
      amountQuestionsPart2: amountQuestionsPart2,
      amountQuestionsPart3: amountQuestionsPart3,
      typeScoring: typeScoring,
      aiOption: aiOption,
    )
        .then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap[StringConstants.k_error_code] == 200) {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );
        int total = dataMap[StringConstants.k_data][StringConstants.k_diamond];

        _view!.onCalculatePriceSuccess(total);
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message:
              "Calculate price error: ${dataMap['error_code']}${dataMap['status']}",
          status: LogEvent.failed,
        );

        _view!.onCalculatePriceError(
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

        _view!.onCalculatePriceError(
            Utils.multiLanguage(StringConstants.common_error_message)!);
      },
    );
  }

  void createScoringOrder({required String testId}) async {
    _practiceRepository!
        .createScoringOrder(
      testId: testId,
    )
        .then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap[StringConstants.k_error_code] == 200) {
        _view!.onCreateScoringOrderSuccess();
      } else {
        _view!.onCreateScoringOrderError(
            Utils.multiLanguage(StringConstants.common_error_message)!);
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) {
        _view!.onCreateScoringOrderError(
            Utils.multiLanguage(StringConstants.common_error_message)!);
      },
    );
  }
}
