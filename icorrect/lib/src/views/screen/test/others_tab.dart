import 'package:flutter/material.dart';

class OtherTab extends StatefulWidget {
  const OtherTab({super.key});

  @override
  State<OtherTab> createState() => _OtherTabState();
}

class _OtherTabState extends State<OtherTab> with AutomaticKeepAliveClientMixin<OtherTab> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const Center(child: Text("OtherTab"),);
  }

  @override
  bool get wantKeepAlive => true;
}
