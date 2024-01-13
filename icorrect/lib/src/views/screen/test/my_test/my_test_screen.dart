import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/provider/my_test_provider.dart';
import 'package:icorrect/src/views/other/confirm_dialog.dart';
import 'package:icorrect/src/views/screen/home/homework_screen.dart';
import 'package:icorrect/src/views/screen/test/my_test/highlight_tab.dart';
import 'package:icorrect/src/views/screen/test/my_test/my_test_tab.dart';
import 'package:icorrect/src/views/screen/test/my_test/others_tab.dart';
import 'package:icorrect/src/views/screen/test/my_test/response_tab.dart';
import 'package:provider/provider.dart';

class MyTestScreen extends StatefulWidget {
  const MyTestScreen(
      {super.key,
      required this.activitiesModel,
      required this.isFromSimulatorTest});

  final ActivitiesModel activitiesModel;
  final bool isFromSimulatorTest;

  @override
  State<MyTestScreen> createState() => _MyTestScreenState();
}

class _MyTestScreenState extends State<MyTestScreen> {
  MyTestProvider? _myTestProvider;
  AuthProvider? _authProvider;

  TabBar get _tabBar {
    bool hasTeacherResponse = widget.activitiesModel.activityAnswer != null &&
        widget.activitiesModel.activityAnswer!.hasTeacherResponse();
    return TabBar(
      physics: const BouncingScrollPhysics(),
      isScrollable: hasTeacherResponse ? true : false,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 3.0,
          color: AppColor.defaultPurpleColor,
        ),
      ),
      tabs: _tabsLabel(),
    );
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _myTestProvider = Provider.of<MyTestProvider>(
      context,
      listen: false,
    );
    _authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    Future.delayed(
      Duration.zero,
      () {
        _myTestProvider!.clearData();
        _authProvider!.setGlobalScaffoldKey(
          GlobalScaffoldKey.myTestScaffoldKey,
        );
      },
    );
  }

  @override
  void dispose() {
    _myTestProvider!.clearData();
    super.dispose();
    // _myTestProvider!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasTeacherResponse = widget.activitiesModel.activityAnswer != null &&
        widget.activitiesModel.activityAnswer!.hasTeacherResponse();
    return DefaultTabController(
      length: hasTeacherResponse ? 4 : 3,
      child: Scaffold(
        key: GlobalScaffoldKey.myTestScaffoldKey,
        appBar: AppBar(
          elevation: 0.0,
          iconTheme: const IconThemeData(
            color: AppColor.defaultPurpleColor,
          ),
          centerTitle: true,
          leading: Consumer<MyTestProvider>(
            builder: (context, myTestprovider, child) {
              return BackButton(
                onPressed: () {
                  if (myTestprovider.reAnswerOfQuestions.isNotEmpty) {
                    _showDialogConfirmToOutScreen(provider: myTestprovider);
                  } else {
                    if (widget.isFromSimulatorTest) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => HomeWorkScreen(),
                        ),
                        (route) => false,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  }
                },
              );
            },
          ),
          title: Text(
            StringConstants.icorrect_title,
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
        body: TabBarView(
          children: _tabBarView(),
        ),
      ),
    );
  }

  List<Widget> _tabsLabel() {
    return widget.activitiesModel.activityAnswer!.hasTeacherResponse()
        ? [
            Tab(
              child: Text(
                Utils.multiLanguage(StringConstants.my_exam_tab_title)!,
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColor.defaultBlackColor,
                  fontsSize: FontsSize.fontSize_14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Tab(
              child: Text(
                Utils.multiLanguage(StringConstants.response_tab_title)!,
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColor.defaultBlackColor,
                  fontsSize: FontsSize.fontSize_14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Tab(
              child: Text(
                Utils.multiLanguage(StringConstants.highlight_tab_title)!,
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColor.defaultBlackColor,
                  fontsSize: FontsSize.fontSize_14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Tab(
              child: Text(
                Utils.multiLanguage(StringConstants.others_tab_title)!,
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColor.defaultBlackColor,
                  fontsSize: FontsSize.fontSize_14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ]
        : [
            Tab(
              child: Text(
                Utils.multiLanguage(StringConstants.my_exam_tab_title)!,
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColor.defaultBlackColor,
                  fontsSize: FontsSize.fontSize_14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Tab(
              child: Text(
                Utils.multiLanguage(StringConstants.highlight_tab_title)!,
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColor.defaultBlackColor,
                  fontsSize: FontsSize.fontSize_14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Tab(
              child: Text(
                Utils.multiLanguage(StringConstants.others_tab_title)!,
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColor.defaultBlackColor,
                  fontsSize: FontsSize.fontSize_14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ];
  }

  _tabBarView() {
    if (kDebugMode) {
      print(
        'DEBUG: test id: ${widget.activitiesModel.activityAnswer!.testId.toString()}',
      );
    }
    return widget.activitiesModel.activityAnswer!.hasTeacherResponse()
        ? [
            MyTestTab(
                homeWorkModel: widget.activitiesModel,
                practiceTestId: null,
                provider: _myTestProvider!),
            ResponseTab(
                homeWorkModel: widget.activitiesModel,
                provider: _myTestProvider!),
            HighLightTab(
                provider: _myTestProvider!,
                homeWorkModel: widget.activitiesModel),
            OtherTab(
                provider: _myTestProvider!,
                homeWorkModel: widget.activitiesModel),
          ]
        : [
            MyTestTab(
                homeWorkModel: widget.activitiesModel,
                practiceTestId: null,
                provider: _myTestProvider!),
            HighLightTab(
                provider: _myTestProvider!,
                homeWorkModel: widget.activitiesModel),
            OtherTab(
                provider: _myTestProvider!,
                homeWorkModel: widget.activitiesModel),
          ];
  }

  void _showDialogConfirmToOutScreen({required MyTestProvider provider}) {
    showDialog(
      context: context,
      builder: (builder) {
        return ConfirmDialogWidget(
          title: Utils.multiLanguage(StringConstants.confirm_to_go_out_screen)!,
          message: Utils.multiLanguage(
              StringConstants.re_answer_not_be_save_message)!,
          cancelButtonTitle:
              Utils.multiLanguage(StringConstants.cancel_button_title)!,
          okButtonTitle:
              Utils.multiLanguage(StringConstants.back_button_title)!,
          cancelButtonTapped: () {},
          okButtonTapped: () {
            deleteFileAnswers(provider.reAnswerOfQuestions);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future deleteFileAnswers(List<QuestionTopicModel> questions) async {
    for (var q in questions) {
      if (q.answers.isNotEmpty) {
        String fileName = q.answers.last.url.toString();
        FileStorageHelper.deleteFile(fileName, MediaType.audio, null);
      }
    }
  }
}
