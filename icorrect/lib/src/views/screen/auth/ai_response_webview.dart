import 'package:flutter/material.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class AiResponse extends StatefulWidget {
  String url;
  AiResponse({super.key, required this.url});

  @override
  State<AiResponse> createState() => _AIResponseState();
}

class _AIResponseState extends State<AiResponse> {
  WebViewController? _webViewController;
  CircleLoading? _loading;

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _loading!.show(context: context, isViewAIResponse: false);

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              _loading!.hide();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return _buildResponse();
  }

  Widget _buildResponse() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: WebViewWidget(controller: _webViewController!),
    );
  }
}
