import 'package:flutter/material.dart';

class MyTestTab extends StatefulWidget {
  const MyTestTab({super.key});

  @override
  State<MyTestTab> createState() => _MyTestTabState();
}

class _MyTestTabState extends State<MyTestTab> with AutomaticKeepAliveClientMixin<MyTestTab> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const Center(
      child: Text("MyTest Tab"),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
