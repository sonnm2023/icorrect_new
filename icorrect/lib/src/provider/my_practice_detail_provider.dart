import 'package:flutter/material.dart';
import 'package:icorrect/src/models/my_practice_test_model/scoring_order_model.dart';

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
}
