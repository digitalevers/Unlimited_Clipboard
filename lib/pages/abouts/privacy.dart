import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

 
// ignore: must_be_immutable
class Privacy extends StatelessWidget {

  const Privacy({super.key});
  
  void initState() {
    
  }

  @override
  Widget build(BuildContext context) {
    WebViewController webViewController = WebViewController.fromPlatformCreationParams(const PlatformWebViewControllerCreationParams());
    webViewController.loadFlutterAsset("assets/privacy.html");
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私政策'),
      ),
      body: WebViewWidget(controller: webViewController)
    );
  }
}