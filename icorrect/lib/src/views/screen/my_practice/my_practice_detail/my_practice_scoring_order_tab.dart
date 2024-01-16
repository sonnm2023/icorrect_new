import 'package:flutter/material.dart';
import 'package:icorrect/src/models/my_practice_test_model/my_practice_test_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/scoring_order_model.dart';
import 'package:icorrect/src/presenters/my_practice_detail_presenter/my_practice_detail_presenter.dart';
import 'package:icorrect/src/presenters/my_practice_detail_presenter/my_practice_scoring_order_tab_presenter.dart';

class MyPracticeScoringOrderTab extends StatefulWidget {
  final MyPracticeDetailPresenter presenter;
  final MyPracticeTestModel practice;
  const MyPracticeScoringOrderTab(
      {super.key, required this.presenter, required this.practice});

  @override
  State<MyPracticeScoringOrderTab> createState() =>
      _MyPracticeScoringOrderTabState();
}

class _MyPracticeScoringOrderTabState extends State<MyPracticeScoringOrderTab>
    with AutomaticKeepAliveClientMixin<MyPracticeScoringOrderTab>
    implements MyPracticeScoringOrderTabViewContract {
  late final MyPracticeScoringOrderTabPresenter _presenter;
  @override
  void initState() {
    super.initState();
    _presenter = MyPracticeScoringOrderTabPresenter(this);
    _presenter.getListScoringOrderWithTestId(
        context: context, testId: widget.practice.id.toString());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const Placeholder();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void onGetScoringOrderListError(String message) {}

  @override
  void onGetScoringOrderListSuccess(List<ScoringOrderModel> list) {
    if (list.isEmpty) {
      //Build No Data UI
    } else {
      
    }
  }
}
