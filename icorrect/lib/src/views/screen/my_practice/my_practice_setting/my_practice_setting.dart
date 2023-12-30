import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/my_practice_test_model/bank_model.dart';
import 'package:icorrect/src/provider/my_practice_topics_provider.dart';
import 'package:icorrect/src/views/screen/my_practice/my_practice_setting/setting_tab.dart';
import 'package:icorrect/src/views/screen/my_practice/my_practice_setting/topic_list_tab.dart';
import 'package:provider/provider.dart';

class MyPracticeSettingScreen extends StatefulWidget {
  const MyPracticeSettingScreen({super.key, required this.selectedBank});

  final BankModel selectedBank;

  @override
  State<MyPracticeSettingScreen> createState() =>
      _MyPracticeSettingScreenState();
}

class _MyPracticeSettingScreenState extends State<MyPracticeSettingScreen>
    with
        AutomaticKeepAliveClientMixin<MyPracticeSettingScreen>,
        SingleTickerProviderStateMixin {
  late TabController _tabController;

  MyPracticeTopicsProvider? _myPracticeTopicsProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(_handleTabChange);
    _myPracticeTopicsProvider =
        Provider.of<MyPracticeTopicsProvider>(context, listen: false);
  }

  void _handleTabChange() {
    _tabController.animateTo(0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: GlobalScaffoldKey.myPracticeSettingScreenScaffoldKey,
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
              child: TabBar(
                controller: _tabController,
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
              ),
            ),
          ),
          backgroundColor: AppColor.defaultWhiteColor,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  TopicListTabScreen(
                    selectedBank: widget.selectedBank,
                  ),
                  const SettingTabScreen(),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                bool isValidData = _checkSettings();
                if (isValidData) {
                  if (kDebugMode) {
                    print("DEBUG: Start to do practice");
                  }
                }
              },
              child: Container(
                width: screenWidth,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColor.defaultPurpleColor,
                ),
                alignment: Alignment.center,
                child: Text(
                  Utils.multiLanguage(StringConstants.start_to_pratice),
                  style: const TextStyle(
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
          Utils.multiLanguage(StringConstants.topic_tab_title),
        ),
      ),
      Tab(
        child: Text(
          Utils.multiLanguage(StringConstants.practice_setting),
        ),
      ),
    ];
  }

  bool _checkSettings() {
    //Check selected topics
    int selectedTopics = _myPracticeTopicsProvider!.getTotalSelectedSubTopics();
    if (selectedTopics == 0) {
      showToastMsg(
        msg: Utils.multiLanguage(
            StringConstants.my_practice_selected_topic_error_message),
        toastState: ToastStatesType.warning,
        isCenter: true,
      );
      return false;
    }

    //Check setting: number of topics
    double settingNumberOfTopics = _myPracticeTopicsProvider!.settings[0].value;
    if (settingNumberOfTopics == 0) {
      showToastMsg(
        msg: Utils.multiLanguage(
            StringConstants.my_practice_setting_number_topic_error_message),
        toastState: ToastStatesType.warning,
        isCenter: true,
      );
      return false;
    }

    //Check number question of part 1, part 2
    double numberQuestionPart1 = _myPracticeTopicsProvider!.settings[1].value;
    double numberQuestionPart2 = _myPracticeTopicsProvider!.settings[2].value;

    if (numberQuestionPart1 == 0 && numberQuestionPart2 == 0) {
      showToastMsg(
        msg: Utils.multiLanguage(
            StringConstants.my_practice_setting_number_question_error_message),
        toastState: ToastStatesType.warning,
        isCenter: true,
      );
      return false;
    }

    //Check take note time
    double takeNoteTime = _myPracticeTopicsProvider!.settings[3].value;
    if (takeNoteTime == 0) {
      showToastMsg(
        msg: Utils.multiLanguage(
            StringConstants.my_practice_setting_take_note_time_error_message),
        toastState: ToastStatesType.warning,
        isCenter: true,
      );
      return false;
    }

    return true;
  }

  @override
  bool get wantKeepAlive => true;
}
