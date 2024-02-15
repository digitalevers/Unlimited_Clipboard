import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:rabbit_clipboard/pages/modules/privacyPage.dart';
import 'pages/tabs.dart';

import 'common/func.dart';
import 'common/globalVariable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bot_toast/bot_toast.dart';

// 重写HttpOverrides
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    var http = super.createHttpClient(context);
    http.findProxy = (uri) {
      return 'PROXY ${GlobalVariables.proxy}'; //设置代理必须使用局域网地址 localhost或127.0.0.1不行
    };
    http.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return http;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //这一行很重要且必须放在第一行 放在 SharedPreferences 前面 否则运行会报错 暂不知原因
  GlobalVariables.prefs = await SharedPreferences.getInstance();
  if (GlobalVariables.useProxy) {
    HttpOverrides.global = MyHttpOverrides(); // 使用自己的HttpOverrides
  }
  // 屏幕顶部状态栏设置为透明（沉浸式）
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.blue));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    log("启动MyApp");
    return MaterialApp(
      navigatorKey: GlobalVariables.nav,
      title: '脱兔剪切板',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(
          title: 'A Crossplatform Clipboard Sync Tool',
          //key: GlobalVariables.myHomePageKey
        ),
      builder: BotToastInit(), //bot_toast
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    log("启动Main页面");
    // if(allowPrivacy){
    //   //刷新页面也不关闭 showGeneralDialog 弹窗?
    //   return const Tabs();
    // } else {
    //   return const PrivacyPage();
    // }
    return Tabs(key: GlobalVariables.tabsKey);
  }
}
