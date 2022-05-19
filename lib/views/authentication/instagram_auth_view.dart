import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InstagramAuthView extends StatelessWidget {
  InstagramAuthView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView example'),
      ),
      body: const WebView(
        initialUrl: '',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
