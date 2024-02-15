import 'dart:async';
import 'package:flutter/services.dart';
import 'package:rabbit_clipboard/common/func.dart';

import 'package:rabbit_clipboard/common/globalVariable.dart';

class ClipBoard {
  static Timer? timer;
  static Duration timeout = Duration(seconds: GlobalVariables.readClipBoardInternalTime);
  static String? prevContent;
  
  static void startReadClipBoard(){
    timer = Timer.periodic(timeout, (timer) {
      Clipboard.getData(Clipboard.kTextPlain).then((value){
          if(value?.text != prevContent){
              //剪切板有内容更新则发送该内容
              prevContent = value?.text;
              //log(prevContent,StackTrace.current);
              if(prevContent != null){
                dynamic key = GlobalVariables.remoteDevicesKey;
                for(int i = 0; i < key.currentState!.remoteDevicesData.length; i++){
                  if(key.currentState!.remoteDevicesData[i]["syncFlag"] == true){
                    syncClipBoard(GlobalVariables.client, key.currentState!.remoteDevicesData[i]["lanIP"], GlobalVariables.httpServerPort, prevContent);
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
