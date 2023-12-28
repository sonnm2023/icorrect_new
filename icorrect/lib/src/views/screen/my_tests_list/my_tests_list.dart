import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/my_practice_test_model/my_practice_response_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/my_practice_test_model.dart';
import 'package:icorrect/src/presenters/my_tests_list_presenter.dart';
import 'package:icorrect/src/provider/my_tests_list_provider.dart';
import 'package:icorrect/src/views/screen/bank_list/bank_detail_list.dart';
import 'package:icorrect/src/views/screen/my_tests_list/my_practice_test_detail.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/custom_alert_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/message_dialog.dart';
import 'package:icorrect/src/views/widget/divider.dart';
import 'package:provider/provider.dart';

class MyTestsList extends StatefulWidget {
  const MyTestsList({super.key});

  @override
  State<MyTestsList> createState() => _MyTestsListState();
}

class _MyTestsListState extends State<MyTestsList>
    implements MyTestsListConstract {
  double w = 0, h = 0;
  MyTestsListPresenter? _presenter;
  CircleLoading? _loading;
  MyTestsListProvider? _myTestsListProvider;

  @override
  void initState() {
    super.initState();
    _presenter = MyTestsListPresenter(this);
    _loading = CircleLoading();
    _myTestsListProvider =
        Provider.of<MyTestsListProvider>(context, listen: false);

    _getMyTestsList();
  }

  void _getMyTestsList() {
    int pageNum = 1;
    _loading!.show(context: context, isViewAIResponse: false);
    _presenter!.getMyTestLists(pageNum: pageNum, isLoadMore: false);
    Future.delayed(
      Duration.zero,
      () {
        _myTestsListProvider!.setPageNum(pageNum);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: _buildMainScreen(),
              ),
              _buildLoadmore(),
              Container(
                alignment: Alignment.bottomRight,
                margin: const EdgeInsets.all(15),
                child: _buildShowingListBankButton(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShowingListBankButton() {
    return SpeedDial(
      backgroundColor: AppColor.defaultYellowColor,
      overlayColor: Colors.black,
      overlayOpacity: 0.6,
      spaceBetweenChildren: 10,
      activeBackgroundColor: AppColor.defaultYellowColor,
      activeIcon: Icons.close,
      foregroundColor: Colors.white,
      children: [
        SpeedDialChild(
          shape: const CircleBorder(),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BankDetailList(),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(5),
            color: Colors.green,
            child: const Icon(Icons.book_outlined, color: Colors.white),
          ),
          backgroundColor: Colors.green,
          labelWidget: Container(
            margin: const EdgeInsets.only(right: 10),
            child: const Text(
              "Lớp 7 Global Success",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SpeedDialChild(
          shape: const CircleBorder(),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BankDetailList(),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(5),
            color: Colors.orange,
            child: const Text(
              "IELTS",
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          backgroundColor: Colors.orange,
          labelWidget: Container(
            margin: const EdgeInsets.only(right: 10),
            child: const Text(
              "IELTS Bank",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        )
      ],
      child: const Icon(Icons.menu_rounded, color: Colors.white),
    );
  }

  Widget _buildMainScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(
                    Icons.arrow_back_outlined,
                    color: AppColor.defaultPurpleColor,
                    size: 25,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  Utils.multiLanguage(StringConstants.my_test_title),
                  style: CustomTextStyle.textWithCustomInfo(
                    context: context,
                    color: AppColor.defaultPurpleColor,
                    fontsSize: FontsSize.fontSize_18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            ],
          ),
        ),
        const CustomDivider(),
        const SizedBox(height: 20),
        Consumer<MyTestsListProvider>(
          builder: (context, provider, child) {
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
                    MyPracticeTestModel myTestModel =
                        provider.myTestsList[index];
                    return InkWell(
                      onTap: () {
                        _onClickToTestDetail(myTestModel);
                      },
                      child: _myTestItem(myTestModel, index),
                    );
                  },
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Widget _myTestItem(MyPracticeTestModel myTestModel, int index) {
    Map<String, String> dataString = _getMyTestItem(myTestModel.type);
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(color: AppColor.defaultPurpleColor, width: 1),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
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
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dataString[StringConstants.k_title] ?? "",
                    style: CustomTextStyle.textWithCustomInfo(
                      context: context,
                      color: AppColor.defaultPurpleColor,
                      fontsSize: FontsSize.fontSize_16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.av_timer, color: Colors.red),
                      const SizedBox(width: 5),
                      Text(
                        "00:0${myTestModel.duration}",
                        style: CustomTextStyle.textWithCustomInfo(
                          context: context,
                          color: AppColor.defaultGrayColor,
                          fontsSize: FontsSize.fontSize_16,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getDate(myTestModel.createdAt),
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColor.defaultGrayColor,
                  fontsSize: FontsSize.fontSize_15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              InkWell(
                onTap: () {
                  _onClickDeleteTest(myTestModel.id, index);
                },
                child: Text(
                  Utils.multiLanguage(StringConstants.delete_action_title),
                  style: CustomTextStyle.textWithCustomInfo(
                    context: context,
                    color: AppColor.defaultPurpleColor,
                    fontsSize: FontsSize.fontSize_16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLoadmore() {
    return Consumer<MyTestsListProvider>(
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
                    "${Utils.multiLanguage(StringConstants.loading_title)}....",
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
    if (!_myTestsListProvider!.showLoadingBottom) {
      MyPracticeResponseModel practiceResponseModel =
          _myTestsListProvider!.myPracticeResponseModel;
      int pageNum = _myTestsListProvider!.pageNum;
      int lastPage = practiceResponseModel.myPracticeDataModel.lastPage;
      if (pageNum < lastPage) {
        pageNum = pageNum + 1;
        _presenter!.getMyTestLists(pageNum: pageNum, isLoadMore: true);
        _myTestsListProvider!.setPageNum(pageNum);
      } else {
        Future.delayed(
          const Duration(seconds: 1),
          () {
            _myTestsListProvider!.setShowLoadingBottom(false);
          },
        );
      }
      _myTestsListProvider!.setShowLoadingBottom(true);
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

  void _onClickDeleteTest(int testId, int indexDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: Utils.multiLanguage(StringConstants.dialog_title),
          description:
              Utils.multiLanguage(StringConstants.delete_this_test_confirm),
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

  void _onClickToTestDetail(MyPracticeTestModel myTestModel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            MyPracticeTestDetail(testId: myTestModel.id.toString()),
      ),
    );
  }

  @override
  void getMyTestListFail(String message) {
    _loading!.hide();
    _myTestsListProvider!.setShowLoadingBottom(false);

    showDialog(
      context: context,
      builder: (builder) {
        return MessageDialog.alertDialog(context, Utils.multiLanguage(message));
      },
    );
  }

  @override
  void getMyTestsListSuccess(MyPracticeResponseModel practiceResponseModel,
      List<MyPracticeTestModel> practiceTests, bool isLoadMore) {
    if (isLoadMore) {
      _myTestsListProvider!.setShowLoadingBottom(false);
      _myTestsListProvider!.addMyTestsList(practiceTests);
    } else {
      _loading!.hide();
      _myTestsListProvider!.setMyTestsList(practiceTests);
    }

    _myTestsListProvider!.setMyPracticeResponseModel(practiceResponseModel);
  }

  @override
  void deleteTestFail(String message) {
    _loading!.hide();
    _myTestsListProvider!.setShowLoadingBottom(false);
    showDialog(
      context: context,
      builder: (builder) {
        return MessageDialog.alertDialog(context, Utils.multiLanguage(message));
      },
    );
  }

  @override
  void deleteTestSuccess(String message, int indexDeleted) {
    _loading!.hide();
    showToastMsg(
      msg: Utils.multiLanguage(message),
      toastState: ToastStatesType.success,
      isCenter: true,
    );
    _myTestsListProvider!.removeTestAt(indexDeleted);
  }
}
