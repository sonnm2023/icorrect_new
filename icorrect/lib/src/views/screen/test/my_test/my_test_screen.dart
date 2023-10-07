import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/provider/my_test_provider.dart';
import 'package:icorrect/src/views/screen/home/homework_screen.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/confirm_dialog.dart';
import 'package:icorrect/src/views/screen/test/my_test/highlight_tab.dart';
import 'package:icorrect/src/views/screen/test/my_test/my_test_tab.dart';
import 'package:icorrect/src/views/screen/test/my_test/others_tab.dart';
import 'package:icorrect/src/views/screen/test/my_test/response_tab.dart';
import 'package:provider/provider.dart';

class MyTestScreen extends StatefulWidget {
  const MyTestScreen(
      {super.key,
      required this.homeWorkModel,
      required this.isFromSimulatorTest});

  final ActivitiesModel homeWorkModel;
  final bool isFromSimulatorTest;

  @override
  State<MyTestScreen> createState() => _MyTestScreenState();
}

class _MyTestScreenState extends State<MyTestScreen> {
  MyTestProvider? _myTestProvider;
  AuthProvider? _authProvider;

  TabBar get _tabBar {
    bool hasTeacherResponse = widget.homeWorkModel.activityAnswer != null &&
        widget.homeWorkModel.activityAnswer!.hasTeacherResponse();
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
    super.dispose();
    _myTestProvider!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasTeacherResponse = widget.homeWorkModel.activityAnswer != null &&
        widget.homeWorkModel.activityAnswer!.hasTeacherResponse();
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
          title: const Text(
            "ICORRECT",
            style: CustomTextStyle.appbarTitle,
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
    return widget.homeWorkModel.activityAnswer!.hasTeacherResponse()
        ? const [
            Tab(
              child: Text(
                'MY EXAM',
                style: TextStyle(
                  fontSize: FontsSize.fontSize_14,
                ),
              ),
            ),
            Tab(
              child: Text(
                'RESPONSE',
                style: TextStyle(
                  fontSize: FontsSize.fontSize_14,
                ),
              ),
            ),
            Tab(
              child: Text(
                'HIGHLIGHT',
                style: TextStyle(
                  fontSize: FontsSize.fontSize_14,
                ),
              ),
            ),
            Tab(
              child: Text(
                'OTHERS',
                style: TextStyle(
                  fontSize: FontsSize.fontSize_14,
                ),
              ),
            ),
          ]
        : const [
            Tab(
              child: Text(
                'MY EXAM',
                style: TextStyle(
                  fontSize: FontsSize.fontSize_14,
                ),
              ),
            ),
            Tab(
              child: Text(
                'HIGHLIGHT',
                style: TextStyle(
                  fontSize: FontsSize.fontSize_14,
                ),
              ),
            ),
            Tab(
              child: Text(
                'OTHERS',
                style: TextStyle(
                  fontSize: FontsSize.fontSize_14,
                ),
              ),
            ),
          ];
  }

  _tabBarView() {
    if (kDebugMode) {
      print(
        'DEBUG: test id: ${widget.homeWorkModel.activityAnswer!.testId.toString()}',
      );
    }
    return widget.homeWorkModel.activityAnswer!.hasTeacherResponse()
        ? [
            MyTestTab(
                homeWorkModel: widget.homeWorkModel,
                provider: _myTestProvider!),
            ResponseTab(
                homeWorkModel: widget.homeWorkModel,
                provider: _myTestProvider!),
            HighLightTab(
                provider: _myTestProvider!,
                homeWorkModel: widget.homeWorkModel),
            OtherTab(
                provider: _myTestProvider!,
                homeWorkModel: widget.homeWorkModel),
          ]
        : [
            MyTestTab(
                homeWorkModel: widget.homeWorkModel,
                provider: _myTestProvider!),
            HighLightTab(
                provider: _myTestProvider!,
                homeWorkModel: widget.homeWorkModel),
            OtherTab(
                provider: _myTestProvider!,
                homeWorkModel: widget.homeWorkModel),
          ];
  }

  void _showDialogConfirmToOutScreen({required MyTestProvider provider}) {
    showDialog(
      context: context,
      builder: (builder) {
        return ConfirmDialogWidget(
          title: "Are you sure to back ?",
          message: "Your re-answers will not be saved ",
          cancelButtonTitle: "Cancel",
          okButtonTitle: "Back",
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
