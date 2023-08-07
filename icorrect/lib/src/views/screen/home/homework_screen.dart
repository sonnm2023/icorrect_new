import 'dart:core';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/new_class_model.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect/src/presenters/homework_presenter.dart';
import 'package:icorrect/src/provider/homework_provider.dart';
import 'package:icorrect/src/provider/my_test_provider.dart';
import 'package:icorrect/src/views/screen/auth/change_password_screen.dart';
import 'package:icorrect/src/views/screen/auth/login_screen.dart';
import 'package:icorrect/src/views/screen/home/my_homework_tab.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/confirm_dialog.dart';
import 'package:icorrect/src/views/screen/test/my_test/my_test_tab.dart';
import 'package:icorrect/src/views/widget/default_text.dart';
import 'package:icorrect/src/views/widget/filter_content_widget.dart';
import 'package:provider/provider.dart';

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
  final scaffoldKey = GlobalKey<ScaffoldState>();
  HomeWorkPresenter? _homeWorkPresenter;
  late HomeWorkProvider _homeWorkProvider;
  late MyTestProvider _myTestProvider;
  CircleLoading? _loading;

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _homeWorkProvider = Provider.of<HomeWorkProvider>(context, listen: false);
    _homeWorkPresenter = HomeWorkPresenter(this);

    _myTestProvider = Provider.of<MyTestProvider>(context, listen: false);

    _getListHomeWork();
  }

  void _getListHomeWork() {
    _homeWorkPresenter!.getListHomeWork();

    Future.delayed(Duration.zero, () {
      _homeWorkProvider.updateProcessingStatus();
    });
  }

  @override
  void dispose() {
    _homeWorkProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final drawerItems = ListView(
      children: [
        Consumer<HomeWorkProvider>(builder: (context, homeWorkProvider, child) {
          return _drawHeader(homeWorkProvider.currentUser);
        }),
        ListTile(
          title: const Text(
            "Home",
          ),
          leading: const Icon(Icons.home),
          onTap: () {
            toggleDrawer();
          },
        ),
        ListTile(
          title: const Text(
            "Change password",
          ),
          leading: const Icon(Icons.password),
          onTap: () {
            toggleDrawer();

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ChangePasswordScreen(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text(
            "Logout",
          ),
          leading: const Icon(Icons.logout_outlined),
          onTap: () {
            toggleDrawer();
            showAlertDialog(context);
          },
        ),
      ],
    );

    return WillPopScope(
      onWillPop: () async {
        if (_homeWorkProvider.isShowFilter) {
          //Filter bottom sheet
          _homeWorkProvider.setShowFilter(false);
          Navigator.of(
                  GlobalScaffoldKey.filterScaffoldKey.currentState!.context)
              .pop();
        } else if (_myTestProvider.isShowAIResponse) {
          //AI Response
          _myTestProvider.setShowAIResponse(false);
          Navigator.of(
                  GlobalScaffoldKey.aiResponseScaffoldKey.currentState!.context)
              .pop();
        } else {
          //TODO: Show confirm dialog to quit the application here
          if (kDebugMode) {
            print(
                "DEBUG: TODO: Show confirm dialog to quit the application here");
          }
          _showQuitAppConfirmDialog();
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
                fontWeight: FontWeight.w800),
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: AppColor.defaultPurpleColor),
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
                style: TextStyle(color: AppColor.defaultPurpleColor),
              ),
              centerTitle: true,
              elevation: 0.0,
              iconTheme:
                  const IconThemeData(color: AppColor.defaultPurpleColor),
              // bottom: PreferredSize(
              //   preferredSize: _tabBar.preferredSize,
              //   child: Material(
              //     color: defaultWhiteColor,
              //     child: _tabBar,
              //   ),
              // ),
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
            drawer: Drawer(
              backgroundColor: AppColor.defaultWhiteColor,
              child: drawerItems,
            ),
            drawerEnableOpenDragGesture: false,
          ),
        ),
      ),
    );
  }

  _showQuitAppConfirmDialog() {
    showDialog(
      context: context,
      builder: (builder) {
        return ConfirmDialogWidget(
          title: "Confirm",
          message: "Are you sure to quit this application?",
          cancelButtonTitle: "Cancel",
          okButtonTitle: "Ok",
          cancelButtonTapped: () {},
          okButtonTapped: () {
            Navigator.of(context).pop(true);
          },
        );
      },
    );
  }

  static Widget _drawHeader(UserDataModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
      color: AppColor.defaultPurpleColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircleAvatar(
              child: Consumer<HomeWorkProvider>(
                  builder: (context, homeWorkProvider, child) {
                return CachedNetworkImage(
                  imageUrl:
                      fileEP(homeWorkProvider.currentUser.profileModel.avatar),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
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
                      width: 42,
                      height: 42,
                    ),
                  ),
                );
              }),
            ),
          ),
          Container(
            width: 200,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultText(
                  text: user.profileModel.displayName.toString(),
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    DefaultText(
                      text:
                          "Dimond: ${user.profileModel.wallet.usd.toString()}",
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: const Image(
                        width: 20,
                        image: AssetImage(AppAsset.dimond),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      "Gold: ${user.profileModel.pointTotal.toString()}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: const Image(
                        width: 20,
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

  void showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text(
        "Cancel",
        style: TextStyle(
            color: AppColor.defaultGrayColor, fontWeight: FontWeight.w800),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text(
        "OK",
        style: TextStyle(
            color: AppColor.defaultPurpleColor, fontWeight: FontWeight.w800),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        _homeWorkProvider.updateProcessingStatus();
        _homeWorkPresenter!.logout();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: const Text(
        "Notification",
        style: TextStyle(
          color: AppColor.defaultBlackColor,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: const Text(
        "Do you want to logout?",
        style: TextStyle(fontSize: 17),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

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
