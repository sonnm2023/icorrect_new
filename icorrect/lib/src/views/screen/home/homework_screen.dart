import 'dart:io';
import 'dart:core';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:provider/provider.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/provider/homework_provider.dart';
import 'package:icorrect/src/presenters/homework_presenter.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:icorrect/src/views/screen/home/my_homework_tab.dart';
import 'package:icorrect/src/presenters/simulator_test_presenter.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/new_class_model.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/custom_alert_dialog.dart';
import 'package:workmanager/workmanager.dart';

import '../video_authentication/submit_video_auth.dart';

class HomeWorkScreen extends StatefulWidget {
  final scaffoldKey = GlobalScaffoldKey.homeScreenScaffoldKey;

  HomeWorkScreen({super.key});

  @override
  State<HomeWorkScreen> createState() => _HomeWorkScreenState();
}

class _HomeWorkScreenState extends State<HomeWorkScreen>
    implements HomeWorkViewContract {
  // TabBar get _tabBar => const TabBar(
  //       indicatorColor: defaultPurpleColor,
  //       tabs: [
  //         Tab(text: 'MY HOMEWORK'),
  //         Tab(text: 'NEXT HOMEWORK'),
  //       ],
  //     );

  HomeWorkPresenter? _homeWorkPresenter;
  late HomeWorkProvider _homeWorkProvider;
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _homeWorkPresenter = HomeWorkPresenter(this);

    _homeWorkProvider = Provider.of<HomeWorkProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    _getListHomeWork();

    //Send log if has
    _sendLog();
  }

  void _sendLog() {
    Workmanager().registerOneOffTask(
      sendLogsTask,
      sendLogsTask,
    );
  }

  void _getListHomeWork() {
    //Reset old data
    _homeWorkProvider.updateFilterString(StringConstants.add_your_filter);
    _homeWorkProvider.resetListSelectedClassFilter();
    _homeWorkProvider.resetListSelectedStatusFilter();
    _homeWorkProvider.resetListSelectedFilterIntoLocal();
    _homeWorkProvider.resetListHomeworks();
    _homeWorkProvider.resetListClassForFilter();
    _homeWorkProvider.resetListFilteredHomeWorks();

    _homeWorkPresenter!.getListHomeWork(context);

    Future.delayed(Duration.zero, () {
      _authProvider
          .setGlobalScaffoldKey(GlobalScaffoldKey.homeScreenScaffoldKey);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_authProvider.isShowDialog) {
          GlobalKey<ScaffoldState> key = _authProvider.globalScaffoldKey;
          _authProvider.setShowDialogWithGlobalScaffoldKey(false, key);

          Navigator.of(key.currentState!.context).pop();
        } else if (Provider.of<SimulatorTestProvider>(context, listen: false)
                .doingStatus ==
            DoingStatus.doing) {
          _showQuitTheTestConfirmDialog();
        } else {
          Queue<GlobalKey<ScaffoldState>> scaffoldKeys =
              _authProvider.scaffoldKeys;
          GlobalKey<ScaffoldState> key = scaffoldKeys.first;
          if (key == GlobalScaffoldKey.homeScreenScaffoldKey) {
            _showQuitAppConfirmDialog();
          } else {
            Navigator.of(key.currentState!.context).pop();
            scaffoldKeys.removeFirst();
          }
        }

        return false;
      },
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          // add tabBarTheme
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
          length: 1,
          child: Scaffold(
            key: widget.scaffoldKey,
            appBar: AppBar(
              title: const Text(
                StringConstants.my_homework_screen_title,
                style: CustomTextStyle.appbarTitle,
              ),
              centerTitle: true,
              elevation: 0.0,
              iconTheme: const IconThemeData(
                color: AppColor.defaultPurpleColor,
              ),
              backgroundColor: AppColor.defaultWhiteColor,
            ),
            body: Stack(
              children: [
                MyHomeWorkTab(
                  homeWorkProvider: _homeWorkProvider,
                  homeWorkPresenter: _homeWorkPresenter!,
                  pullToRefreshCallBack: _pullToRefresh,
                ),
                Consumer<HomeWorkProvider>(
                  builder: (context, homeWorkProvider, child) {
                    if (kDebugMode) {
                      print(
                          "DEBUG: HomeworkScreen: update UI with processing: ${homeWorkProvider.isProcessing}");
                    }
                    if (homeWorkProvider.isProcessing) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.black.withOpacity(0.2),
                        child: Center(
                          child: Container(
                            width: 50,
                            height: 50,
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                                color: Colors.white),
                            child: const CircularProgressIndicator(
                              strokeWidth: 4,
                              backgroundColor: AppColor.defaultLightGrayColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColor.defaultPurpleColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
            drawer: Utils.navbar(
                context: context, homeWorkPresenter: _homeWorkPresenter),
            drawerEnableOpenDragGesture: false,
          ),
        ),
      ),
    );
  }

  Future<void> _pullToRefresh() async {
    if (kDebugMode) {
      print("DEBUG: HomeWorkScreen - _pullToRefresh");
    }
    _getListHomeWork();
  }

  void _showQuitAppConfirmDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: StringConstants.dialog_title,
          description: StringConstants.exit_app_message,
          okButtonTitle: StringConstants.ok_button_title,
          cancelButtonTitle: StringConstants.cancel_button_title,
          borderRadius: 8,
          hasCloseButton: false,
          okButtonTapped: () {
            exit(0);
          },
          cancelButtonTapped: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _handleEventBackButtonSystem({required bool isQuitTheTest}) {
    SimulatorTestPresenter? presenter =
        Provider.of<HomeWorkProvider>(context, listen: false)
            .simulatorTestPresenter;
    if (null == presenter) return;

    presenter.handleEventBackButtonSystem(isQuitTheTest: isQuitTheTest);
  }

  void _showQuitTheTestConfirmDialog() async {
    SimulatorTestPresenter? presenter =
        Provider.of<HomeWorkProvider>(context, listen: false)
            .simulatorTestPresenter;

    if (null == presenter) return;

    presenter.handleBackButtonSystemTapped();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: StringConstants.dialog_title,
          description: StringConstants.quit_the_test_message,
          okButtonTitle: StringConstants.ok_button_title,
          cancelButtonTitle: StringConstants.cancel_button_title,
          borderRadius: 8,
          hasCloseButton: false,
          okButtonTapped: () {
            _handleEventBackButtonSystem(isQuitTheTest: true);
          },
          cancelButtonTapped: () {
            Navigator.of(context).pop();
            _handleEventBackButtonSystem(isQuitTheTest: false);
          },
        );
      },
    );
  }

  @override
  void onGetListHomeworkError(String message) {
    _homeWorkProvider.setProcessingStatus(isProcessing: false);

    //Show error message
    showToastMsg(
      msg: message,
      toastState: ToastStatesType.error,
    );
  }

  @override
  void onLogoutComplete() {
    _homeWorkProvider.setProcessingStatus(isProcessing: false);

    _sendLog();

    Navigator.of(context).pop();
  }

  @override
  void onLogoutError(String message) {
    _homeWorkProvider.setProcessingStatus(isProcessing: false);

    //Show error message
    showToastMsg(
      msg: message,
      toastState: ToastStatesType.error,
    );
  }

  @override
  void onUpdateCurrentUserInfo(UserDataModel userDataModel) {
    _homeWorkProvider.setCurrentUser(userDataModel);
    _homeWorkProvider.setProcessingStatus(isProcessing: true);
  }

  @override
  void onGetListHomeworkComplete(List<ActivitiesModel> activities,
      List<NewClassModel> classes, String serverCurrentTime) async {
    _homeWorkProvider.setServerCurrentTime(serverCurrentTime);
    await _homeWorkProvider.setListClassForFilter(classes);
    await _homeWorkProvider.setListHomeWorks(activities);
    await _homeWorkProvider.initializeListFilter();
  }

  @override
  void onRefreshListHomework() {
    if (kDebugMode) {
      print("DEBUG: HomeWorkScreen - onRefreshListHomework");
    }
    _getListHomeWork();
  }
}
