import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AIResponse extends StatefulWidget {
  String url;
  AIResponse({super.key, required this.url});

  @override
  State<AIResponse> createState() => _AIResponseState();
}

class _AIResponseState extends State<AIResponse> {
  WebViewController? _webViewController;
  CircleLoading? _loading;

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _loading!.show(context);

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
