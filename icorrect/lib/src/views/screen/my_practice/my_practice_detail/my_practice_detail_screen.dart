import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/my_practice_test_model/my_practice_test_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/presenters/my_practice_detail_presenter/my_practice_detail_presenter.dart';
import 'package:icorrect/src/provider/my_practice_detail_provider.dart';
import 'package:icorrect/src/views/other/circle_loading.dart';
import 'package:icorrect/src/views/screen/my_practice/my_practice_detail/my_practice_detail_tab.dart';
import 'package:icorrect/src/views/screen/my_practice/my_practice_detail/my_practice_scoring_order_tab.dart';
import 'package:provider/provider.dart';

class MyPracticeDetailScreen extends StatefulWidget {
  final MyPracticeTestModel practice;
  const MyPracticeDetailScreen({required this.practice, super.key});

  @override
  State<MyPracticeDetailScreen> createState() => _MyPracticeDetailScreenState();
}

class _MyPracticeDetailScreenState extends State<MyPracticeDetailScreen>
    with AutomaticKeepAliveClientMixin<MyPracticeDetailScreen>
    implements MyPracticeDetailViewContract {
  late final String _title;
  List<Widget> _tabsLabel() {
    return [
      Tab(
        child: Text(
          Utils.multiLanguage(StringConstants.my_practice_detail_tab_title)!,
        ),
      ),
      Tab(
        child: Text(
          Utils.multiLanguage(
              StringConstants.my_practice_scoring_order_tab_title)!,
        ),
      ),
    ];
  }

  TabBar get _tabBar {
    return TabBar(
      physics: const BouncingScrollPhysics(),
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 3.0,
          color: AppColor.defaultPurpleColor,
        ),
      ),
      labelColor: AppColor.defaultPurpleColor,
      labelStyle: const TextStyle(
        fontSize: FontsSize.fontSize_16,
        fontWeight: FontWeight.bold,
      ),
      tabs: _tabsLabel(),
    );
  }

  late final MyPracticeDetailPresenter _presenter;
  late MyPracticeDetailProvider _provider;
  CircleLoading? _loading;

  @override
  void initState() {
    super.initState();
    _title = "#${widget.practice.id}-${widget.practice.bankTitle}";
    _presenter = MyPracticeDetailPresenter(this);
    _provider = Provider.of<MyPracticeDetailProvider>(context, listen: false);
    _loading = CircleLoading();
    _getPracticeDetail();
  }

  void _getPracticeDetail() {
    Future.delayed(const Duration(microseconds: 0), () {
      _provider.updateLoadingStatus(value: true);
    });

    String testId = widget.practice.id.toString();
    _presenter.getMyPracticeDetail(
      context: context,
      activityId: "",
      testId: testId,
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_loading != null) {
      _loading = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        tabBarTheme: const TabBarTheme(
          labelColor: AppColor.defaultPurpleColor,
          labelStyle: TextStyle(
            color: AppColor.defaultPurpleColor,
            fontWeight: FontWeight.w800,
          ),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              color: AppColor.defaultPurpleColor,
            ),
          ),
        ),
        primaryColor: AppColor.defaultPurpleColor,
        unselectedWidgetColor:
            AppColor.defaultPurpleColor.withAlpha(5), // deprecated,
      ),
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                elevation: 0.0,
                iconTheme: const IconThemeData(
                  color: AppColor.defaultPurpleColor,
                ),
                centerTitle: true,
                leading: _buildBackButton(),
                title: _buildTitle(),
                bottom: _buildBottomNavigatorTabBar(),
                backgroundColor: AppColor.defaultWhiteColor,
              ),
              body: _buildBody(),
            ),
          ),
          _buildProcessingView(),
        ],
      ),
    );
  }

  Widget _buildProcessingView() {
    return Consumer<MyPracticeDetailProvider>(
      builder: (context, provider, child) {
        if (kDebugMode) {
          print("DEBUG: MyPracticeDetailScreen: update UI with processing");
        }
        if (provider.isLoading) {
          _loading!.show(context: context, isViewAIResponse: false);
        } else {
          _loading!.hide();
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: const Icon(
        Icons.arrow_back_rounded,
        color: AppColor.defaultPurpleColor,
        size: 25,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      _title,
      style: CustomTextStyle.textWithCustomInfo(
        context: context,
        color: AppColor.defaultPurpleColor,
        fontsSize: FontsSize.fontSize_18,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  PreferredSize _buildBottomNavigatorTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(CustomSize.size_40),
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColor.defaultPurpleColor,
            ),
          ),
        ),
        child: _tabBar,
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      children: [
        MyPracticeDetailTab(
          testId: widget.practice.id.toString(),
        ),
        MyPracticeScoringOrderTab(
          presenter: _presenter,
          practice: widget.practice,
        ),
      ],
    );
  }

  @override
  void onGetMyPracticeDetailError(String message) {
    _provider.updateLoadingStatus(value: false);

    //Show error message
    showToastMsg(
      msg: message,
      toastState: ToastStatesType.error,
      isCenter: false,
    );

    Navigator.of(context).pop();
  }

  @override
  void onGetMyPracticeDetailSuccess(TestDetailModel myPracticeDetail) {
    _provider.updateLoadingStatus(value: false);
    _provider.setMyPracticeDetail(value: myPracticeDetail);
  }

  @override
  bool get wantKeepAlive => true;
}
