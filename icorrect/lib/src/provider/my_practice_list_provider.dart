import 'package:flutter/foundation.dart';
import 'package:icorrect/src/models/my_practice_test_model/bank_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/my_practice_response_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/my_practice_test_model.dart';

class MyPracticeListProvider extends ChangeNotifier {
  bool isDisposed = false;
  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }

  @override
  void notifyListeners() {
    if (!isDisposed) {
      super.notifyListeners();
    }
  }

  MyPracticeResponseModel _myPracticeResponseModel = MyPracticeResponseModel();
  MyPracticeResponseModel get myPracticeResponseModel =>
      _myPracticeResponseModel;
  void setMyPracticeResponseModel(MyPracticeResponseModel model) {
    _myPracticeResponseModel = model;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  final List<MyPracticeTestModel> _myTestsList = [];
  List<MyPracticeTestModel> get myTestsList => _myTestsList;
  void setMyTestsList(List<MyPracticeTestModel> list) {
    if (_myTestsList.isNotEmpty) {
      _myTestsList.clear();
    }
    _myTestsList.addAll(list);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void removeTestAt(int indexDeleted) {
    _myTestsList.removeAt(indexDeleted);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addMyTestsList(List<MyPracticeTestModel> list) {
    _myTestsList.addAll(list);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearMyTestsList() {
    _myTestsList.clear();
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _pageNum = 0;
  int get pageNum => _pageNum;
  void setPageNum(int page) {
    _pageNum = page;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _showLoadingBottom = false;
  bool get showLoadingBottom => _showLoadingBottom;
  void setShowLoadingBottom(bool isShow) {
    _showLoadingBottom = isShow;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  final List<BankModel> _banks = [];
  List<BankModel> get banks => _banks;

  void setBankList(List<BankModel> list) {
    clearBankList();
    _banks.addAll(list);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearBankList() {
    if (_banks.isNotEmpty) {
      _banks.clear();
    }
  }

  bool _showBankListButton = false;
  bool get showBankListButton => _showBankListButton;

  void updateStatusShowBankListButton({required bool isShow}) {
    _showBankListButton = isShow;

    if (!isDisposed) {
      notifyListeners();
    }
  }
}
