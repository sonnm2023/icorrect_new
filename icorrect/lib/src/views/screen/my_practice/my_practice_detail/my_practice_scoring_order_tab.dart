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

  bool isLoading = false;
  bool isLoadingMore = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _provider = Provider.of<MyPracticeDetailProvider>(context, listen: false);
    _presenter = MyPracticeScoringOrderTabPresenter(this);
    _scrollController.addListener(_scrollListener);
    _loadData();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _loadMoreData();
    }
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

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              itemCount: provider.listOrder.length,
              itemBuilder: (context, index) {
                return _buildItem(provider.listOrder[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _generateIcon(ScoringOrderModel order) {
    Widget child;
    Color bgColor;
    if (order.scoreBy == 0) {
      //By AI
      bgColor = Colors.blueAccent;
      child = Text(
        "AI",
        style: CustomTextStyle.textWithCustomInfo(
          context: context,
          color: Colors.white,
          fontsSize: 25,
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      //By Expert
      bgColor = Colors.green;
      child = Image.asset(
        'assets/images/ic_expert.png',
        height: CustomSize.size_30,
        width: CustomSize.size_30,
        color: Colors.white,
      );
    }
    return Container(
      width: CustomSize.size_50,
      height: CustomSize.size_50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(CustomSize.size_100),
      ),
      child: Center(child: child),
    );
  }

  String _generateTitle(ScoringOrderModel order) {
    String scoreBy = "";
    if (order.scoreBy == 0) {
      scoreBy = "Chấm bởi AI";
    } else if (order.scoreBy == 1) {
      scoreBy = "Chấm bởi chuyên gia";
    }

    return "#${order.id}-$scoreBy";
  }

  void _extendOrder(ScoringOrderModel order) {}

  void _deleteOrder(ScoringOrderModel order) {}

  Widget _cancelOrderWidget(ScoringOrderModel order) {
    //In case: Cho tiep nhan, Qua han, Chua xu ly
    if (order.status! == 1 || order.status! == 5 || order.status! == 10) {
      return InkWell(
        onTap: () {
          _deleteOrder(order);
        },
        child: Container(
          width: 100,
          height: 35,
          alignment: Alignment.bottomRight,
          child: Text(
            "Huỷ yêu cầu",
            style: CustomTextStyle.textWithCustomInfo(
              context: context,
              color: Colors.grey,
              fontsSize: FontsSize.fontSize_16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return const SizedBox();
  }

  Widget _scoreOrExtendWidget(ScoringOrderModel order) {
    if (order.score! > 0) {
      return Text(
        order.score!.toDouble().toStringAsFixed(1),
        style: CustomTextStyle.textWithCustomInfo(
          context: context,
          color: Colors.green,
          fontsSize: FontsSize.fontSize_16,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    if (order.status! == 5 || order.status! == 10) {
      //Chua xu ly, qua han
      return InkWell(
        onTap: () {
          _extendOrder(order);
        },
        child: Container(
          width: 80,
          height: 35,
          alignment: Alignment.bottomRight,
          child: Text(
            "Gia hạn",
            style: CustomTextStyle.textWithCustomInfo(
              context: context,
              color: AppColor.defaultPurpleColor,
              fontsSize: FontsSize.fontSize_16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildItem(ScoringOrderModel order) {
    String title = _generateTitle(order);
    Map<String, dynamic> orderStatus = Utils.getScoringOrderStatus(order);

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.defaultPurpleColor, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Column(
              children: [
                _generateIcon(order),
                const SizedBox(height: 5),
                Text(
                  orderStatus['title'],
                  style: TextStyle(
                    color: orderStatus['color'],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  softWrap: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: CustomTextStyle.textWithCustomInfo(
                          context: context,
                          color: AppColor.defaultPurpleColor,
                          fontsSize: FontsSize.fontSize_16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    _scoreOrExtendWidget(order),
                  ],
                ),
                const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          Utils.getDate(order.createdAt!, true),
                          style: CustomTextStyle.textWithCustomInfo(
                            context: context,
                            color: AppColor.defaultGrayColor,
                            fontsSize: FontsSize.fontSize_15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 1),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.diamond,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          order.cost!.toString(),
                          style: CustomTextStyle.textWithCustomInfo(
                            context: context,
                            color: AppColor.defaultGrayColor,
                            fontsSize: FontsSize.fontSize_16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    _cancelOrderWidget(order),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  // Future<void> _loadData() async {
  //   _getListScoringOrder();
  // }

  // Future<void> _loadMoreData() async {
  //   await _getMoreDataFromAPI();
  // }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    // Call your API to get initial data
    // Replace this with your actual method call
    await _getListScoringOrder();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadMoreData() async {
    if (!isLoadingMore) {
      setState(() {
        isLoadingMore = true;
      });

      // Call your API to get more data
      // Replace this with your actual method call
      await _getMoreDataFromAPI();

      setState(() {
        isLoadingMore = false;
      });
    }
  }

  Future<void> _getMoreDataFromAPI() async {
    if (kDebugMode) {
      print("_getMoreDataFromAPI");
    }
    // await Future.delayed(Duration(seconds: 2)); // Simulate API call
    // scoringOrderList.addAll(List.generate(10, (index) => ScoringOrderModel((scoringOrderList.length + index).toString()))); // Example data
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

  Future<void> _getListScoringOrder() async {
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
