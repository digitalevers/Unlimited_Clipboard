import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
//import 'package:hive/hive.dart';
//import 'package:rabbit_clipboard/controllers/controllers.dart';

import 'fileServices.dart';
//import 'package:rabbit_clipboard/main.dart';
//import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:rabbit_clipboard/common/globalVariable.dart';
import 'package:rabbit_clipboard/common/func.dart';

class Sender{
    // ignore: slash_for_doc_comments
    /**
     * 分享文件 包括外部意图和内部主动选择文件进行分享
     * /storage/emulated/0/
     * /data/data/0/com.digitalevers.transfer/files/uri_to_files
     */
  static Future<List<Map<String,String>>> share(context, { bool externalIntent = false, List<String> appList = const <String>[]}) async {
    if (externalIntent) {
      //分享意图
      if(Platform.isIOS){
        //TODO iOS分享意图

      } else if(Platform.isAndroid){
        List<SharedMediaFile> sharedMediaFiles = await ReceiveSharingIntent.getInitialMedia();
        GlobalVariables.fileList = transformList(sharedMediaFiles.map((e) => e.path).toList());
      }
    } else {
      //主动选择
      if(Platform.isAndroid){
        GlobalVariables.fileList  = transformList(await FileMethods.pickFiles());
        //log(fileList,StackTrace.current);
        for(int i = 0; i < GlobalVariables.fileList.length; i++){
          //第一种方式 使用 uri_to_file 插件试图转换成 /data/data 开头的内部链接 但是会将文件复制一份放到 "/data/data/0/包名" 的内部空间中 如果文件很大造成空间浪费而且复制会特别耗时
          //fileList![i] = (await toFile(fileList![i]!)).path;
          //print(fileList![i]);

          //第二种方式 使用 Android Api 转译地址来访问文件
          String? decodeContentUri = Uri.decodeComponent(GlobalVariables.fileList[i]["contentUri"]!);
          const platform = MethodChannel("AndroidApi");
          String originFilePath = await platform.invokeMethod("getOriginFilePathByUri",[decodeContentUri]);
          GlobalVariables.fileList[i]["originUri"] = originFilePath;
          if(originFilePath.startsWith("/storage/")){
            GlobalVariables.fileList[i]["storageUri"] = originFilePath;
          } else if(originFilePath.startsWith("/data/")){
            GlobalVariables.fileList[i]["privateUri"] = originFilePath;
          } else {
            throw Exception("无法转换File Uri");
          }
          //获取文件基本信息
          GlobalVariables.fileList[i]["baseName"] = getFileInfo(originFilePath)["baseName"]!;
          GlobalVariables.fileList[i]["fileName"] = getFileInfo(originFilePath)["fileName"]!;
          GlobalVariables.fileList[i]["shortFileName"] = getFileInfo(originFilePath)["shortFileName"]!;
          GlobalVariables.fileList[i]["extension"] = getFileInfo(originFilePath)["extension"]!;
          GlobalVariables.fileList[i]["fileSize"] = getFileInfo(originFilePath)["fileSize"]!;
        }
      } else{
        //iOS、Windows and so on
        GlobalVariables.fileList  = transformList(await FileMethods.pickFiles());
        for(int i = 0 ;i < GlobalVariables.fileList.length; i++){
          //获取文件基本信息
          GlobalVariables.fileList[i]['originUri'] = GlobalVariables.fileList[i]['contentUri']!;
          Map fileInfo = getFileInfo(GlobalVariables.fileList[i]['originUri']!);
          GlobalVariables.fileList[i]["baseName"] = fileInfo["baseName"]!;
          GlobalVariables.fileList[i]["fileName"] = fileInfo["fileName"]!;
          GlobalVariables.fileList[i]["shortFileName"] = fileInfo["shortFileName"]!;
          GlobalVariables.fileList[i]["extension"] = fileInfo["extension"]!;
          GlobalVariables.fileList[i]["fileSize"] = fileInfo["fileSize"]!;
        }
      }
    }
  
    log(GlobalVariables.fileList,StackTrace.current);
    return GlobalVariables.fileList;
  }
}
