// ignore: slash_for_doc_comments
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;
import 'package:rabbit_clipboard/common/customIcons.dart';

import 'commclass.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'globalVariable.dart';


// ignore: slash_for_doc_comments
/**
 * 打印日志 输出所在文件及所在行
 */
void log(var msg, [StackTrace? st]) {
  st ??= StackTrace.current;
  if (GlobalVariables.logDebug){
    CustomPrint customPrint = CustomPrint(st);
      // ignore: avoid_print
    print("打印信息:$msg, 所在文件:${customPrint.fileName},所在行:${customPrint.lineNumber}");
  }
}

//返回min-max之间的整数
int randomInt(int min, int max) {
  final random = Random();
//将 参数min + 取随机数（最大值范围：参数max -  参数min）的结果 赋值给变量 result;
  int result = min + random.nextInt(max - min);
//返回变量 result 的值;
  return result;
}

//将 fileSize=0&fileCount=0 这样的拼接参数解析成 map
Map<String,String> pathinfo(String s){
  Map<String,String> map = {};
  List<String> token = s.split("&");
  for(String k in token){
    List<String> temp = k.split("=");
    map[temp[0]] = temp[1];
  }
  return map;
}

//判断给出的点是否在某个矩阵内
//位于矩阵内返回true 否则返回false
bool pointInsideRect(Offset point,double top,double left,double itemWidth,double itemHeight){
  //print(point); 
  //print(top); 
  //print(left);
  //print(itemWidth); 
  //print(itemHeight);
  if(point.dx > left && point.dx < (left + itemWidth) && point.dy > top && point.dy < (top + itemHeight)){
    return true;
  }
  return false;
}

//转换文件大小的规格
String fommatFileSize(int fileSizeBytes){
  int power = 0;
  List<String> units = ['Bytes','KB','MB','GB','TB'];
  int numLength = fileSizeBytes.toString().length;
  power = (numLength - 1) ~/ 3;
  num divisor = pow(1000,power);
  String formatedFileSize = (fileSizeBytes / divisor).toStringAsFixed(1);
  return "$formatedFileSize${units[power]}";
}

//获取文件名的简略形式 以免文件名过长
//params limLengh 限制的简略文件名字符长度（包含后缀）
String getShortFileName(String baseName,[int limLengh = 6]){
  if(baseName.length <= limLengh){
    return baseName;
  }
  baseName = baseName.substring(baseName.length - limLengh);
  return "...$baseName";
}

//根据 storageUri 或 privateUri 获取文件基本信息
Map<String,String>  getFileInfo(String storageOrPrivateUri){
  Map<String,String> fileInfo = {};
  fileInfo['baseName'] = p.basename(storageOrPrivateUri);
  fileInfo['fileName'] = p.withoutExtension(fileInfo['baseName']!);
  fileInfo['shortFileName'] = getShortFileName(fileInfo['baseName']!);
  fileInfo['extension'] = p.extension(fileInfo['baseName']!);
  File tempFile = File(storageOrPrivateUri);
  fileInfo['fileSize'] = tempFile.lengthSync().toString();
  return fileInfo;
}

//同步剪切板消息
Future<int> syncClipBoard(HttpClient client_, String serverIP_, int serverPort_, String? content_) async {
  String url = "http://$serverIP_:$serverPort_/syncClipBoard";
  //log(url,StackTrace.current);
  try{
    HttpClientRequest request = await GlobalVariables.client.postUrl(Uri.parse(url));
    request.add(utf8.encode(content_!));
    HttpClientResponse response = await request.close();
    int result = int.parse(await response.transform(utf8.decoder).join());
    //result 1 同步成功 0 同步失败
    return result;
  } catch(error){
    log(error,StackTrace.current);
    return 0;
  }
  //client.close();// 这里若关闭了 就不能再次发送请求了
}


//将 List<String?> 转成 List<Map<String,String>>的形式
List<Map<String,String>> transformList(List<String?> list){
  List<Map<String,String>> result = [];
  //Map<String,String> map = {"contentUri":"","storageUri":"","privateUri":"","baseName":"","fileName":"","extension":""};
  for(int i = 0; i < list.length; i++){
    Map<String,String> map = {};
    map["contentUri"] = list[i]!;
    result.add(map);
  }
  
  return result;
}


ContentType getHeaderContentType(String extension){
  ContentType ct = ContentType.text;
  switch(extension){
    case ".html":
      ct = ContentType.html;
      break;
    case ".js":
      ct = ContentType.parse("application/javascript; charset=utf-8");
      break;
    case ".css":
      ct = ContentType.parse("text/css; charset=utf-8");
      break;
    case ".gif":
      ct = ContentType.parse("image/gif");
      break;
    case ".png":
      ct = ContentType.parse("image/png");
      break;
    case ".ico":
      ct = ContentType.parse("image/ico");
      break;
    case ".apk":
      ct = ContentType.parse("application/vnd.android.package-archive");
      break;
    case ".json":
      ct = ContentType.json;
      break;
  }
  return ct;
}

IconData getRemoteDeviceTypeIcon(String? deviceType) {
  switch (deviceType) {
    case 'linux':
      return const Icon(CustomIcons.linux).icon!;
    case 'macos':
      return Icons.laptop_mac;
    case 'windows':
      return Icons.window_sharp;
    case 'android':
      return Icons.android;
    case 'ios':
      return Icons.phone_iphone;
    case 'fuchsia':
      return Icons.computer;
    default:
      return Icons.question_mark_sharp;
  }
}


//获取下载目录
//TODO iOS下载目录
// Future<String> getDownloadDir() {
//   if(Platform.isAndroid){
//     return ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
//   } else {
//     return getDownloadsDirectory().then((value){
//       return value!.path;
//     });
//   }
// }
