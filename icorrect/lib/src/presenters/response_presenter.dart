import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/my_test_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/my_test_models/result_response_model.dart';

abstract class ResponseContracts {
  void getSuccessResponse(ResultResponseModel responseModel);
  void getErrorResponse(String message);
}

class ResponsePresenter {
  final ResponseContracts? _view;
  MyTestRepository? _repository;

  ResponsePresenter(this._view) {
    _repository = Injector().getMyTestRepository();
  }

  void getResponse({
    required BuildContext context,
    required String orderId,
  }) async {
    assert(_view != null && _repository != null);

    //Add log
    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiGetResponse);
    }

    _repository!.getResponse(orderId).then((value) {
      Map<String, dynamic> dataMap = jsonDecode(value) ?? {};

      if (kDebugMode) {
        print(dataMap.toString());
      }

      if (dataMap.isNotEmpty) {
        ResultResponseModel responseModel =
            ResultResponseModel.fromJson(dataMap);

        //Add log
        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );

        _view!.getSuccessResponse(responseModel);
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: "Loading result response fail!",
          status: LogEvent.failed,
        );

        _view!.getErrorResponse(
            StringConstants.load_result_response_error_message);
      }
    }).catchError((onError) {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: null,
        message: onError.toString(),
        status: LogEvent.failed,
      );

      // ignore: invalid_return_type_for_catch_error
      _view!.getErrorResponse(StringConstants.can_not_load_response_message);
    });
  }
}
