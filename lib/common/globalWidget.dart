import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:rabbit_clipboard/common/commclass.dart';
import 'package:rabbit_clipboard/common/func.dart';
import 'package:rabbit_clipboard/common/globalVariable.dart';

class headerWidget extends StatefulWidget {
  const headerWidget({super.key});

  @override
  State<headerWidget> createState() => _headerWidgetState();
}

class _headerWidgetState extends State<headerWidget> {

  //初始化获取设备和wifi信息
  Future<Map> initGetInfo(Function func) async {
    Map deviceInfo_ = await DeviceInfoApi.getDeviceInfo();
    deviceInfo_['model'] ??= deviceInfo_['prettyName']; //linux
    deviceInfo_['lanIP'] = await DeviceInfoApi.getDeviceLocalIP();
    deviceInfo_['network'] = await DeviceInfoApi.getNetworkInfo(func);
    deviceInfo_['deviceType'] = Platform.operatingSystem;
    return deviceInfo_;
  }

  /// 监听网络类型的改变
  /// 改变ip和wifi接入情况
  /// ethernet wifi mobile none
  Future<void> listenConnectivityChanged(ConnectivityResult result) async {
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
    if ((result_['type'] == 'wifi' || result_['type'] == 'ethernet') &&
        lanIP.isNotEmpty) {
      //startUDP();
    } else {
      //由WiFi切换到移动网络下关闭UDP广播
      //stopUDP();
    }
    //print(lanIP);
    setState(() {
      GlobalVariables.deviceInfo['networkText'] = networkText;
      GlobalVariables.deviceInfo['lanIP'] = lanIP;
    });
  }

  Future<void> initEnv() async {
    Map deviceInfo_ = await initGetInfo(listenConnectivityChanged);
    log(deviceInfo_, StackTrace.current);
    if (deviceInfo_['network']['type'] == 'nowifi') {
      GlobalVariables.deviceInfo['networkText'] = '未接入WiFi';
    } else {
      GlobalVariables.deviceInfo['networkText'] = deviceInfo_['network']['wifiName'];
    }
    if (GlobalVariables.deviceInfo['lanIP']!.isEmpty) {
      GlobalVariables.deviceInfo['lanIP'] = "无法获取ip";
    }
    GlobalVariables.deviceInfo['model'] = deviceInfo_['model'];
    GlobalVariables.deviceInfo['deviceType'] = deviceInfo_['deviceType'];
    //startUDP();
    //startCleanTimer();
    //启动HTTP SERVER并传入key 便于在server类中获取context
    //await Server.startServer(sendToAppBodyKey, receiveFilesLogKey);
  }

  @override
  void initState() {
    super.initState();
    initEnv();
    //添加监听
    //WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.blue,
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                Icon(
                  getRemoteDeviceTypeIcon(GlobalVariables.deviceInfo['deviceType']),
                  size: 16,
                  color: Colors.white,
                ),
                Text(
                  GlobalVariables.deviceInfo['model']!,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.location_pin,
                  size: 16,
                  color: Colors.white,
                ),
                Text(
                  GlobalVariables.deviceInfo['lanIP']!,
                  style: const TextStyle(color: Colors.white),
                )
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.wifi,
                  size: 16,
                  color: Colors.white,
                ),
                Text(
                  GlobalVariables.deviceInfo['networkText']!,
                  style: const TextStyle(color: Colors.white),
                )
              ],
            ),
          ],
        ));
  }
}

// Widget getHeaderWidget() {


//   return ;
// }
