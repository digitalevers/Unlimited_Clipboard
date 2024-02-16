import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:rabbit_clipboard/common/commclass.dart';
import 'package:rabbit_clipboard/services/clipBoardServices.dart';
import 'package:rabbit_clipboard/services/server.dart';

import 'tabs/syncDevices.dart';
import 'tabs/syncHistory.dart';

import 'package:rabbit_clipboard/pages/modules/privacyPage.dart';
import 'package:rabbit_clipboard/common/globalVariable.dart';
import 'package:rabbit_clipboard/services/udpServices.dart';
//import 'package:showcaseview/showcaseview.dart';

class Tabs extends StatefulWidget {
  //final GlobalKey tabsKey;
  const Tabs({super.key});

  @override
  State<Tabs> createState() {
    return _nameState();
  }
}

class _nameState extends State<Tabs> with SingleTickerProviderStateMixin {
  //默认显示的tab index
  int _currentIndex = 0;
  List<Map<String, String>> chooseFiles = [];
  String showShortFileName = '';
  final List<Widget> _pages = [
    const SyncDevices(),
    const SyncHistory(),
  ];

  //新手引导蒙层
  //final GlobalKey _one = GlobalKey();
  //late BuildContext myContext;

  //初始化获取设备和wifi信息
  Future<void> _initGetInfo() async {
    Map deviceInfo_ = await DeviceInfoApi.getDeviceInfo();
    //log(deviceInfo_, StackTrace.current);
    GlobalVariables.deviceInfo['model'] = deviceInfo_['model'] ?? deviceInfo_['prettyName']; //linux
    GlobalVariables.deviceInfo['deviceType'] = Platform.operatingSystem;
    DeviceInfoApi.getNetworkInfo(_listenConnectivityChanged);
  }

  /// 监听网络类型的改变
  /// 改变ip和wifi接入情况
  /// ethernet wifi mobile none
  Future<void> _listenConnectivityChanged(ConnectivityResult result) async {
    Map result_ = await DeviceInfoApi.parseNetworkInfoResult(result);
    //log(result_, StackTrace.current);
    String networkText, lanIP;
    if (result_['type'] == 'nowifi') {
      networkText = '未接入WiFi';
    } else {
      networkText = result_['wifiName'];
    }
    //由移动网络切换到WiFi下继续启动UDP广播
    lanIP = await DeviceInfoApi.getDeviceLocalIP();
    if (lanIP.isEmpty) {
      lanIP = "无法获取ip";
    }
    if ((result_['type'] == 'wifi' || result_['type'] == 'ethernet') && lanIP.isNotEmpty) {
      UdpServices.startUDP();
      ClipBoardServices.startReadClipBoard();
      Server.startServer();
    } else {
      //由WiFi切换到移动网络下关闭UDP广播
      UdpServices.stopUDP();
    }
    //刷新 headerWidget
    GlobalVariables.headerWidgetKey.currentState?.setState(() {
      GlobalVariables.deviceInfo['networkText'] = networkText;
      GlobalVariables.deviceInfo['lanIP'] = lanIP;
    });
  }

  // void initEnv() {
  //   log(deviceInfo_, StackTrace.current);
  //   startUDP();
  //   startCleanTimer();
  //   启动HTTP SERVER并传入key 便于在server类中获取context
  //   await Server.startServer(sendToAppBodyKey, receiveFilesLogKey);
  // }

  @override
  void initState() {
    super.initState();
    _initGetInfo();
    //startCleanTimer();
  }

  @override
  void deactivate() {
    super.deactivate();
    print('tabs-deactivate');
  }

  @override
  void dispose() {
    super.dispose();
    print('tabs-dispose');
  }

  @override
  Widget build(BuildContext context) {
    bool allowPrivacy = GlobalVariables.prefs?.getBool("allowPrivacy") ?? false;
    if (allowPrivacy) {
      //置于initState中只会执行一次
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          //ShowCaseWidget.of(myContext).startShowCase([_one]);
        });
      });

      return Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.devices), label: "同步设备"),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: "同步历史"),
          ],
        ),
        //新手引导蒙层只在app安装时提示一次
        //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      );
    } else {
      return const PrivacyPage();
    }
  }
}
