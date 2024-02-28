import 'dart:async';
import 'dart:convert';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/services.dart';
import 'package:rabbit_clipboard/common/func.dart';
import 'package:rabbit_clipboard/common/globalVariable.dart';

class ClipBoardServices {
  static Timer? timer;
  static Duration timeout = Duration(seconds: GlobalVariables.readClipBoardInternalTime);
  static String? prevContent = GlobalVariables.prefs!.getString("ClipboardData");
  
  static void startReadClipBoard(){
    timer = Timer.periodic(timeout, (timer) {
      Clipboard.getData(Clipboard.kTextPlain).then((value) async {
          //log(prevContent,StackTrace.current);
          //log(value?.text,StackTrace.current);
          if(value?.text != null){
            dynamic key = GlobalVariables.remoteDevicesKey;
            int remoteDevicesDataLength = key.currentState!.remoteDevicesData.length;
            //同步成功设备数
            int syncSucc = 0;
            //同步失败设备数
            int syncFail = 0;

            if(value?.text != prevContent){
              //剪切板有新内容才同步剪切板
              prevContent = value?.text;
              for(int i = 0; i < remoteDevicesDataLength; i++){
                bool syncFlag = key.currentState!.remoteDevicesData[i]["syncFlag"];
                String lanIP = key.currentState!.remoteDevicesData[i]["lanIP"];
                if(syncFlag == true){
                  //only send one time?
                  // syncClipBoard(GlobalVariables.client, key.currentState!.remoteDevicesData[i]["lanIP"], GlobalVariables.httpServerPort, prevContent).then((value){
                  //   if(value == 1){
                  //     //同步成功内容写入缓存 防止重启应用后再次同步
                  //     GlobalVariables.prefs!.setString("ClipboardData", prevContent!);
                  //   } else {
                  //     //同步失败自动进入下一个轮询同步
                  //     //prevContent = null;
                  //   }
                  // });
                  int result = await syncClipBoard(GlobalVariables.client, lanIP, GlobalVariables.httpServerPort, prevContent);
                  if(result == 1){
                    ++syncSucc;
                  } else {
                    ++syncFail;
                    //同步失败则将同步失败标识写入缓存 以便重启应用后再次尝试同步
                    GlobalVariables.prefs!.setString("$lanIP-syncResult", jsonEncode({"syncResult":false}));
                  }
                  GlobalVariables.prefs!.setString("ClipboardData", prevContent!);
                  BotToast.showText(text: "同步成功$syncSucc台设备\n同步失败$syncFail台设备");
                }
              }
            } else {
              for(int i = 0; i < remoteDevicesDataLength; i++){
                String lanIP = key.currentState!.remoteDevicesData[i]["lanIP"];
                String? syncResultS = GlobalVariables.prefs!.getString("$lanIP-syncResult");
                if(syncResultS != null){
                  bool syncResult = jsonDecode(syncResultS)["syncResult"];
                  //之前同步失败的记录再次进行同步
                  if(syncResult == false){
                    int result = await syncClipBoard(GlobalVariables.client, lanIP, GlobalVariables.httpServerPort, prevContent);
                    if(result == 1){
                      ++syncSucc;
                      //同步成功后删除失败标识记录
                      GlobalVariables.prefs!.remove("$lanIP-syncResult");
                    } else {
                      ++syncFail;
                    }
                    BotToast.showText(text: "同步成功$syncSucc台设备\n同步失败$syncFail台设备");
                  }
                }
              }
            }
          }
      });
    });
  }

  static void stopReadClipBoard(){
    timer?.cancel();
  }
}
