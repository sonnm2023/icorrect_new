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
import 'package:icorrect/src/provider/ielts_part_list_screen_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/alert_dialog.dart';
import 'package:icorrect/src/views/screen/practice/topics_list/ielts_individual_part_screen.dart';
import 'package:icorrect/src/views/screen/practice/topics_list/ielts_full_part_screen.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/simulator_test_screen.dart';
import 'package:icorrect/src/views/widget/divider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class IELTSPartListScreen extends StatefulWidget {
  IELTSPartListScreen({required this.partType, super.key});
  // List<String> partType;
  IELTSPartType partType;

  @override
  State<IELTSPartListScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<IELTSPartListScreen>
    implements ActionAlertListener {
  IELTSPartListScreenProvider? _provider;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _provider =
        Provider.of<IELTSPartListScreenProvider>(context, listen: false);
    Future.delayed(
      Duration.zero,
      () {
        _provider!.removeAllSelectedTopicList();
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
            title: Consumer<IELTSPartListScreenProvider>(
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
          body: Consumer<IELTSPartListScreenProvider>(
            builder: (context, provider, child) {
              return SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: widget.partType == IELTSPartType.full.get
                          ? const IELTSFullPartScreen()
                          : IELTSIndividualPartScreen(
                              partType: widget.partType,
                            ),
                      // : ChangeNotifierProvider(
                      //     create: (_) =>
                      //         IELTSIndividualPartScreenProvider(),
                      //     child: IELTSIndividualPartScreen(
                      //       partType: widget.partType,
                      //     ),
                      //   ),
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
    switch (widget.partType) {
      case IELTSPartType.part1:
        {
          if (_provider!.selectedTopicIdList.length < 3) {
            showToastMsg(
              msg: Utils.multiLanguage(
                  StringConstants.choose_at_least_3_topics)!,
              toastState: ToastStatesType.warning,
              isCenter: true,
            );
          } else {
            _goToTestScreen();
          }
          break;
        }
      case IELTSPartType.part2:
      case IELTSPartType.part3:
      case IELTSPartType.part2and3:
        {
          _goToTestScreen();
          break;
        }
      case IELTSPartType.full:
        {
          _checkConditionFullPart();
          break;
        }
    }
  }

  void _checkConditionFullPart() {
    // List<TopicId> topicsId = _provider!.selectedTopicIdList;
    // var topicsPart1 = topicsId
    //     .where((element) => element.testOption == IELTSTestOption.part1.get);
    // var topicsPart23 = topicsId.where(
    //     (element) => element.testOption == IELTSTestOption.part2and3.get);
    // if (topicsPart1.length < 3) {
    //   showToastMsg(
    //     msg: Utils.multiLanguage(
    //         StringConstants.choose_at_least_3_topics_at_part1_message)!,
    //     toastState: ToastStatesType.warning,
    //     isCenter: true,
    //   );
    // } else if (topicsPart23.isEmpty) {
    //   showToastMsg(
    //     msg: Utils.multiLanguage(
    //         StringConstants.choose_at_least_1_topics_at_part23_message)!,
    //     toastState: ToastStatesType.warning,
    //     isCenter: true,
    //   );
    // } else {
    //   _goToTestScreen();
    // }
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

  List<int> _convertSelectedTopicIdList() {
    List<int> result = [];
    return result;
  }

  Future<void> _goToTestScreen() async {
    int testOption = Utils.getTestOption(widget.partType);
    List<int> topicIdList = _convertSelectedTopicIdList();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SimulatorTestScreen(
          activitiesModel: null,
          testOption: testOption,
          topicsId: topicIdList,
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
