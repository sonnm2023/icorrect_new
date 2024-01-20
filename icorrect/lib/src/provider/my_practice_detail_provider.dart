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
  void updateIsAllScoring({required bool value}) {
    _isAllScoring = value;

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
}
