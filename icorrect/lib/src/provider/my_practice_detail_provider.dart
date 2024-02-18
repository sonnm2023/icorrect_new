import 'package:flutter/material.dart';
import 'package:icorrect/src/models/my_practice_test_model/scoring_order_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';

class MyPracticeDetailProvider extends ChangeNotifier {
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

  final List<ScoringOrderModel> _listOrder = [];
  List<ScoringOrderModel> get listOrder => _listOrder;
  Future<void> setListOrder(List<ScoringOrderModel> list) async {
    if (_listOrder.isNotEmpty) _listOrder.clear();
    _listOrder.addAll(list);
  }

  void resetListClassForFilter() {
    _listOrder.clear();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void updateLoadingStatus({required bool value}) {
    _isLoading = value;

    notifyListeners();
  }

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;
  void updateProcessingStatus({required bool processing}) {
    _isProcessing = processing;

    notifyListeners();
  }

  bool _isCanGroupScoring = false;
  bool get isCanGroupScoring => _isCanGroupScoring;
  void updateIsCanGroupScoring({required bool value}) {
    _isCanGroupScoring = value;

    notifyListeners();
  }

  bool _isGroupScoring = false;
  bool get isGroupScoring => _isGroupScoring;
  void updateIsGroupScoring({required bool value}) {
    _isGroupScoring = value;

    notifyListeners();
  }

  bool _isAllScoring = false;
  bool get isAllScoring => _isAllScoring;
  void updateIsAllScoring(
      {required bool isSelected,
      required int? value1,
      required int? value2,
      required int? value3}) {
    _isAllScoring = isSelected;

    //Update all number question of all parts
    if (isSelected && null != value1 && null != value2 && null != value3) {
      setNumberQuestionOfPart(
          index: 0, value: value1.toDouble(), isInitData: false);
      setNumberQuestionOfPart(
          index: 1, value: value2.toDouble(), isInitData: false);
      setNumberQuestionOfPart(
          index: 2, value: value3.toDouble(), isInitData: false);
    }

    notifyListeners();
  }

  int _currentUsd = 0;
  int get currentUsd => _currentUsd;
  void updateCurrentUsd(int value) {
    _currentUsd = value;

    notifyListeners();
  }

  int _totalPrice = 0;
  int get totalPrice => _totalPrice;
  void updateTotalPrice(int value) {
    _totalPrice = value;

    notifyListeners();
  }

  TestDetailModel? _myPracticeDetail;
  TestDetailModel? get myPracticeDetail => _myPracticeDetail;
  void setMyPracticeDetail({required TestDetailModel value}) {
    _myPracticeDetail = value;
  }

  void resetMyPracticeDetail() {
    if (null != _myPracticeDetail) {
      _myPracticeDetail = null;
    }
  }

  double getNumberOfPart(int index) {
    switch (index) {
      case 0:
        return _numberQuestionOfPart1;
      case 1:
        return _numberQuestionOfPart2;
      case 2:
        return _numberQuestionOfPart3;
    }
    return 0.0;
  }

  void setNumberQuestionOfPart(
      {required int index, required double value, required bool isInitData}) {
    switch (index) {
      case 0:
        _numberQuestionOfPart1 = value;
      case 1:
        _numberQuestionOfPart2 = value;
      case 2:
        _numberQuestionOfPart3 = value;
    }

    if (!isInitData) {
      notifyListeners();
    }
  }

  double _numberQuestionOfPart1 = 0;
  double get numberQuestionOfPart1 => _numberQuestionOfPart1;

  double _numberQuestionOfPart2 = 0;
  double get numberQuestionOfPart2 => _numberQuestionOfPart2;

  double _numberQuestionOfPart3 = 0;
  double get numberQuestionOfPart3 => _numberQuestionOfPart3;

  bool _isShowNoteView = false;
  bool get isShowNoteView => _isShowNoteView;
  void updateShowNoteViewStatus({required bool isShow}) {
    _isShowNoteView = isShow;

    notifyListeners();
  }

  String _noteMessage = "";
  String get noteMessage => _noteMessage;
  void updateNoteMessage(String value) {
    _noteMessage = value;
  }

  bool _isScoringRequest = false;
  bool get isScoringRequest => _isScoringRequest;
  void updateScoringRequestStatus({required bool value}) {
    _isScoringRequest = value;

    notifyListeners();
  }
}
