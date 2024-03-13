// ignore_for_file: must_be_immutable

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/auth_models/topic_id.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/provider/ielts_topics_provider.dart';
import 'package:icorrect/src/provider/ielts_topics_screen_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/alert_dialog.dart';
import 'package:icorrect/src/views/screen/practice/topics_list/ielts_each_part_topics.dart';
import 'package:icorrect/src/views/screen/practice/topics_list/ielts_full_part_topics.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/simulator_test_screen.dart';
import 'package:icorrect/src/views/widget/divider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class IELTSTopicsScreen extends StatefulWidget {
  IELTSTopicsScreen({required this.topicTypes, super.key});
  List<String> topicTypes;

  @override
  State<IELTSTopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<IELTSTopicsScreen>
    implements ActionAlertListener {
  IELTSTopicsScreenProvider? _provider;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<IELTSTopicsScreenProvider>(context, listen: false);
    Future.delayed(
      Duration.zero,
      () {
        _provider!.clearTopicsId();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_provider!.isShowSearchBar) {
          _provider!.setShowSearchBar(!_provider!.isShowSearchBar);
          _provider!.setQueryChanged("");
          return false;
        }
        return true;
      },
      child: DefaultTabController(
        length: 1,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: 50,
            title: Consumer<IELTSTopicsScreenProvider>(
              builder: (context, provider, child) {
                return (provider.isShowSearchBar)
                    ? _buildSearchBar()
                    : Text(
                        StringConstants.topics_screen_title,
                        style: CustomTextStyle.textWithCustomInfo(
                          context: context,
                          color: AppColor.defaultPurpleColor,
                          fontsSize: FontsSize.fontSize_18,
                          fontWeight: FontWeight.w800,
                        ),
                      );
              },
            ),
            actions: [
              IconButton(
                onPressed: () {
                  _provider!.setShowSearchBar(!_provider!.isShowSearchBar);
                },
                icon: const Icon(
                  Icons.search,
                  color: AppColor.defaultPurpleColor,
                ),
              )
            ],
            centerTitle: true,
            elevation: 0.0,
            iconTheme: const IconThemeData(
              color: AppColor.defaultPurpleColor,
            ),
            backgroundColor: AppColor.defaultWhiteColor,
          ),
          body: Consumer<IELTSTopicsScreenProvider>(
            builder: (context, provider, child) {
              return SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: widget.topicTypes == IELTSTopicType.full.get
                          ? IELTSFullPartTopics()
                          : ChangeNotifierProvider(
                              create: (_) => IELTSTopicsProvider(),
                              child: IELTSEachPartTopics(
                                  topicTypes: widget.topicTypes),
                            ),
                    ),
                    Container(
                      height: 50,
                      alignment: Alignment.bottomCenter,
                      child: _startTestButton(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "${Utils.multiLanguage(StringConstants.search_title)}...",
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColor.defaultPurpleColor, width: 2),
        ),
      ),
      autofocus: true,
      cursorColor: AppColor.defaultPurpleColor,
      onEditingComplete: (() => focusNode.requestFocus()),
      onChanged: (query) {
        _provider!.setQueryChanged(query);
      },
    );
  }

  Widget _startTestButton() {
    return InkWell(
      onTap: () {
        if (kDebugMode) {
          print(
              "DEBUG : topics id length: ${_provider!.getTopicsIdList().length}");
          for (int i = 0; i < _provider!.topicsId.length; i++) {
            print("DEBUG : topic id : ${_provider!.topicsId[i].id},"
                " testOption:${_provider!.topicsId[i].testOption} ");
          }
        }
        _onClickStartTest();
      },
      child: Wrap(
        children: [
          Container(
            color: AppColor.defaultWhiteColor,
            child: Column(
              children: [
                const CustomDivider(),
                const SizedBox(height: 10),
                Text(
                  Utils.multiLanguage(StringConstants.start_test_button_title)!,
                  style: CustomTextStyle.textWithCustomInfo(
                    context: context,
                    color: AppColor.defaultPurpleColor,
                    fontsSize: FontsSize.fontSize_16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                const CustomDivider(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future _onClickStartTest() async {
    _requestMicroPermission();
  }

  Future _prepareBeforeToDoTest() async {
    List<TopicId> topicsId = _provider!.topicsId;
    if (widget.topicTypes == IELTSTopicType.part2and3.get) {
      if (topicsId.isNotEmpty) {
        _goToTestScreen();
      } else {
        showToastMsg(
          msg: Utils.multiLanguage(
              StringConstants.choose_at_least_1_topics_at_part23_message)!,
          toastState: ToastStatesType.warning,
          isCenter: true,
        );
      }
    } else if (topicsId.length >= 3 &&
        widget.topicTypes == IELTSTopicType.full.get) {
      _onTopicsIsFullTest();
    } else if (topicsId.length >= 3 &&
        widget.topicTypes != IELTSTopicType.full.get) {
      _goToTestScreen();
    } else {
      showToastMsg(
        msg: Utils.multiLanguage(StringConstants.choose_at_least_3_topics)!,
        toastState: ToastStatesType.warning,
        isCenter: true,
      );
    }
  }

  void _onTopicsIsFullTest() {
    List<TopicId> topicsId = _provider!.topicsId;
    var topicsPart1 = topicsId
        .where((element) => element.testOption == IELTSTestOption.part1.get);
    if (topicsPart1.length < 3) {
      showToastMsg(
        msg: Utils.multiLanguage(
            StringConstants.choose_at_least_3_topics_at_part1_message)!,
        toastState: ToastStatesType.warning,
        isCenter: true,
      );
    } else {
      _goToTestScreen();
    }
  }

  Future _requestMicroPermission() async {
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
        if (_provider!.permissionDeniedTime >= 1) {
          _showConfirmDeniedDialog(AlertClass.microPermissionAlert);
        } else {
          _provider!.setPermissionDeniedTime();
        }
      } else {
        _provider!.resetPermissionDeniedTime();
        _prepareBeforeToDoTest();
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("DEBUG: Permission error ${e.toString()}");
      }
    }
  }

  void _showConfirmDeniedDialog(AlertInfo alertInfo) {
    if (false == _provider!.dialogShowing) {
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
      _provider!.setDialogShowing(true);
    }
  }

  Future<void> _goToTestScreen() async {
    int testOption = Utils.getTestOption(widget.topicTypes);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SimulatorTestScreen(
          activitiesModel: null,
          testOption: testOption,
          topicsId: _provider!.getTopicsIdList(),
          isPredict: IELTSPredict.normalQuestion.get,
          testDetail: null,
          onRefresh: null,
        ),
      ),
    );
  }

  @override
  void onAlertExit(String keyInfo) {
    _provider!.setDialogShowing(false);
  }

  @override
  void onAlertNextStep(String keyInfo) {
    _provider!.setDialogShowing(false);
    openAppSettings();
  }
}
