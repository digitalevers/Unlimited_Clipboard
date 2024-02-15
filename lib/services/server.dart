import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:path/path.dart' as p;
import 'package:rabbit_clipboard/common/func.dart';
import 'package:rabbit_clipboard/common/globalVariable.dart';

class Server {
  static ServerStatus serverStatus = ServerStatus.idle;
  static Map<String, Object>? serverInf;
  //static Map<String, String>? fileList;
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
            // String os = (request.headers['os']![0]);
            // String username = request.headers['receiver-name']![0];
            // //allowRequest = await senderRequestDialog(username, os);

            // if (allowRequest == true) {
            //   //appending receiver data
            //   //request.response.write(jsonEncode({'code': _randomSecretCode, 'accepted': true}));
            //   request.response.close();
            // } else {
            //   request.response.write(
            //     jsonEncode({'code': -1, 'accepted': false}),
            //   );
            //   request.response.close();
            // }
            if (serverStatus == ServerStatus.idle) {
              String jsonString = await request.bytesToString();
              //log("收到剪切板消息$jsonString", StackTrace.current);
              Clipboard.setData(ClipboardData(text: jsonString));
              BotToast.showText(text: "收到剪切板消息");
            } else {
              request.response.write(jsonEncode({'code': HttpResponseCode.serverBusy})); //告知客户端 "服务端繁忙"
            }
          } else {
            request.response.write('Request Path denied access');
          }
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

  // static closeServer(context) async {
  //   try {
  //     await _server.close();
  //     await FileMethods.clearCache();
  //   } catch (e) {
  //     showSnackBar(context, 'Server not started yet');
  //   }
  // }
}
