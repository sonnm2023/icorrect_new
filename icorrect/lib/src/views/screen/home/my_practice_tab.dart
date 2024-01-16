import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/my_practice_test_model/bank_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/my_practice_response_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/my_practice_test_model.dart';
import 'package:icorrect/src/presenters/home_presenter/my_practice_tab_presenter.dart';
import 'package:icorrect/src/provider/my_practice_list_provider.dart';
import 'package:icorrect/src/views/other/message_dialog.dart';
import 'package:icorrect/src/views/screen/my_practice/my_practice_detail/my_practice_detail_screen.dart';
import 'package:icorrect/src/views/screen/my_practice/my_practice_setting/my_practice_setting_screen.dart';
import 'package:icorrect/src/views/other/circle_loading.dart';
import 'package:icorrect/src/views/other/custom_alert_dialog.dart';
import 'package:icorrect/src/views/widget/no_data_widget.dart';
import 'package:provider/provider.dart';

class MyPracticeTab extends StatefulWidget {
  const MyPracticeTab({super.key});

  @override
  State<MyPracticeTab> createState() => _MyPracticeTabState();
}

class _MyPracticeTabState extends State<MyPracticeTab>
    with AutomaticKeepAliveClientMixin
    implements MyPracticeTabContract {
  double w = 0, h = 0;
  MyPracticeTabPresenter? _presenter;
  CircleLoading? _loading;
  MyPracticeListProvider? _myPracticeListProvider;

  @override
  void initState() {
    super.initState();
    _presenter = MyPracticeTabPresenter(this);
    _loading = CircleLoading();
    _myPracticeListProvider =
        Provider.of<MyPracticeListProvider>(context, listen: false);
    _myPracticeListProvider!.refreshList(false);

    _getMyPracticeList(isRefresh: false, needShowLoading: true);
    _getBankList();
  }

  @override
  void dispose() {
    if (null != _loading) {
      _loading = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        left: true,
        top: true,
        right: true,
        bottom: true,
        child: SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: [
              _buildList(),
              _buildLoadMore(),
              _buildBankListButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankListButton() {
    return Consumer<MyPracticeListProvider>(
      builder: (context, provider, child) {
        if (provider.isRefreshList) {
          provider.refreshList(false);
          _getMyPracticeList(isRefresh: true, needShowLoading: false);
        }

        return Visibility(
          visible: provider.banks.isNotEmpty,
          child: Container(
            alignment: Alignment.bottomRight,
            margin: const EdgeInsets.all(15),
            child: SpeedDial(
              backgroundColor: AppColor.defaultYellowColor,
              overlayColor: Colors.black,
              overlayOpacity: 0.6,
              spaceBetweenChildren: 10,
              activeBackgroundColor: AppColor.defaultYellowColor,
              activeIcon: Icons.close,
              foregroundColor: Colors.white,
              children: _createBankListUI(),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void _getMyPracticeList(
      {required bool isRefresh, required bool needShowLoading}) {
    if (null != _loading &&
        null != _presenter &&
        null != _myPracticeListProvider) {
      int pageNum = 1;
      if (needShowLoading) {
        _loading!.show(context: context, isViewAIResponse: false);
      }
      _presenter!.getMyPracticeList(
          pageNum: pageNum, isLoadMore: false, isRefresh: isRefresh);

      Future.delayed(
        Duration.zero,
        () {
          _myPracticeListProvider!.setPageNum(pageNum);
          _myPracticeListProvider!.setIsProcessing(true);
        },
      );
    }
  }

  void _getBankList() {
    _presenter!.getBankList();
  }

  void _gotoMyPracticeSettingScreen(BankModel bank) {
    if (kDebugMode) {
      print("DEBUG: you chose bank id = ${bank.id}");
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyPracticeSettingScreen(
          selectedBank: bank,
          onRefresh: _refreshList,
        ),
      ),
    );
  }

  void _refreshList() {
    if (kDebugMode) {
      print("DEBUG: _refreshList Callback");
    }
    _getMyPracticeList(isRefresh: true, needShowLoading: true);
  }

  List<SpeedDialChild> _createBankListUI() {
    if (_myPracticeListProvider!.banks.isEmpty) return [];

    List<SpeedDialChild> list = [];
    for (int i = 0; i < _myPracticeListProvider!.banks.length; i++) {
      BankModel bank =
          _myPracticeListProvider!.banks[i]; //Default Class bank icon
      Widget child = const Image(
        image: AssetImage(AppAsset.ic_book),
        width: 25,
        height: 25,
        color: Colors.white,
      );
      Color bgColor = Colors.green; //Default Class bank color
      if (bank.type == 0) {
        child = const Center(
          child: Text(
            "IELTS",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        );
        //IELTS bank icon
        bgColor = const Color.fromARGB(255, 237, 125, 50);
      }

      SpeedDialChild temp = SpeedDialChild(
        shape: const CircleBorder(),
        onTap: () {
          _gotoMyPracticeSettingScreen(bank);
        },
        child: Container(
          margin: const EdgeInsets.all(5),
          child: child,
        ),
        backgroundColor: bgColor,
        labelWidget: Container(
          margin: const EdgeInsets.only(right: 10),
          child: Text(
            bank.title != null ? bank.title! : "",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

      list.add(temp);
    }
    return list;
  }

  Widget _buildList() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Consumer<MyPracticeListProvider>(
        builder: (context, provider, child) {
          if (provider.myTestsList.isEmpty && !provider.isProcessing) {
            return NoDataWidget(
              msg: Utils.multiLanguage(
                  StringConstants.my_practice_no_data_message)!,
              reloadCallBack: _reloadCallBack,
            );
          }
          return Container(
            height: h,
            padding: const EdgeInsets.only(bottom: 150),
            child: NotificationListener<ScrollEndNotification>(
              onNotification: (scrollEnd) {
                final metrics = scrollEnd.metrics;
                if (metrics.atEdge) {
                  bool isTop = metrics.pixels == 0;
                  if (isTop) {
                    if (kDebugMode) {
                      print("DEBUG :Scroll To Top");
                    }
                  } else {
                    _startLoadMoreData();
                    if (kDebugMode) {
                      print("DEBUG :Scroll To Bottom");
                    }
                  }
                }
                return false;
              },
              child: ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: provider.myTestsList.length,
                itemBuilder: (BuildContext context, int index) {
                  MyPracticeTestModel myTestModel = provider.myTestsList[index];
                  return InkWell(
                    onTap: () {
                      _gotoMyPracticeDetailScreen(myTestModel);
                    },
                    child: _buildItem(myTestModel, index),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItem(MyPracticeTestModel myTestModel, int index) {
    Map<String, String> dataString = _getMyTestItem(myTestModel.type);
    String title = Utils.generateTitle(myTestModel);
    double score = Utils.generateScore(myTestModel);
    Color scoreColor = AppColor.defaultGrayColor;
    if (score > 0) {
      scoreColor = Colors.amber;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.defaultPurpleColor, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: CustomSize.size_50,
            height: CustomSize.size_50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2.0,
                color: AppColor.defaultPurpleColor,
              ),
              borderRadius: BorderRadius.circular(CustomSize.size_100),
            ),
            child: Text(
              dataString[StringConstants.k_data] ?? "I",
              style: CustomTextStyle.textWithCustomInfo(
                context: context,
                color: AppColor.defaultPurpleColor,
                fontsSize: FontsSize.fontSize_16,
                fontWeight: FontWeight.w600,
              ),
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
                    Text(
                      _getDate(myTestModel.createdAt),
                      style: CustomTextStyle.textWithCustomInfo(
                        context: context,
                        color: AppColor.defaultGrayColor,
                        fontsSize: FontsSize.fontSize_15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: AppColor.defaultGrayColor,
                        ),
                        const SizedBox(width: 1),
                        Text(
                          Utils.formateDuration(myTestModel.duration),
                          style: CustomTextStyle.textWithCustomInfo(
                            context: context,
                            color: AppColor.defaultGrayColor,
                            fontsSize: FontsSize.fontSize_16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.star,
                            color: scoreColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          score == 0.0 ? "NA" : "$score",
                          style: CustomTextStyle.textWithCustomInfo(
                            context: context,
                            color: AppColor.defaultGrayColor,
                            fontsSize: FontsSize.fontSize_16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        _deleteTest(myTestModel.id, index);
                      },
                      child: Container(
                        width: 80,
                        height: 35,
                        alignment: Alignment.bottomRight,
                        child: Text(
                          Utils.multiLanguage(
                              StringConstants.delete_action_title)!,
                          style: CustomTextStyle.textWithCustomInfo(
                            context: context,
                            color: AppColor.defaultPurpleColor,
                            fontsSize: FontsSize.fontSize_16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMore() {
    return Consumer<MyPracticeListProvider>(
      builder: (context, provider, child) {
        return Visibility(
          visible: provider.showLoadingBottom,
          child: Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        backgroundColor: AppColor.defaultLightGrayColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColor.defaultPurpleColor,
                        ),
                      )),
                  const SizedBox(width: 10),
                  Text(
                    "${Utils.multiLanguage(StringConstants.loading_title)}...",
                    style: CustomTextStyle.textWithCustomInfo(
                      context: context,
                      color: AppColor.defaultPurpleColor,
                      fontsSize: FontsSize.fontSize_15,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _startLoadMoreData() {
    if (!_myPracticeListProvider!.showLoadingBottom) {
      MyPracticeResponseModel practiceResponseModel =
          _myPracticeListProvider!.myPracticeResponseModel;
      int pageNum = _myPracticeListProvider!.pageNum;
      int lastPage = practiceResponseModel.myPracticeDataModel.lastPage;
      if (pageNum < lastPage) {
        pageNum = pageNum + 1;
        _presenter!.getMyPracticeList(
            pageNum: pageNum, isLoadMore: true, isRefresh: false);
        _myPracticeListProvider!.setPageNum(pageNum);
      } else {
        Future.delayed(
          const Duration(seconds: 1),
          () {
            _myPracticeListProvider!.setShowLoadingBottom(false);
          },
        );
      }
      _myPracticeListProvider!.setShowLoadingBottom(true);
    }
  }

  Map<String, String> _getMyTestItem(int type) {
    switch (type) {
      case 1:
        return {
          StringConstants.k_title: "Practice Part I",
          StringConstants.k_data: "I"
        };
      case 2:
        return {
          StringConstants.k_title: "Practice Part II",
          StringConstants.k_data: "II"
        };
      case 3:
        return {
          StringConstants.k_title: "Practice Part III",
          StringConstants.k_data: "III"
        };
      case 4:
        return {
          StringConstants.k_title: "Practice Part II & III",
          StringConstants.k_data: "II&&III"
        };
      case 5:
        return {
          StringConstants.k_title: "Practice Full Test",
          StringConstants.k_data: "FULL"
        };
      default:
        return {
          StringConstants.k_title: "Practice Part I",
          StringConstants.k_data: "I"
        };
    }
  }

  String _getDate(String dateTime) {
    var date = DateTime.parse(dateTime);
    return "${date.day}-${date.month}-${date.year}";
  }

  void _deleteTest(int testId, int indexDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: Utils.multiLanguage(StringConstants.dialog_title)!,
          description:
              Utils.multiLanguage(StringConstants.delete_this_test_confirm)!,
          okButtonTitle: Utils.multiLanguage(StringConstants.ok_button_title),
          cancelButtonTitle:
              Utils.multiLanguage(StringConstants.cancel_button_title),
          borderRadius: 8,
          hasCloseButton: true,
          okButtonTapped: () {
            _loading!.show(context: context, isViewAIResponse: false);
            _presenter!.deleteTest(testId: testId, index: indexDelete);
          },
          cancelButtonTapped: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _gotoMyPracticeDetailScreen(MyPracticeTestModel myPractice) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MyPracticeDetailScreen(
          practice: myPractice,
        ),
      ),
    );
  }

  void _reloadCallBack() async {
    if (kDebugMode) {
      print("DEBUG: MyPracticeList - _reloadCallBack");
    }
    _getMyPracticeList(isRefresh: true, needShowLoading: true);
  }

  @override
  void onGetMyPracticeListSuccess({
    required MyPracticeResponseModel practiceResponseModel,
    required List<MyPracticeTestModel> practiceTests,
    required bool isLoadMore,
    required bool isRefresh,
  }) {
    if (isRefresh) {
      _myPracticeListProvider!.clearOldDataMyTestsList();
    }

    if (isLoadMore) {
      _myPracticeListProvider!.setShowLoadingBottom(false);
      _myPracticeListProvider!.addMyTestsList(practiceTests);
    } else {
      _loading!.hide();
      _myPracticeListProvider!.setMyTestsList(practiceTests);
    }

    _myPracticeListProvider!.setMyPracticeResponseModel(practiceResponseModel);
    _myPracticeListProvider!.setIsProcessing(false);
  }

  @override
  void onGetMyPracticeListError(String message) {
    _loading!.hide();
    _myPracticeListProvider!.setShowLoadingBottom(false);
    _myPracticeListProvider!.setIsProcessing(false);

    String? msg = Utils.multiLanguage(message);

    showDialog(
      context: context,
      builder: (builder) {
        return MessageDialog.alertDialog(context, msg ??= message);
      },
    );
  }

  @override
  void onDeleteMyPracticeError(String message) {
    _loading!.hide();
    _myPracticeListProvider!.setShowLoadingBottom(false);

    String? msg = Utils.multiLanguage(message);

    showDialog(
      context: context,
      builder: (builder) {
        return MessageDialog.alertDialog(context, msg ??= message);
      },
    );
  }

  @override
  void onDeleteMyPracticeSuccess(String message, int indexDeleted) {
    _loading!.hide();

    String? msg = Utils.multiLanguage(message);

    showToastMsg(
      msg: msg ??= message,
      toastState: ToastStatesType.success,
      isCenter: false,
    );
    _myPracticeListProvider!.removeTestAt(indexDeleted);
  }

  @override
  void onGetBankListError(String message) {
    if (kDebugMode) {
      print("DEBUG: getBankListFail");
    }

    //Not show list of bank button or disable this button
    _myPracticeListProvider!.updateStatusShowBankListButton(isShow: false);
  }

  @override
  void onGetBankListSuccess(List<BankModel> banks) {
    if (kDebugMode) {
      print("DEBUG: getBankListSuccess. Banks = ${banks.length}");
    }

    _myPracticeListProvider!.setBankList(banks);
    _myPracticeListProvider!.updateStatusShowBankListButton(isShow: true);
  }

  @override
  bool get wantKeepAlive => true;
}
