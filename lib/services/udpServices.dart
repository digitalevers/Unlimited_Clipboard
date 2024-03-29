import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:rabbit_clipboard/common/func.dart';
import 'package:rabbit_clipboard/common/globalVariable.dart';

class UdpServices {
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
    GlobalVariables.socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, GlobalVariables.udpPort);
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
        List<String> ipList = GlobalVariables.deviceInfo['lanIP'].toString().split(".");
        ipList[ipList.length - 1] = "255";
        GlobalVariables.socket?.send(broadJson.codeUnits,InternetAddress(ipList.join(".")), GlobalVariables.udpPort);
      } else {
        GlobalVariables.socket?.send(broadJson.codeUnits, InternetAddress("255.255.255.255"), GlobalVariables.udpPort);
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
            //print('收到来自${udpData.address.toString()}:${udpData.port}的数据：${udpData.data.length}字节数据 内容:$msg');
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
                dynamic key = GlobalVariables.remoteDevicesKey;
                key.currentState?.addDeviceItem(_json);
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
            UdpServices.stopUDP();
          }
          break;
      }
    }, onError: (error) {
      log(error, StackTrace.current);
      UdpServices.stopUDP();
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
    GlobalVariables.socket?.send(offlineNotifyJson.codeUnits, InternetAddress("255.255.255.255"), GlobalVariables.udpPort);
  }

  static void stopUDP() {
    sendOfflineNotify();
    _startUDPLock = false;
    GlobalVariables.socket?.close();
    //关闭UDP广播定时器
    timer?.cancel();
  }

  //启动"清理下线设备"定时器 每隔 cleanInternalTime 秒清理一次下线设备(注意毫秒单位)
  static void startCleanTimer() {
    dynamic key = GlobalVariables.remoteDevicesKey;
    List<Map<String, dynamic>> remoteDevicesData_ = key.currentState!.remoteDevicesData;
    Duration timeout = Duration(seconds: GlobalVariables.cleanInternalTime);
    cleanTimer = Timer.periodic(timeout, (cleanTimer) {
      if (remoteDevicesData_.isNotEmpty) {
        int now = DateTime.now().millisecondsSinceEpoch;
        // 这样删除会引起 Concurrent modification during iteration
        // remoteDevicesData_.forEach((key, value) {
        //   if(now - value['millTimeStamp'] >= 5000){
        //     //超过5000毫秒没有更新时间戳的默认为下线设备并将其清理
        //     remoteDevicesData_.removeWhere(key);
        //   }
        // });
        remoteDevicesData_.removeWhere((remoteDeviceInfo) {
          if (now - remoteDeviceInfo['millTimeStamp'] >= GlobalVariables.cleanInternalTime * 1000) {
            return true;
          } else {
            return false;
          }
        });
        key.currentState?.setState(() {});
      }
    });
  }

  //关闭"清理下线设备"定时器
  static void stopCleanTimer() {
    cleanTimer?.cancel();
  }

}
