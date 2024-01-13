// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:core';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/views/screen/auth/change_password_screen.dart';
import 'package:icorrect/src/views/screen/auth/login_screen.dart';
import 'package:icorrect/src/views/screen/home/my_practice_tab.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/language_selection_dialog.dart';
import 'package:icorrect/src/views/screen/practice/practice_screen.dart';
import 'package:icorrect/src/views/screen/video_authentication/user_auth_detail_status_widget.dart';
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

class HomeWorkScreen extends StatefulWidget {
  final scaffoldKey = GlobalScaffoldKey.homeScreenScaffoldKey;

  HomeWorkScreen({super.key});

  @override
  State<HomeWorkScreen> createState() => _HomeWorkScreenState();
}

class _HomeWorkScreenState extends State<HomeWorkScreen>
    with AutomaticKeepAliveClientMixin
    implements HomeWorkViewContract {
  HomeWorkPresenter? _homeWorkPresenter;
  HomeWorkProvider? _homeWorkProvider;
  AuthProvider? _authProvider;
  SimulatorTestProvider? _simulatorTestProvider;

  List<Widget> _tabsLabel() {
    return [
      Tab(
        child: Text(
          Utils.multiLanguage(StringConstants.my_homework_screen_title)!
              .toUpperCase(),
        ),
      ),
      Tab(
        child: Text(
          Utils.multiLanguage(StringConstants.my_test_menu_item_title)!
              .toUpperCase(),
        ),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _homeWorkPresenter = HomeWorkPresenter(this);

    _homeWorkProvider = Provider.of<HomeWorkProvider>(context, listen: false);
    _simulatorTestProvider =
        Provider.of<SimulatorTestProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    _getListHomeWork();

    //Send log
    Utils.sendLog();

    //Create crash bug for test
    // Utils.testCrashBug();
  }

  void _getListHomeWork() async {
    _homeWorkProvider!.updateFilterString(
        Utils.multiLanguage(StringConstants.add_your_filter)!);
    _homeWorkProvider!.resetListSelectedClassFilter();
    _homeWorkProvider!.resetListSelectedStatusFilter();
    _homeWorkProvider!.resetListSelectedFilterIntoLocal();
    _homeWorkProvider!.resetListHomeworks();
    _homeWorkProvider!.resetListClassForFilter();
    _homeWorkProvider!.resetListFilteredHomeWorks();

    _homeWorkPresenter!.getListHomeWork(context);

    Future.delayed(Duration.zero, () {
      _authProvider!
          .setGlobalScaffoldKey(GlobalScaffoldKey.homeScreenScaffoldKey);
    });
  }

  @override
  void dispose() {
    _authProvider!.resetPermissionDeniedTime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WillPopScope(
      onWillPop: () async {
        _backButtonTapped();
        return false;
      },
      child: MaterialApp(
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
            key: widget.scaffoldKey,
            appBar: AppBar(
              title: Text(
                Utils.multiLanguage(StringConstants.icorrect_title)!,
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColor.defaultPurpleColor,
                  fontsSize: FontsSize.fontSize_18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              centerTitle: true,
              elevation: 0.0,
              iconTheme: const IconThemeData(
                color: AppColor.defaultPurpleColor,
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
            body: _buildBody(),
            drawer: _buildMenu(),
            drawerEnableOpenDragGesture: false,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      children: [
        MyHomeWorkTab(
          homeWorkProvider: _homeWorkProvider!,
          homeWorkPresenter: _homeWorkPresenter!,
          pullToRefreshCallBack: _pullToRefresh,
        ),
        const MyPracticeTab(),
      ],
    );
  }

  Widget _buildMenu() {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: Container(
              padding: const EdgeInsets.symmetric(
                vertical: CustomSize.size_10,
                horizontal: CustomSize.size_5,
              ),
              color: AppColor.defaultPurpleColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: CustomSize.size_60,
                    height: CustomSize.size_60,
                    child: CircleAvatar(
                      child: Consumer<HomeWorkProvider>(
                          builder: (context, homeWorkProvider, child) {
                        return CachedNetworkImage(
                          imageUrl: fileEP(
                              homeWorkProvider.currentUser.profileModel.avatar),
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(CustomSize.size_100),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                                colorFilter: const ColorFilter.mode(
                                  Colors.transparent,
                                  BlendMode.colorBurn,
                                ),
                              ),
                            ),
                          ),
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => CircleAvatar(
                            child: Image.asset(
                              AppAsset.defaultAvt,
                              width: CustomSize.size_40,
                              height: CustomSize.size_40,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Consumer<HomeWorkProvider>(
                    builder: (context, provider, child) {
                      return Flexible(
                        child: Text(
                          provider.currentUser.profileModel.displayName
                              .toString(),
                          style: CustomTextStyle.textWithCustomInfo(
                            context: context,
                            color: AppColor.defaultAppColor,
                            fontsSize: FontsSize.fontSize_15,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
          ListTile(
            title: Text(
              Utils.multiLanguage(
                StringConstants.home_menu_item_title,
              )!,
              style: CustomTextStyle.textWithCustomInfo(
                context: context,
                color: AppColor.defaultGrayColor,
                fontsSize: FontsSize.fontSize_15,
                fontWeight: FontWeight.w400,
              ),
            ),
            leading: const Icon(
              Icons.home_outlined,
              color: AppColor.defaultGrayColor,
            ),
            onTap: () {
              widget.scaffoldKey.currentState?.closeDrawer();
            },
          ),
          ListTile(
            title: Text(
              Utils.multiLanguage(
                StringConstants.practice_menu_item_title,
              )!,
              style: CustomTextStyle.textWithCustomInfo(
                context: context,
                color: AppColor.defaultGrayColor,
                fontsSize: FontsSize.fontSize_15,
                fontWeight: FontWeight.w400,
              ),
            ),
            leading: const Icon(
              Icons.menu_book,
              color: AppColor.defaultGrayColor,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PracticeScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: Text(
              Utils.multiLanguage(
                StringConstants.change_password_menu_item_title,
              )!,
              style: CustomTextStyle.textWithCustomInfo(
                context: context,
                color: AppColor.defaultGrayColor,
                fontsSize: FontsSize.fontSize_15,
                fontWeight: FontWeight.w400,
              ),
            ),
            leading: const Icon(
              Icons.password_outlined,
              color: AppColor.defaultGrayColor,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: Text(
              Utils.multiLanguage(
                StringConstants.video_authen_menu_item_title,
              )!,
              style: CustomTextStyle.textWithCustomInfo(
                context: context,
                color: AppColor.defaultGrayColor,
                fontsSize: FontsSize.fontSize_15,
                fontWeight: FontWeight.w400,
              ),
            ),
            leading: const Icon(
              Icons.video_camera_front_outlined,
              color: AppColor.defaultGrayColor,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UserAuthDetailStatus(),
                ),
              );
            },
          ),
          ListTile(
            title: Text(
              Utils.multiLanguage(
                StringConstants.multi_language,
              )!,
              style: CustomTextStyle.textWithCustomInfo(
                context: context,
                color: AppColor.defaultGrayColor,
                fontsSize: FontsSize.fontSize_15,
                fontWeight: FontWeight.w400,
              ),
            ),
            leading: const Icon(
              Icons.language,
              color: AppColor.defaultGrayColor,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (builder) {
                  return const LanguageSelectionDialog();
                },
              );
            },
          ),
          //For test rating
          // ListTile(
          //   title: Text(
          //     "Rating",
          //     style: CustomTextStyle.textWithCustomInfo(
          //       context: context,
          //       color: AppColor.defaultGrayColor,
          //       fontsSize: FontsSize.fontSize_15,
          //       fontWeight: FontWeight.w400,
          //     ),
          //   ),
          //   leading: const Icon(
          //     Icons.language,
          //     color: AppColor.defaultGrayColor,
          //   ),
          //   onTap: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (context) => const RatingWidget(),
          //       ),
          //     );
          //   },
          // ),
          ListTile(
            title: Text(
              Utils.multiLanguage(
                StringConstants.logout_menu_item_title,
              )!,
              style: CustomTextStyle.textWithCustomInfo(
                context: context,
                color: AppColor.defaultGrayColor,
                fontsSize: FontsSize.fontSize_15,
                fontWeight: FontWeight.w400,
              ),
            ),
            leading: const Icon(
              Icons.logout_outlined,
              color: AppColor.defaultGrayColor,
            ),
            onTap: () {
              Utils.showLogoutConfirmDialog(
                context: context,
                homeWorkPresenter: _homeWorkPresenter,
              );
            },
          ),
        ],
      ),
    );
  }

  Future _backButtonTapped() async {
    if (_authProvider!.isShowDialog) {
      GlobalKey<ScaffoldState> key = _authProvider!.globalScaffoldKey;
      _authProvider!.setShowDialogWithGlobalScaffoldKey(false, key);

      Navigator.of(key.currentState!.context).pop();
    } else if (_isShowConfirmDuringTest()) {
      _showQuitTheTestConfirmDialog();
    } else if (_isShowConfirmSaveTest()) {
      _simulatorTestProvider!.setShowConfirmSaveTest(true);
      setState(() {});
    } else {
      GlobalKey<ScaffoldState> key = _authProvider!.scaffoldKeys.first;
      if (key == GlobalScaffoldKey.homeScreenScaffoldKey) {
        _showQuitAppConfirmDialog();
      } else {
        if (_isBackFromTestRoom(key)) {
          Navigator.pop(key.currentState!.context, StringConstants.k_refresh);
        } else {
          Navigator.of(key.currentState!.context).pop();
        }
        _authProvider!.scaffoldKeys.removeFirst();
      }
    }
  }

  bool _isShowConfirmDuringTest() {
    return _simulatorTestProvider!.doingStatus == DoingStatus.doing &&
        _simulatorTestProvider!.reviewingStatus == ReviewingStatus.playing;
  }

  bool _isShowConfirmSaveTest() {
    return _simulatorTestProvider!.doingStatus == DoingStatus.finish &&
            _simulatorTestProvider!.submitStatus != SubmitStatus.success ||
        _simulatorTestProvider!.isVisibleSaveTheTest;
  }

  bool _isBackFromTestRoom(GlobalKey<ScaffoldState> key) {
    // return key == GlobalScaffoldKey.simulatorTestScaffoldKey &&
    return _simulatorTestProvider!.submitStatus == SubmitStatus.success;
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
          title: Utils.multiLanguage(StringConstants.dialog_title)!,
          description: Utils.multiLanguage(StringConstants.exit_app_message)!,
          okButtonTitle: Utils.multiLanguage(StringConstants.ok_button_title),
          cancelButtonTitle:
              Utils.multiLanguage(StringConstants.cancel_button_title),
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
          title: Utils.multiLanguage(StringConstants.dialog_title)!,
          description:
              Utils.multiLanguage(StringConstants.quit_the_test_message)!,
          okButtonTitle: Utils.multiLanguage(StringConstants.ok_button_title),
          cancelButtonTitle:
              Utils.multiLanguage(StringConstants.cancel_button_title),
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
    _homeWorkProvider!.setProcessingStatus(processing: false);

    //Show error message
    showToastMsg(
      msg: message,
      toastState: ToastStatesType.error,
      isCenter: true,
    );
  }

  @override
  void onLogoutSuccess() {
    _homeWorkProvider!.setProcessingStatus(processing: false);

    //Send log
    Utils.sendLog();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  void onLogoutError(String message) {
    _homeWorkProvider!.setProcessingStatus(processing: false);

    //Show error message
    showToastMsg(
      msg: message,
      toastState: ToastStatesType.error,
      isCenter: true,
    );
  }

  @override
  void onUpdateCurrentUserInfo(UserDataModel userDataModel) {
    _homeWorkProvider!.setCurrentUser(userDataModel);
    _homeWorkProvider!.setProcessingStatus(processing: true);
  }

  @override
  void onGetListHomeworkSuccess(List<ActivitiesModel> activities,
      List<NewClassModel> classes, String serverCurrentTime) async {
    _homeWorkProvider!.setServerCurrentTime(serverCurrentTime);
    await _homeWorkProvider!.setListClassForFilter(classes);
    await _homeWorkProvider!.setListHomeWorks(activities);
    await _homeWorkProvider!.initializeListFilter(context);
  }

  @override
  void onRefreshListHomework() {
    if (kDebugMode) {
      print("DEBUG: HomeWorkScreen - onRefreshListHomework");
    }
    _getListHomeWork();
  }

  @override
  bool get wantKeepAlive => true;
}
