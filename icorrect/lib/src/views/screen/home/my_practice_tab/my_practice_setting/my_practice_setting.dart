import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/my_practice_test_model/bank_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/bank_topic_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/setting_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/presenters/my_practice_setting_presenter.dart';
import 'package:icorrect/src/provider/my_practice_list_provider.dart';
import 'package:icorrect/src/views/screen/home/my_practice_tab/my_practice_setting/setting_tab.dart';
import 'package:icorrect/src/views/screen/home/my_practice_tab/my_practice_setting/topic_list_tab.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/alert_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/simulator_test_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class MyPracticeSettingScreen extends StatefulWidget {
  const MyPracticeSettingScreen(
      {super.key, required this.selectedBank, required this.onRefresh});

  final BankModel selectedBank;
  final Function onRefresh;

  @override
  State<MyPracticeSettingScreen> createState() =>
      _MyPracticeSettingScreenState();
}

class _MyPracticeSettingScreenState extends State<MyPracticeSettingScreen>
    with
        AutomaticKeepAliveClientMixin<MyPracticeSettingScreen>,
        SingleTickerProviderStateMixin
    implements ActionAlertListener, MyPracticeSettingViewContract {
  // late TabController _tabController;

  MyPracticeSettingPresenter? _myPracticeSettingPresenter;
  MyPracticeListProvider? _practiceListProvider;
  bool isCheckingData = false;
  CircleLoading? _loading;

  @override
  void initState() {
    super.initState();
    // _tabController = TabController(vsync: this, length: 2);

    _myPracticeSettingPresenter = MyPracticeSettingPresenter(this);
    _practiceListProvider =
        Provider.of<MyPracticeListProvider>(context, listen: false);
    _loading = CircleLoading();
  }

  @override
  void dispose() {
    // _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double screenWidth = MediaQuery.of(context).size.width;

    if (kDebugMode) {
      print("DEBUG: MyPracticeSettingScreen - build");
    }

    return Stack(
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
                    // controller: _tabController,
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
                    if (_practiceListProvider!.settings.isEmpty) {
                      _practiceListProvider!.initSettings();
                    }

                    if (isCheckingData == false) {
                      bool isValidData = _checkSettings();
                      if (isValidData) {
                        _prepareData();
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
                      Utils.multiLanguage(StringConstants.start_to_pratice)!,
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
        ),
        Consumer<MyPracticeListProvider>(
          builder: (context, provider, child) {
            if (provider.isTestDetailLoading) {
              _loading!.show(context: context, isViewAIResponse: false);
            } else {
              _loading!.hide();
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  List<Widget> _tabsLabel() {
    return [
      Tab(
        child: Text(
          Utils.multiLanguage(StringConstants.topic_tab_title)!,
        ),
      ),
      Tab(
        child: Text(
          Utils.multiLanguage(StringConstants.practice_setting)!,
        ),
      ),
    ];
  }

  bool _checkSettings() {
    //Check selected topics
    int selectedTopics = _practiceListProvider!.getTotalSelectedSubTopics();
    if (selectedTopics == 0) {
      isCheckingData = true;
      showToastMsg(
        msg: Utils.multiLanguage(
            StringConstants.my_practice_selected_topic_error_message)!,
        toastState: ToastStatesType.warning,
        isCenter: true,
      );
      Future.delayed(const Duration(seconds: 1), () {
        isCheckingData = false;
      });
      return false;
    }

    //Check setting: number of topics
    double settingNumberOfTopics = _practiceListProvider!.settings[0].value;
    if (settingNumberOfTopics == 0) {
      showToastMsg(
        msg: Utils.multiLanguage(
            StringConstants.my_practice_setting_number_topic_error_message)!,
        toastState: ToastStatesType.warning,
        isCenter: true,
      );
      return false;
    }

    //Check number question of part 1, part 2
    double numberQuestionPart1 = _practiceListProvider!.settings[1].value;
    double numberQuestionPart2 = _practiceListProvider!.settings[2].value;

    if (numberQuestionPart1 == 0 && numberQuestionPart2 == 0) {
      showToastMsg(
        msg: Utils.multiLanguage(
            StringConstants.my_practice_setting_number_question_error_message)!,
        toastState: ToastStatesType.warning,
        isCenter: true,
      );
      return false;
    }

    //Check take note time
    double takeNoteTime = _practiceListProvider!.settings[3].value;
    if (takeNoteTime == 0) {
      showToastMsg(
        msg: Utils.multiLanguage(
            StringConstants.my_practice_setting_take_note_time_error_message)!,
        toastState: ToastStatesType.warning,
        isCenter: true,
      );
      return false;
    }

    //Save setting list into local
    _practiceListProvider!.saveSettingList(_practiceListProvider!.settings);

    return true;
  }

  void _prepareData() {
    String bank_code = widget.selectedBank.bankDistributeCode!;
    int amount_topics = _practiceListProvider!.settings[0].value.toInt();
    int amount_questions_part1 =
        _practiceListProvider!.settings[1].value.toInt();
    int amount_questions_part2 =
        _practiceListProvider!.settings[2].value.toInt();
    double take_note_time =
        _practiceListProvider!.settings[3].value.toPrecision(2);
    ;
    double normal_speed =
        1.0; //_practiceListProvider!.settings[4].value.toPrecision(2);
    double first_repeat_speed =
        1.0; //_practiceListProvider!.settings[5].value.toPrecision(2);
    double second_repeat_speed =
        1.0; //_practiceListProvider!.settings[6].value.toPrecision(2);

    List<int> topics = [];
    List<int> subTopics = [];

    for (int i = 0; i < _practiceListProvider!.topics.length; i++) {
      Topic t = _practiceListProvider!.topics[i];
      if (t.isSelected) {
        topics.add(t.id!);
      }

      if (t.subTopics!.isNotEmpty) {
        for (int j = 0; j < t.subTopics!.length; j++) {
          SubTopics s = t.subTopics![j];
          if (s.isSelected) {
            if (!subTopics.contains(s.id)) {
              subTopics.add(s.id!);
            }

            if (!topics.contains(t.id!)) {
              topics.add(t.id!);
            }
          }
        }
      }
    }

    Map<String, dynamic> data = {};
    data["bank_code"] = bank_code;
    data["amount_topics"] = amount_topics;
    data["amount_questions_part1"] = amount_questions_part1;
    data["amount_questions_part2"] = amount_questions_part2;
    data["take_note_time"] = take_note_time;
    data["normal_speed"] = normal_speed;
    data["first_repeat_speed"] = first_repeat_speed;
    data["second_repeat_speed"] = second_repeat_speed;
    data["topics"] = topics;
    data["sub_topics"] = subTopics;
    data["lang"] = Utils.getCurrentLanguage()[StringConstants.k_data]
        .toString()
        .toLowerCase();

    _onClickStartToPractice(data);
  }

  Future _onClickStartToPractice(Map<String, dynamic> data) async {
    if (kDebugMode) {
      print("DEBUG: _onClickStartToPractice");
    }
    _requestMicroPermission(data);
  }

  Future _requestMicroPermission(Map<String, dynamic> data) async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
      ].request();

      if (statuses[Permission.microphone]! ==
          PermissionStatus.permanentlyDenied) {
        _showConfirmDeniedDialog(AlertClass.microPermissionAlert);
        return;
      }

      if (statuses[Permission.microphone]! == PermissionStatus.denied) {
        if (_practiceListProvider!.permissionDeniedTime >= 1) {
          _showConfirmDeniedDialog(AlertClass.microPermissionAlert);
        } else {
          _practiceListProvider!.setPermissionDeniedTime();
        }
      } else {
        _practiceListProvider!.resetPermissionDeniedTime();
        _getTestDetail(data);
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("DEBUG: Permission error ${e.toString()}");
      }
    }
  }

  void _showConfirmDeniedDialog(AlertInfo alertInfo) {
    if (false == _practiceListProvider!.dialogShowing) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertsDialog.init().showDialog(
            context,
            alertInfo,
            this,
            keyInfo: StringClass.permissionDenied,
          );
        },
      );
      _practiceListProvider!.setDialogShowing(true);
    }
  }

  void _getTestDetail(Map<String, dynamic> data) {
    _practiceListProvider!.setIsTestDetailLoading(true);
    _myPracticeSettingPresenter!
        .getTestDetailFromMyPractice(context: context, data: data);
  }

  Future<void> _goToTestScreen(TestDetailModel testDetail) async {
    if (kDebugMode) {
      print("DEBUG: _goToTestScreen $testDetail");
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SimulatorTestScreen(
          activitiesModel: null,
          testOption: null,
          topicsId: null,
          isPredict: null,
          testDetail: testDetail,
          onRefresh: widget.onRefresh,
        ),
      ),
    );
  }

  @override
  void onGetTestDetailError(String message) {
    _practiceListProvider!.setIsTestDetailLoading(false);
    if (kDebugMode) {
      print("DEBUG: onGetTestDetailError");
    }

    if (null != _loading) {
      _loading!.hide();
    }

    String? msg = Utils.multiLanguage(message);

    showToastMsg(
      msg: msg ??= message,
      toastState: ToastStatesType.error,
      isCenter: true,
    );
  }

  @override
  void onGetTestDetailSuccess(TestDetailModel testDetail) {
    _practiceListProvider!.setIsTestDetailLoading(false);
    _goToTestScreen(testDetail);
  }

  @override
  void onAlertExit(String keyInfo) {}

  @override
  void onAlertNextStep(String keyInfo) {}

  @override
  bool get wantKeepAlive => true;
}

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}
