import 'package:flutter/material.dart';
import 'package:icorrect/src/provider/my_test_provider.dart';
import 'package:icorrect/src/views/screen/test/my_test/my_test_tab.dart';
import 'package:provider/provider.dart';

class MyPracticeDetailTab extends StatefulWidget {
  final String testId;
  const MyPracticeDetailTab({super.key, required this.testId});

  @override
  State<MyPracticeDetailTab> createState() => _MyPracticeDetailTabState();
}

class _MyPracticeDetailTabState extends State<MyPracticeDetailTab>
    with AutomaticKeepAliveClientMixin<MyPracticeDetailTab> {
  MyTestProvider? _myTestProvider;

  @override
  void initState() {
    super.initState();
    _myTestProvider = Provider.of<MyTestProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MyTestTab(
      homeWorkModel: null,
      practiceTestId: widget.testId,
      provider: _myTestProvider!,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
