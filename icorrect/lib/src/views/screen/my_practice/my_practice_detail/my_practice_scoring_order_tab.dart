import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/my_practice_test_model/my_practice_test_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/scoring_order_model.dart';
import 'package:icorrect/src/presenters/my_practice_detail_presenter/my_practice_detail_presenter.dart';
import 'package:icorrect/src/presenters/my_practice_detail_presenter/my_practice_scoring_order_tab_presenter.dart';
import 'package:icorrect/src/provider/my_practice_detail_provider.dart';
import 'package:icorrect/src/views/other/circle_loading.dart';
import 'package:icorrect/src/views/widget/no_data_widget.dart';
import 'package:provider/provider.dart';

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
  late final MyPracticeDetailProvider _provider;
  late final CircleLoading _loading;

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _provider = Provider.of<MyPracticeDetailProvider>(context, listen: false);
    _presenter = MyPracticeScoringOrderTabPresenter(this);
    _getListScoringOrder();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Column(
          children: [
            _buildList(),
            _buildCreateOrderButton(),
          ],
        ),
        _buildProcessingView(),
      ],
    );
  }

  Widget _buildProcessingView() {
    return Consumer<MyPracticeDetailProvider>(
      builder: (context, provider, child) {
        if (kDebugMode) {
          print("DEBUG: MyPracticeScoringOrderTab: update UI with processing");
        }
        if (provider.isProcessing) {
          _loading.show(context: context, isViewAIResponse: false);
        } else {
          _loading.hide();
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildList() {
    return Expanded(
      child: Consumer<MyPracticeDetailProvider>(
        builder: (context, provider, child) {
          if (provider.listOrder.isEmpty) {
            return NoDataWidget(
              msg: Utils.multiLanguage(
                  StringConstants.list_scoring_order_empty_message)!,
              reloadCallBack: _reloadCallBack,
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: provider.listOrder.length,
            itemBuilder: (context, index) {
              return _buildItem(provider.listOrder[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildItem(ScoringOrderModel order) {
    return Container();
  }

  Widget _buildCreateOrderButton() {
    return InkWell(
      onTap: () {
        if (kDebugMode) {
          print("DEBUG: Create Order Tapped");
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        decoration: const BoxDecoration(
          color: AppColor.defaultPurpleColor,
        ),
        alignment: Alignment.center,
        child: Text(
          Utils.multiLanguage(StringConstants.create_scoring_order)!,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: FontsSize.fontSize_16,
          ),
        ),
      ),
    );
  }

  void _reloadCallBack() async {
    if (kDebugMode) {
      print("DEBUG: MyPracticeScoringOrderTab: _reloadCallBack");
    }
    _getListScoringOrder();
  }

  void _getListScoringOrder() {
    Future.delayed(const Duration(microseconds: 0), () {
      _provider.updateProcessingStatus(processing: true);
    });

    _presenter.getListScoringOrderWithTestId(
        context: context, testId: widget.practice.id.toString());
  }

  @override
  void onGetScoringOrderListError(String message) {
    _provider.updateProcessingStatus(processing: false);

    //Show error message
    showToastMsg(
      msg: message,
      toastState: ToastStatesType.error,
      isCenter: false,
    );
  }

  @override
  void onGetScoringOrderListSuccess(List<ScoringOrderModel> list) {
    _provider.updateProcessingStatus(processing: false);
    _provider.setListOrder(list);
  }

  @override
  bool get wantKeepAlive => true;
}
