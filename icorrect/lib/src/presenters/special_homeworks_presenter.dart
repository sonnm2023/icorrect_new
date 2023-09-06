import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/my_test_repository.dart';
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

  void getSpecialHomeWorks(
      {required String email,
      required String activityId,
      required int status,
      required int example}) {
    assert(_view != null && _myTestRepository != null);
    _myTestRepository!
        .getSpecialHomeWorks(email, activityId, status, example)
        .then((value) {
      Map<String, dynamic> dataMap = jsonDecode(value) ?? [];

      if (dataMap.isNotEmpty) {
        if (dataMap['error_code'] == 200) {
          List<StudentResultModel> results =
              _getStudentResultsModel(dataMap['data'] ?? {});
          _view!.getSpecialHomeWork(results);
        } else {
          _view!.getSpecialHomeWorksFail('Loading result response fail !');
        }
      } else {
        _view!.getSpecialHomeWorksFail(
            'Loading result response fail.Please check your internet and try again!');
      }
    }).catchError((onError) {
      _view!.getSpecialHomeWorksFail(
          'Error when load homeworks : ${onError.toString()}');
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
