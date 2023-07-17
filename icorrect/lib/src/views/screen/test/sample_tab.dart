import 'package:flutter/material.dart';

class SampleTab extends StatefulWidget {
  const SampleTab({super.key});

  @override
  State<SampleTab> createState() => _SampleTabState();
}

class _SampleTabState extends State<SampleTab> with AutomaticKeepAliveClientMixin<SampleTab> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const Center(child: Text("SampleTab"),);
  }

  @override
  bool get wantKeepAlive => true;
}
