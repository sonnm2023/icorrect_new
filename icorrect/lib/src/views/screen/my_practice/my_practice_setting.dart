import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/models/my_practice_test_model/bank_model.dart';
import 'package:icorrect/src/presenters/my_practice_setting_presenter.dart';
import 'package:icorrect/src/views/screen/my_practice/my_practice_setting/setting_tab.dart';
import 'package:icorrect/src/views/screen/my_practice/my_practice_setting/topic_list_tab.dart';

class MyPracticeSettingScreen extends StatefulWidget {
  const MyPracticeSettingScreen({super.key, required this.selectedBank});

  final BankModel selectedBank;

  @override
  State<MyPracticeSettingScreen> createState() =>
      _MyPracticeSettingScreenState();
}

class _MyPracticeSettingScreenState extends State<MyPracticeSettingScreen>
    implements MyPracticeSettingViewContract {
  TabBar get _tabBar {
    return TabBar(
      physics: const BouncingScrollPhysics(),
      isScrollable: false,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 3.0,
          color: AppColor.defaultPurpleColor,
        ),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: AppColor.defaultPurpleColor,
      labelStyle: const TextStyle(
        fontSize: FontsSize.fontSize_16,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelColor: AppColor.defaultBlackColor,
      tabs: _tabsLabel(),
    );
  }

  @override
  void initState() {
    super.initState();
    // _homeWorkPresenter = HomeWorkPresenter(this);

    // _homeWorkProvider = Provider.of<HomeWorkProvider>(context, listen: false);
    // _simulatorTestProvider =
    //     Provider.of<SimulatorTestProvider>(context, listen: false);
    // _authProvider = Provider.of<AuthProvider>(context, listen: false);

    // _getListHomeWork();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: GlobalScaffoldKey.myTestScaffoldKey,
        appBar: AppBar(
          elevation: 0.0,
          iconTheme: const IconThemeData(
            color: AppColor.defaultPurpleColor,
          ),
          centerTitle: true,
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            widget.selectedBank.title!,
            style: CustomTextStyle.textWithCustomInfo(
              context: context,
              color: AppColor.defaultPurpleColor,
              fontsSize: FontsSize.fontSize_18,
              fontWeight: FontWeight.w800,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(CustomSize.size_50),
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
          ),
          backgroundColor: AppColor.defaultWhiteColor,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TabBarView(
                children: _tabBarView(),
              ),
            ),
            InkWell(
              onTap: () {
                if (kDebugMode) {
                  print("DEBUG: Start to practice");
                }
              },
              child: Container(
                width: screenWidth,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColor.defaultPurpleColor,
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Bắt đầu luyện tập",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: FontsSize.fontSize_16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _tabsLabel() {
    return [
      Tab(
        child: Text(
          "Topics",
        ),
      ),
      Tab(
        child: Text(
          // Utils.multiLanguage(StringConstants.response_tab_title),
          "Setting",
        ),
      ),
    ];
  }

  _tabBarView() {
    return [
      TopicListTabScreen(),
      SettingTabScreen(),
    ];
  }
}
