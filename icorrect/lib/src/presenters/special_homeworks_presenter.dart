import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/my_test_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/my_test_models/student_result_model.dart';

abstract class SpecialHomeworksContracts {
  void getSpecialHomeWork(List<StudentResultModel> studentsResults);
  void getSpecialHomeWorksFail(String message);
}

class SpecialHomeworksPresenter {
  final SpecialHomeworksContracts? _view;
  MyTestRepository? _myTestRepository;

  SpecialHomeworksPresenter(this._view) {
    _myTestRepository = Injector().getMyTestRepository();
  }

  void getSpecialHomeWorks({
    required BuildContext context,
    required String email,
    required String activityId,
    required int status,
    required int example,
  }) async {
    assert(_view != null && _myTestRepository != null);

    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiGetSpecialHomework);
    }

    _myTestRepository!
        .getSpecialHomeWorks(email, activityId, status, example)
        .then((value) {
      Map<String, dynamic> dataMap = jsonDecode(value) ?? {};

      if (kDebugMode) {
        print("DEBUG: getSpecialHomeWorks: result: ${value.toString()}");
      }

      if (dataMap.isNotEmpty) {
        if (dataMap['error_code'] == 200) {
          List<StudentResultModel> results =
              _getStudentResultsModel(dataMap['data'] ?? []);

          //Add log
          Utils.prepareLogData(
            log: log,
            key: "response",
            value: value,
            message: null,
            status: LogEvent.success,
          );

          _view!.getSpecialHomeWork(results);
        } else {
          //Add log
          Utils.prepareLogData(
              log: log,
              key: null,
              value: null,
              message:
              'GetSpecialHomeWorks: result fail!',
              status: LogEvent.failed,
          );

          _view!.getSpecialHomeWorksFail('GetSpecialHomeWorks: result fail!');
        }
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          key: null,
          value: null,
          message:
          'GetSpecialHomeWorks fail.Please check your internet and try again!',
          status: LogEvent.failed,
        );

        _view!.getSpecialHomeWorksFail(
            'GetSpecialHomeWorks fail.Please check your internet and try again!');
      }
    }).catchError((onError) {
      //Add log
      Utils.prepareLogData(
        log: log,
        key: null,
        value: null,
        message: onError.toString(),
        status: LogEvent.failed,
      );

      _view!.getSpecialHomeWorksFail(
          'Error when getSpecialHomeWorks : ${onError.toString()}');
      if (kDebugMode) {
        print("DEBUG: getSpecialHomeWorks ${onError.toString()}");
      }
    });
  }

  List<StudentResultModel> _getStudentResultsModel(List<dynamic> data) {
    if (kDebugMode) {
      print("DEBUG: _getStudentResultsModel ${data.toString()}");
    }
    List<StudentResultModel> results = [];
    for (int i = 0; i < data.length; i++) {
      dynamic item = data[i];
      results.add(StudentResultModel.fromJson(item));
    }
    return results;
  }
}
