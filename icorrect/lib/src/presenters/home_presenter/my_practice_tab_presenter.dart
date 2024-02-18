import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/practice_repository.dart';
import 'package:icorrect/src/models/my_practice_test_model/bank_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/my_practice_response_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/my_practice_test_model.dart';

abstract class MyPracticeTabContract {
  void onGetMyPracticeListSuccess(
      {required MyPracticeResponseModel practiceResponseModel,
      required List<MyPracticeTestModel> practiceTests,
      required bool isLoadMore,
      required bool isRefresh});
  void onGetMyPracticeListError(String message);
  void onDeleteMyPracticeSuccess(String message, int index);
  void onDeleteMyPracticeError(String message);
  void onGetBankListSuccess(List<BankModel> banks);
  void onGetBankListError(String message);
}

class MyPracticeTabPresenter {
  final MyPracticeTabContract? _view;
  PracticeRepository? _repository;

  MyPracticeTabPresenter(this._view) {
    _repository = Injector().getPracticeRepository();
  }

  Future getMyPracticeList({
    required int pageNum,
    required bool isLoadMore,
    required bool isRefresh,
  }) async {
    assert(_view != null && _repository != null);
    _repository!.getMyPracticeList(pageNum.toString()).then((value) {
      if (kDebugMode) {
        print("DEBUG: getMyPracticeList: $value ");
      }
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap[StringConstants.k_error_code] == 200) {
        MyPracticeResponseModel practiceResponseModel =
            MyPracticeResponseModel.fromJson(dataMap);
        _view!.onGetMyPracticeListSuccess(
          practiceResponseModel: practiceResponseModel,
          practiceTests:
              practiceResponseModel.myPracticeDataModel.myPracticeTests,
          isLoadMore: isLoadMore,
          isRefresh: isRefresh,
        );
      } else {
        _view!.onGetMyPracticeListError(StringConstants.common_error_message);
      }
    }).catchError((error) {
      _view!.onGetMyPracticeListError(StringConstants.common_error_message);
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
        _view!.onDeleteMyPracticeSuccess(
            StringConstants.delete_test_success_message, index);
      } else {
        _view!.onDeleteMyPracticeError(StringConstants.common_error_message);
      }
    }).catchError((error) {
      _view!.onDeleteMyPracticeError(StringConstants.common_error_message);
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
        _view!.onGetBankListError(StringConstants.common_error_message);
      }
    }).catchError((error) {
      _view!.onGetBankListError(StringConstants.common_error_message);
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