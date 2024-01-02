import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/practice_repository.dart';
import 'package:icorrect/src/models/my_practice_test_model/bank_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/my_practice_response_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/my_practice_test_model.dart';

abstract class MyTestsListConstract {
  void onGetMyTestsListSuccess(MyPracticeResponseModel practiceResponseModel,
      List<MyPracticeTestModel> practiceTests, bool isLoadMore);
  void onGetMyTestListFail(String message);
  void onDeleteTestSuccess(String message, int indexDeleted);
  void onDeleteTestFail(String message);
  void onGetBankListSuccess(List<BankModel> banks);
  void onGetBankListFail(String message);
}

class MyTestsListPresenter {
  final MyTestsListConstract? _view;
  PracticeRepository? _repository;

  MyTestsListPresenter(this._view) {
    _repository = Injector().getPracticeRepository();
  }

  Future getMyTestLists(
      {required int pageNum, required bool isLoadMore}) async {
    assert(_view != null && _repository != null);
    _repository!.getMyPracticeTestList(pageNum.toString()).then((value) {
      if (kDebugMode) {
        print("DEBUG:getMyTestLists: $value ");
      }
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap[StringConstants.k_error_code] == 200) {
        MyPracticeResponseModel practiceResponseModel =
            MyPracticeResponseModel.fromJson(dataMap);
        _view!.onGetMyTestsListSuccess(
            practiceResponseModel,
            practiceResponseModel.myPracticeDataModel.myPracticeTests,
            isLoadMore);
      } else {
        _view!.onGetMyTestListFail(StringConstants.common_error_message);
      }
    }).catchError((error) {
      _view!.onGetMyTestListFail(StringConstants.common_error_message);
    });
  }

  Future deleteTest({required int testId, required int index}) async {
    assert(_view != null && _repository != null);

    _repository!.deleteTest(testId.toString()).then((value) {
      if (kDebugMode) {
        print("DEBUG:deleteTest: $value ");
      }
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap[StringConstants.k_error_code] == 200) {
        _view!.onDeleteTestSuccess(
            StringConstants.delete_test_success_message, index);
      } else {
        _view!.onDeleteTestFail(StringConstants.common_error_message);
      }
    }).catchError((error) {
      _view!.onDeleteTestFail(StringConstants.common_error_message);
    });
  }

  Future getBankList() async {
    assert(_view != null && _repository != null);
    _repository!.getBankList().then((value) async {
      if (kDebugMode) {
        print("DEBUG:getBankList: $value ");
      }
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap[StringConstants.k_error_code] == 200) {
        List<BankModel> banks = await _generateList(dataMap["data"]);
        _view!.onGetBankListSuccess(banks);
      } else {
        _view!.onGetBankListFail(StringConstants.common_error_message);
      }
    }).catchError((error) {
      _view!.onGetBankListFail(StringConstants.common_error_message);
    });
  }

  Future<List<BankModel>> _generateList(List<dynamic> data) async {
    List<BankModel> temp = [];
    for (int i = 0; i < data.length; i++) {
      BankModel item = BankModel.fromJson(data[i]);
      temp.add(item);
    }
    return temp;
  }
}
