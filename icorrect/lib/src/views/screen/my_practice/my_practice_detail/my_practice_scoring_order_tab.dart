import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/my_practice_test_model/ai_option_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/my_practice_test_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/scoring_order_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect/src/presenters/my_practice_detail_presenter/my_practice_detail_presenter.dart';
import 'package:icorrect/src/presenters/my_practice_detail_presenter/my_practice_scoring_order_tab_presenter.dart';
import 'package:icorrect/src/provider/my_practice_detail_provider.dart';
import 'package:icorrect/src/views/other/circle_loading.dart';
import 'package:icorrect/src/views/widget/no_data_widget.dart';
import 'package:icorrect/src/views/widget/scoring_order_setting_widget.dart';
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
  late final List<AiOption> _listAiOption = [];

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
          crossAxisAlignment: CrossAxisAlignment.end,
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
    if (kDebugMode) {
      print("DEBUG: MyPracticeScoringOrderTab _buildList");
    }

    return Expanded(
      child: Stack(
        children: [
          Visibility(
            visible: _provider.listOrder.isNotEmpty,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _provider.listOrder.length,
              itemBuilder: (context, index) {
                return _buildItem(_provider.listOrder[index]);
              },
            ),
          ),
          Visibility(
            visible: _provider.listOrder.isEmpty,
            child: NoDataWidget(
              msg: Utils.multiLanguage(
                  StringConstants.list_scoring_order_empty_message)!,
              reloadCallBack: _reloadCallBack,
            ),
          ),
        ],
      ),
    );
    /*
    return Expanded(
      child: Consumer<MyPracticeDetailProvider>(
        builder: (context, provider, child) {
          if (kDebugMode) {
            print("DEBUG: MyPracticeScoringOrderTab _buildList");
          }
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
    */
  }

  Widget _buildItem(ScoringOrderModel order) {
    return Container();
  }

  Widget _buildCreateOrderButton() {
    return InkWell(
      onTap: () {
        _getScoringOrderConfigInfo();
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

  void _getScoringOrderConfigInfo() {
    _provider.updateProcessingStatus(processing: true);
    _presenter.getScoringOrderConfigInfo(
        context: context, testId: widget.practice.id.toString());
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

  void _handleError(String message) {
    _provider.updateProcessingStatus(processing: false);

    //Show error message
    showToastMsg(
      msg: message,
      toastState: ToastStatesType.error,
      isCenter: false,
    );
  }

  void _createListAiOption(List<AiOption> list) {
    if (_listAiOption.isNotEmpty) {
      _listAiOption.clear();
    }

    //Add new data
    for (int i = 0; i < list.length; i++) {
      AiOption item = list[i];
      _listAiOption.add(item);
    }

    if (kDebugMode) {
      print("DEBUG: List AiOption: ${_listAiOption.length}");
    }

    _showScoringOrderSetting(list);
  }

  Future<List<PartInfoModel>> _getListPartInfo(
      TestDetailModel testDetailModel) async {
    List<PartInfoModel> parts = []; //init list of part
    int _numberQuestionOfPart1 = 0;
    int _numberQuestionOfPart2 = 0;
    int _numberQuestionOfPart3 = 0;

    //Part introduce
    if (testDetailModel.introduce.questionList.isNotEmpty) {
      _numberQuestionOfPart1 += testDetailModel.introduce.questionList.length;
    }

    //Part 1
    if (testDetailModel.part1.isNotEmpty) {
      for (TopicModel topic in testDetailModel.part1) {
        if (topic.questionList.isNotEmpty) {
          _numberQuestionOfPart1 += topic.questionList.length;
        }
      }
    }

    PartInfoModel temp1 = PartInfoModel(
      PartType.part1,
      _numberQuestionOfPart1,
      testDetailModel.part1Time,
    );
    parts.add(temp1);

    //Part 2
    if (testDetailModel.part2.questionList.isNotEmpty) {
      _numberQuestionOfPart2 += testDetailModel.part2.questionList.length;
    }

    PartInfoModel temp2 = PartInfoModel(
      PartType.part2,
      _numberQuestionOfPart2,
      testDetailModel.part2Time,
    );
    parts.add(temp2);

    //Part 3
    if (testDetailModel.part3.followUp.isNotEmpty) {
      _numberQuestionOfPart3 += testDetailModel.part3.followUp.length;
    }

    if (testDetailModel.part3.questionList.isNotEmpty) {
      _numberQuestionOfPart3 += testDetailModel.part3.questionList.length;
    }

    PartInfoModel temp3 = PartInfoModel(
      PartType.part3,
      _numberQuestionOfPart3,
      testDetailModel.part3Time,
    );
    parts.add(temp3);

    return parts;
  }

  void _showScoringOrderSetting(List<AiOption> list) async {
    TestDetailModel? myPracticeDetail =
        Provider.of<MyPracticeDetailProvider>(context, listen: false)
            .myPracticeDetail;
    if (null == myPracticeDetail) {
      if (kDebugMode) {
        print(
            "DEBUG: _showScoringOrderSetting: Can't get my practice detail info");
      }
      return;
    }

    List<PartInfoModel> parts = await _getListPartInfo(myPracticeDetail);

    showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.white.withOpacity(0),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: ScoringOrderSettingWidget(
            myPracticeDetail: myPracticeDetail,
            parts: parts,
            listAiOption: list,
            parentPresenter: _presenter,
          ),
        );
      },
    ).whenComplete(() {
      Provider.of<MyPracticeDetailProvider>(context, listen: false)
          .updateShowNoteViewStatus(isShow: false);
    });
  }

  @override
  void onGetScoringOrderListError(String message) {
    _handleError(message);
  }

  @override
  void onGetScoringOrderListSuccess(List<ScoringOrderModel> list) {
    _provider.updateProcessingStatus(processing: false);
    _provider.setListOrder(list);
  }

  @override
  void onGetScoringOrderConfigInfoSuccess({
    required List<AiOption> list,
    required bool canGroupScoring,
  }) {
    _provider.updateProcessingStatus(processing: false);
    _provider.updateIsCanGroupScoring(value: canGroupScoring);
    // _provider.updateIsCanGroupScoring(value: false); //For test
    _createListAiOption(list);
  }

  @override
  void onGetScoringOrderConfigInfoError(String message) {
    _handleError(message);
  }

  @override
  void onRefreshScoringOrderList() {
    _getListScoringOrder();
  }

  @override
  bool get wantKeepAlive => true;
}
