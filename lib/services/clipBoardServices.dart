import 'dart:async';
import 'package:flutter/services.dart';
import 'package:rabbit_clipboard/common/func.dart';

import 'package:rabbit_clipboard/common/globalVariable.dart';

class ClipBoardServices {
  static Timer? timer;
  static Duration timeout = Duration(seconds: GlobalVariables.readClipBoardInternalTime);
  static String? prevContent = GlobalVariables.prefs!.getString("ClipboardData");
  
  static void startReadClipBoard(){
    timer = Timer.periodic(timeout, (timer) {
      Clipboard.getData(Clipboard.kTextPlain).then((value){
          //log(prevContent,StackTrace.current);
          //log(value?.text,StackTrace.current);
          if(value?.text != null && value?.text != prevContent){
              //剪切板有新内容才同步剪切板
              prevContent = value?.text;
              dynamic key = GlobalVariables.remoteDevicesKey;
              for(int i = 0; i < key.currentState!.remoteDevicesData.length; i++){
                if(key.currentState!.remoteDevicesData[i]["syncFlag"] == true){
                  //only send one time?
                  syncClipBoard(GlobalVariables.client, key.currentState!.remoteDevicesData[i]["lanIP"], GlobalVariables.httpServerPort, prevContent).then((value){
                    if(value == 1){
                      //同步成功内容写入缓存
                      GlobalVariables.prefs!.setString("ClipboardData", prevContent!);
                    } else {
                      //同步失败自动进入下一个轮询同步
                      prevContent = null;
                    }
                  });
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
