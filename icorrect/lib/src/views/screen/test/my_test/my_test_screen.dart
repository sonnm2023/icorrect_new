import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/models/homework_models/homework_model.dart';
import 'package:icorrect/src/views/screen/test/my_test/my_test_tab.dart';
import 'package:icorrect/src/views/screen/test/my_test/response_tab.dart';
import 'package:icorrect/src/views/screen/test/others_tab.dart';
import 'package:icorrect/src/views/screen/test/sample_tab.dart';

class MyTestScreen extends StatefulWidget {
  const MyTestScreen({super.key, required this.homeWorkModel});

  final HomeWorkModel homeWorkModel;

  @override
  State<MyTestScreen> createState() => _MyTestScreenState();
}

class _MyTestScreenState extends State<MyTestScreen> {
  TabBar get _tabBar => const TabBar(
    indicatorColor: AppColor.defaultPurpleColor,
    tabs: [
      Tab(text: 'MY TEST'),
      Tab(text: 'RESPONSE'),
      Tab(text: 'SAMPLE'),
      Tab(text: 'OTHERS'),
    ],
  );
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            elevation: 0.0,
            iconTheme: const IconThemeData(color: AppColor.defaultPurpleColor),
            centerTitle: true,
            title: const Text(
              "ICORRECT",
              style: TextStyle(color: AppColor.defaultPurpleColor),
            ),
            bottom: _tabBar,
            backgroundColor: AppColor.defaultWhiteColor,
          ),
          body: const TabBarView(
            children: [
              MyTestTab(),
              ResponseTab(),
              SampleTab(),
              OtherTab(),
            ],
          ),
        ),
      ),
    );
  }
}