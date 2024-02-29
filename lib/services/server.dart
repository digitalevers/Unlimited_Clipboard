import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/services.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:path/path.dart' as p;
import 'package:rabbit_clipboard/common/func.dart';
import 'package:rabbit_clipboard/common/globalVariable.dart';
import 'package:rabbit_clipboard/services/clipBoardServices.dart';

class Server {
  static ServerStatus serverStatus = ServerStatus.idle;

  static HttpServer? _server;
  //启动httpserver
  static Future<Map<String, dynamic>> startServer() async {
    try {
      _server = await HttpServer.bind('0.0.0.0', GlobalVariables.httpServerPort);
    } catch (e) {
      return {'hasErr': true, 'type': 'server', 'errMsg': '$e'};
    }

    _server!.listen(
      (HttpRequest request) async {
        if (request.method.toLowerCase() == 'post') {
          String baseUri = p.basename(request.requestedUri.toString());
          //log(baseUri,StackTrace.current);
          if (baseUri == "syncClipBoard") {
            if (serverStatus == ServerStatus.idle) {
              String jsonString = await request.bytesToString();
              ClipBoardServices.stopReadClipBoard();

              await Clipboard.setData(ClipboardData(text: jsonString)).then((setValue) async {
                await Clipboard.getData(Clipboard.kTextPlain).then((getValue){
                  if(getValue?.text != null){
                    //将内容写入prevContent 防止再次将剪切板内容同步出去
                    ClipBoardServices.prevContent = jsonString;
                    //写入缓存
                    GlobalVariables.prefs!.setString("ClipboardData", jsonString);
                    BotToast.showText(text: "收到剪切板消息");
                    //在异步回调中write 必须在最前面加await 否则会报 StreamSink closed
                    request.response.write(1);
                  } else {
                    //应用位于后台无法读写剪切板
                    request.response.write(0);
                  }
                  ClipBoardServices.startReadClipBoard();
                });
              });

            } else {
              request.response.write(jsonEncode({'code': HttpResponseCode.serverBusy})); //告知客户端 "服务端繁忙"
            }
          } else {
            request.response.write('Request Path denied access');
          }
          await request.response.flush();
          request.response.close();
        }
      },
    );
    return {
      'hasErr': false,
      'type': null,
      'errMsg': null,
    };
  }

  static stopServer() async {
    try {
      await _server?.close();
    } catch (e) {
      BotToast.showText(text: "Server not started yet");
    }
  }
}
