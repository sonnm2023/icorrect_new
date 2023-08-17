import 'dart:io';
import 'dart:core';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:provider/provider.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/views/widget/drawer_items.dart';
import 'package:icorrect/src/provider/homework_provider.dart';
import 'package:icorrect/src/presenters/homework_presenter.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/views/screen/auth/login_screen.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:icorrect/src/views/screen/home/my_homework_tab.dart';
import 'package:icorrect/src/presenters/simulator_test_presenter.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/new_class_model.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/custom_alert_dialog.dart';

class HomeWorkScreen extends StatefulWidget {
  const HomeWorkScreen({super.key});

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
  final scaffoldKey = /*GlobalKey<ScaffoldState>()*/
      GlobalScaffoldKey.homeScreenScaffoldKey;
  HomeWorkPresenter? _homeWorkPresenter;
  late HomeWorkProvider _homeWorkProvider;
  late AuthProvider _authProvider;

  CircleLoading? _loading;

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _homeWorkPresenter = HomeWorkPresenter(this);

    _homeWorkProvider = Provider.of<HomeWorkProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    _getListHomeWork();
  }

  void _getListHomeWork() {
    _homeWorkPresenter!.getListHomeWork();

    Future.delayed(Duration.zero, () {
      _homeWorkProvider.updateProcessingStatus();
      _authProvider
          .setGlobalScaffoldKey(GlobalScaffoldKey.homeScreenScaffoldKey);
    });
  }

  @override
  void dispose() {
    _homeWorkProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final drawerItems = navbarItems(context);

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
            key: scaffoldKey,
            appBar: AppBar(
              title: const Text(
                "MY HOMEWORK",
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
                ),
                Consumer<HomeWorkProvider>(
                  builder: (context, homeWorkProvider, child) {
                    if (homeWorkProvider.isProcessing) {
                      _loading!.show(context);
                    } else {
                      _loading!.hide();
                    }
                    return Container();
                  },
                ),
              ],
            ),
            drawer: Utils.navbar(context),
            drawerEnableOpenDragGesture: false,
          ),
        ),
      ),
    );
  }

  void _showQuitAppConfirmDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: "Notification",
          description: "Do you want to exit app?",
          okButtonTitle: "OK",
          cancelButtonTitle: "Cancel",
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
          title: "Notification",
          description: "The test is not completed! Are you sure to quit?",
          okButtonTitle: "OK",
          cancelButtonTitle: "Cancel",
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

/*  static Widget _drawHeader(UserDataModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: CustomSize.size_30,
        horizontal: CustomSize.size_10,
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
                  imageUrl:
                      fileEP(homeWorkProvider.currentUser.profileModel.avatar),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(CustomSize.size_100),
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
          Container(
            width: CustomSize.size_200,
            margin: const EdgeInsets.symmetric(
              horizontal: CustomSize.size_10,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: CustomSize.size_10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.profileModel.displayName.toString(),
                  style: CustomTextStyle.textWhiteBold_15,
                ),
                const SizedBox(height: CustomSize.size_5),
                Row(
                  children: [
                    Text(
                      "Dimond: ${user.profileModel.wallet.usd.toString()}",
                      style: CustomTextStyle.textWhite_14,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: CustomSize.size_10,
                      ),
                      child: const Image(
                        width: CustomSize.size_20,
                        image: AssetImage(AppAsset.dimond),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: CustomSize.size_5),
                Row(
                  children: [
                    Text(
                      "Gold: ${user.profileModel.pointTotal.toString()}",
                      style: CustomTextStyle.textWhite_14,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: CustomSize.size_10,
                      ),
                      child: const Image(
                        width: CustomSize.size_20,
                        image: AssetImage(
                          AppAsset.gold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void toggleDrawer() async {
    if (scaffoldKey.currentState!.isDrawerOpen) {
      scaffoldKey.currentState!.openEndDrawer();
    } else {
      scaffoldKey.currentState!.openDrawer();
    }
  }

  void _showLogoutConfirmDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: "Notification",
          description: "Do you want to logout?",
          okButtonTitle: "OK",
          cancelButtonTitle: "Cancel",
          borderRadius: 8,
          hasCloseButton: false,
          okButtonTapped: () {
            Navigator.of(context).pop();
          },
          cancelButtonTapped: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }*/

  @override
  void onGetListHomeworkError(String message) {
    _homeWorkProvider.updateProcessingStatus();

    //Show error message
    showToastMsg(
      msg: message,
      toastState: ToastStatesType.error,
    );
  }

  @override
  void onLogoutComplete() {
    _homeWorkProvider.updateProcessingStatus();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  void onLogoutError(String message) {
    _homeWorkProvider.updateProcessingStatus();

    //Show error message
    showToastMsg(
      msg: message,
      toastState: ToastStatesType.error,
    );
  }

  @override
  void onUpdateCurrentUserInfo(UserDataModel userDataModel) {
    _homeWorkProvider.setCurrentUser(userDataModel);
  }

  @override
  void onNewGetListHomeworkComplete(
      List<ActivitiesModel> activities, List<NewClassModel> classes) async {
    await _homeWorkProvider.setListClassForFilter(classes);
    await _homeWorkProvider.setListHomeWorks(activities);
    await _homeWorkProvider.initializeListFilter();
  }
}
