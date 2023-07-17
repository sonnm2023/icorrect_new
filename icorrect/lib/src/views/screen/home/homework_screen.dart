import 'dart:core';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/models/homework_models/class_model.dart';
import 'package:icorrect/src/models/homework_models/homework_model.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect/src/presenters/homework_presenter.dart';
import 'package:icorrect/src/provider/homework_provider.dart';
import 'package:icorrect/src/views/screen/auth/change_password_screen.dart';
import 'package:icorrect/src/views/screen/auth/login_screen.dart';
import 'package:icorrect/src/views/screen/home/my_homework_tab.dart';
import 'package:icorrect/src/views/widget/default_loading_indicator.dart';
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

  @override
  void initState() {
    super.initState();

    _homeWorkProvider = Provider.of<HomeWorkProvider>(context, listen: false);
    _homeWorkPresenter = HomeWorkPresenter(this);
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
    UserAccountsDrawerHeader drawerHeader = UserAccountsDrawerHeader(
      accountName: Consumer<HomeWorkProvider>(builder: (context, homeWorkProvider, child) {
        return Text(
          homeWorkProvider.currentUser.profileModel.displayName,
        );
      }),
      accountEmail: const SizedBox(),
      currentAccountPicture: CircleAvatar(
        child: Consumer<HomeWorkProvider>(builder: (context, homeWorkProvider, child) {
          return CachedNetworkImage(
            imageUrl: '$apiDomain${homeWorkProvider.currentUser.profileModel.avatar}',
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  colorFilter: const ColorFilter.mode(
                    Colors.red,
                    BlendMode.colorBurn,
                  ),
                ),
              ),
            ),
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => CircleAvatar(
              child: Image.asset(
                "assets/images/default_avatar.png",
                width: 42.0,
                height: 42.0,
              ),
            ),
          );
        }),
      ),
    );

    final drawerItems = ListView(
      children: [
        drawerHeader,
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
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
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
      onWillPop: () async => false,
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
                MyHomeWorkTab(homeWorkProvider: _homeWorkProvider, homeWorkPresenter: _homeWorkPresenter!),
                Consumer<HomeWorkProvider>(
                  builder: (context, homeWorkProvider, child) {
                    if (homeWorkProvider.isProcessing) {
                      return const DefaultLoadingIndicator(
                          color: AppColor.defaultPurpleColor);
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
            drawer: Drawer(
              backgroundColor: AppColor.defaultWhiteColor,
              child: drawerItems,
            ),
          ),
        ),
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
      title: const Text(
        "Notification",
        style: TextStyle(
            color: AppColor.defaultBlackColor, fontWeight: FontWeight.w800),
      ),
      content: const Text("Do you want to logout?"),
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
  void onGetListHomeworkComplete (
      List<HomeWorkModel> homeworks, List<ClassModel> classes) async {
    await _homeWorkProvider.setListClassForFilter(classes);
    await _homeWorkProvider.setListHomeWorks(homeworks);
    await _homeWorkProvider.initializeListFilter();
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
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoginScreen()));
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
}
