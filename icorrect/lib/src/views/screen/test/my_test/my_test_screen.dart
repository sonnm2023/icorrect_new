import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/models/homework_models/homework_model.dart';
import 'package:icorrect/src/views/screen/test/my_test/my_test_tab.dart';
import 'package:icorrect/src/views/screen/test/my_test/response_tab.dart';
import 'package:provider/provider.dart';

import '../../../../provider/my_test_provider.dart';
import 'highlight_tab.dart';
import 'others_tab.dart';

class MyTestScreen extends StatefulWidget {
  const MyTestScreen({super.key, required this.homeWorkModel});

  final HomeWorkModel homeWorkModel;

  @override
  State<MyTestScreen> createState() => _MyTestScreenState();
}

class _MyTestScreenState extends State<MyTestScreen> {
  MyTestProvider? _provider;
  TabBar get _tabBar => const TabBar(
        indicatorColor: AppColor.defaultPurpleColor,
        tabs: [
          Tab(
            child: Text('MY TEST',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Tab(
            child: Text('RESPONSE',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Tab(
            child: Text('HIGHLIGHT',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Tab(
            child: Text('OTHERS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      );
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<MyTestProvider>(context, listen: false);
    Future.delayed(Duration.zero, () {
      _provider!.clearData();
    });
  }

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
          body: TabBarView(
            children: [
              const MyTestTab(),
              ResponseTab(
                  homeWorkModel: widget.homeWorkModel, provider: _provider!),
              HighLightTab(
                provider: _provider!,
                homeWorkModel: widget.homeWorkModel,
              ),
              OtherTab(
                provider: _provider!,
                homeWorkModel: widget.homeWorkModel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
