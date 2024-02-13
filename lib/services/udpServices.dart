import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:rabbit_clipboard/common/func.dart';
import 'package:rabbit_clipboard/common/globalVariable.dart';
import 'package:rabbit_clipboard/pages/modules/remoteDevices.dart';

class udpServices {
  //UDP广播定时器
  static Timer? timer;
  //探测下线设备定时器
  static Timer? cleanTimer;
  //UDP 启动锁确保只启动一次
  static bool _startUDPLock = false;

  //启动UDP广播 ———— 需要加一个启动锁 多次重复启动 会出现bug
  //2024.01.24 添加 "deviceInfo['lanIP'].isEmpty"判断条件修复linux release包下deviceInfo未初始化就启动UDP广播的错误
  static Future<void> startUDP() async {
    if (_startUDPLock == true || GlobalVariables.deviceInfo['lanIP']!.isEmpty) {
      return;
    }
    _startUDPLock = true;
    GlobalVariables.socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4, GlobalVariables.udpPort);
    GlobalVariables.socket?.broadcastEnabled = true;
    log('UDP Echo ready to receive', StackTrace.current);
    Duration timeout = Duration(seconds: GlobalVariables.udpBroadInternalTime);

    //构造广播json数据
    Map broadMap = {
      'lanIP': GlobalVariables.deviceInfo['lanIP'],
      'deviceName': GlobalVariables.deviceInfo['model'],
      'deviceType': GlobalVariables.deviceInfo['deviceType']
    };
    String broadJson = json.encode(broadMap);

    timer = Timer.periodic(timeout, (timer) {
      //[0x44, 0x48, 0x01, 0x01]
      if (Platform.isIOS || Platform.isMacOS) {
        //动态获取子网地址前三段
        List<String> ipList =
            GlobalVariables.deviceInfo['lanIP'].toString().split(".");
        ipList[ipList.length - 1] = "255";
        GlobalVariables.socket?.send(broadJson.codeUnits,
            InternetAddress(ipList.join(".")), GlobalVariables.udpPort);
      } else {
        GlobalVariables.socket?.send(broadJson.codeUnits,
            InternetAddress("255.255.255.255"), GlobalVariables.udpPort);
      }
    });
    //print('${socket?.address.address}:${socket?.port}');
    GlobalVariables.socket?.listen((RawSocketEvent e) {
      switch (e) {
        case RawSocketEvent.read:
          {
            Datagram? udpData = GlobalVariables.socket?.receive();
            if (udpData == null) return;
            var decoder = const Utf8Decoder();
            String msg = decoder.convert(udpData.data); // 将UTF8数据解码
            //String msg = String.fromCharCodes(udpData.data);
            print(
                '收到来自${udpData.address.toString()}:${udpData.port}的数据：${udpData.data.length}字节数据 内容:$msg');
            //print('Datagram from ${udpData.address.address}:${udpData.port}: ${msg.trim()}');
            //socket.send(msg.codeUnits, d.address, d.port);

            //解析UDP json数据
            // ignore: no_leading_underscores_for_local_identifiers
            Map<String, dynamic> _json = json.decode(msg);
            if (_json['notifyType'] == 2) {
              //设备下线广播
              //log(_json,StackTrace.current);
              // remoteDevicesData.removeWhere((ip, remoteDeviceInfo) {
              //   if (ip == _json['lanIP']) {
              //     setState(() {
              //       removeRemoteDeviceFromWidget(remoteDeviceInfo['remoteDeviceKey']);
              //     });
              //     return true;
              //   } else {
              //     return false;
              //   }
              // });
            } else {
              if (_json['lanIP'] != GlobalVariables.deviceInfo['lanIP']) {
                dynamic _key = GlobalVariables.remoteDevicesKey;
                _key.currentState!.addRemoteDevice();
                //判断设备是否已经添加进显示区
                log(_key.currentState!.remoteDevicesData, StackTrace.current);
                if (!_remote_.containsKey(_json['lanIP'])) {
                  // setState(() {
                  //   addRemoteDeviceToWidget(_json);
                  //   //不能直接赋值 必须深拷贝
                  //   //remoteDevicesWidgetPlus = remoteDevicesWidget;
                  //   remoteDevicesWidgetPlus = [...remoteDevicesWidget];
                  //   remoteDevicesWidgetPlus.add(_waterRipple);
                  // });
                } else {
                  //旧设备则更新毫秒时间戳
                  //remoteDevicesData[_json['lanIP']]!['millTimeStamp'] = DateTime.now().millisecondsSinceEpoch;
                }
              }
            }
          }
          break;
        case RawSocketEvent.write:
          {
            log('RawSocketEvent.write', StackTrace.current);
          }
          break;
        case RawSocketEvent.readClosed:
          {
            log('RawSocketEvent.readClosed', StackTrace.current);
          }
          break;
        case RawSocketEvent.closed:
          {
            log('RawSocketEvent.closed', StackTrace.current);
            //进程在background太久 socket会被系统关闭 所以这里要手动关闭UDP广播 以便界面resume的时候重启UDP广播
            udpServices.stopUDP();
          }
          break;
      }
    }, onError: (error) {
      log(error, StackTrace.current);
      udpServices.stopUDP();
    }, onDone: () {
      GlobalVariables.socket?.close();
    });
  }

  //发送一个设备下线通知广播
  static sendOfflineNotify() {
    Map offlineNotifyMap = {
      'notifyType': 2,
      'lanIP': GlobalVariables.deviceInfo['lanIP'],
      'deviceName': GlobalVariables.deviceInfo['model'],
      'deviceType': GlobalVariables.deviceInfo['deviceType']
    };
    String offlineNotifyJson = json.encode(offlineNotifyMap);
    GlobalVariables.socket?.send(offlineNotifyJson.codeUnits,
        InternetAddress("255.255.255.255"), GlobalVariables.udpPort);
  }

  static void stopUDP() {
    sendOfflineNotify();
    _startUDPLock = false;
    GlobalVariables.socket?.close();
    //关闭UDP广播定时器
    timer?.cancel();
  }
}
