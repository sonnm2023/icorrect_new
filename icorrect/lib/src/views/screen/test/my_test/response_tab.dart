import 'package:flutter/material.dart';

class ResponseTab extends StatefulWidget {
  const ResponseTab({super.key});

  @override
  State<ResponseTab> createState() => _ResponseTabState();
}

class _ResponseTabState extends State<ResponseTab> with AutomaticKeepAliveClientMixin<ResponseTab> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const Placeholder();
  }

  @override
  bool get wantKeepAlive => true;
}

