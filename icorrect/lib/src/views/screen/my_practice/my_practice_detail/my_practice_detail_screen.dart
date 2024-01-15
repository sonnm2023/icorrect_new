import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/my_practice_test_model/my_practice_test_model.dart';
import 'package:icorrect/src/views/screen/my_practice/my_practice_detail/my_practice_detail_tab.dart';
import 'package:icorrect/src/views/screen/my_practice/my_practice_detail/my_practice_scoring_order_tab.dart';

class MyPracticeDetailScreen extends StatefulWidget {
  final MyPracticeTestModel practice;
  const MyPracticeDetailScreen({required this.practice, super.key});

  @override
  State<MyPracticeDetailScreen> createState() => _MyPracticeDetailScreenState();
}

class _MyPracticeDetailScreenState extends State<MyPracticeDetailScreen>
    with AutomaticKeepAliveClientMixin<MyPracticeDetailScreen> {
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

  @override
  void initState() {
    super.initState();
    _title = "#${widget.practice.id}-${widget.practice.bankTitle}";
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
      home: DefaultTabController(
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
        MyPracticeDetailTab(testId: widget.practice.id.toString()),
        MyPracticeScoringOrderTab(),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
