import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/provider/student_test_detail_provider.dart';
import 'package:icorrect/src/views/screen/test/my_test/student_detail_test/student_test_correction_tab.dart';
import 'package:icorrect/src/views/screen/test/my_test/student_detail_test/test_detail_screen_tab.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/app_color.dart';
import '../../../../../models/my_test_models/student_result_model.dart';

class StudentTestDetail extends StatefulWidget {
  final StudentResultModel studentResultModel;

  const StudentTestDetail({
    super.key,
    required this.studentResultModel,
  });

  @override
  State<StudentTestDetail> createState() => _StudentTestDetailState();
}

class _StudentTestDetailState extends State<StudentTestDetail> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  TabBar get _tabBar => TabBar(
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 3.0,
            color: AppColor.defaultPurpleColor,
          ),
          insets: EdgeInsets.symmetric(
            horizontal: CustomSize.size_10,
          ),
        ),
        tabs: _tabsLabel(),
      );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentTestProvider(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            elevation: 0.0,
            iconTheme: const IconThemeData(
              color: AppColor.defaultPurpleColor,
            ),
            centerTitle: true,
            leading: BackButton(
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              widget.studentResultModel.email.toString(),
              style: const TextStyle(
                color: AppColor.defaultPurpleColor,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(CustomSize.size_50),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColor.defaultPurpleColor),
                  ),
                ),
                child: _tabBar,
              ),
            ),
            backgroundColor: AppColor.defaultWhiteColor,
          ),
          body: Consumer<StudentTestProvider>(
            builder: (context, provider, child) {
              return TabBarView(
                children: [
                  TestDetailScreen(
                      provider: provider,
                      studentResultModel: widget.studentResultModel),
                  StudentCorrection(
                      provider: provider,
                      studentResultModel: widget.studentResultModel)
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _tabsLabel() {
    return const [
      Tab(
        child: Text(
          'Test Detail',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      Tab(
        child: Text(
          'Correction',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    ];
  }
}
