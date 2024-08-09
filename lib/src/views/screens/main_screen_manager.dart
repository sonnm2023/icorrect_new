
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:icorrect_pc/core/app_assets.dart';
import 'package:icorrect_pc/core/app_colors.dart';
import 'package:icorrect_pc/src/data_source/local/file_storage_helper.dart';
import 'package:icorrect_pc/src/providers/main_widget_provider.dart';

import 'package:provider/provider.dart';

import '../../data_source/constants.dart';

class MainWidget extends StatefulWidget {
  final scaffoldKey = GlobalScaffoldKey.homeScreenScaffoldKey;
  MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {

  late MainWidgetProvider _provider;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<MainWidgetProvider>(context, listen: false);
    // Future.delayed(Duration.zero, () {
    //   _provider.setCurrentScreen(const HomeWorksWidget());
    // });
    _provider.setIsShowTestDevice(true);
  }

  @override
  void dispose() {
    super.dispose();
    _provider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(AppAssets.bg_main), fit: BoxFit.fill),
          ),
          child: _mainItem(),
        ),
      ),
    );
  }

  Widget _mainItem() {
    return Padding(
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
        child:
        Column(
          children: [_mainHeader(), _body()],
        ));
  }

  Widget _mainHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 170,
                child: IconButton (
                  onPressed: () {
                    _provider.setIsShowTestDevice(true);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => _provider.lastScreen,));
                    FileStorageHelper.deleteFileInAudios();
                  }, icon: const Icon(Icons.arrow_back_outlined, size: 35,),
                ),
              ),
              _buildTitle(),
              const Image(width: 170, image: AssetImage(AppAssets.img_logo_app)),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: const Divider(
            height: 1,
            thickness: 1,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Consumer<MainWidgetProvider>(builder: (context, provider, child) {
      return Text(provider.titleMain, style: const TextStyle(
              color: AppColors.purple,
              fontWeight: FontWeight.bold,
              fontSize: 24));
    },);
  }

  Widget _body() {
    return Consumer<MainWidgetProvider>(
        builder: (context, appState, child) =>
            Expanded(child: appState.currentScreen));
  }
}
