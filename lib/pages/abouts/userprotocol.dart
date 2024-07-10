import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

 
// ignore: must_be_immutable
class Userprotocol extends StatelessWidget {

  const Userprotocol({super.key});
  
  void initState() {
    
  }

  @override
  Widget build(BuildContext context) {
    WebViewController webViewController = WebViewController.fromPlatformCreationParams(const PlatformWebViewControllerCreationParams());
    webViewController.loadFlutterAsset("assets/userprotocol.html");
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户协议'),
      ),
      body: WebViewWidget(controller: webViewController)
    );
  }
}