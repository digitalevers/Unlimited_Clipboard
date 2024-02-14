import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import 'package:rabbit_clipboard/common/func.dart';
import 'package:rabbit_clipboard/common/globalVariable.dart';

//组件单独放在一个文件里则无法访问到 _RemoteDevicesState 该类为文件私有
class RemoteDevices extends StatefulWidget {
  const RemoteDevices(Key key) : super(key: key);

  @override
  State<RemoteDevices> createState() => _RemoteDevicesState();
}

// ignore: camel_case_types
class _RemoteDevicesState extends State<RemoteDevices> {
  List<Map<String, dynamic>> remoteDevicesData = [
    //{"lanIP": "192.168.2.3", "deviceName": "airbook", "deviceType": "macos"}
  ];
  final ScrollController _scrollController =
      ScrollController(); //ListView 滑动控制器

  @override
  void initState() {
    super.initState();
    _initState();

    //界面build完成后执行回调函数
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    // });
  }

  void _initState() async {
    //this.remoteDevices = _getBaseName(filesLog);
    //await prefs!.setStringList("remoteDevices", filesLog);
  }

  @override
  Widget build(BuildContext context) {
    return remoteDevicesData.isEmpty ? remoteDevicesIsEmpty() : remoteDevicesNotEmpty();
  }

  Widget remoteDevicesIsEmpty() {
    //Expanded 和 Container 结合使用可以占满剩余高度
    return Expanded(
        child: Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: const Text(
              '暂未发现局域网设备',
              style: TextStyle(color: Colors.black),
            )));
  }

  Widget remoteDevicesNotEmpty() {
    return Expanded(child: 
      Scrollbar(
        child: 
          ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(5),
            reverse: false,
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 5);
            },
            itemCount: remoteDevicesData.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  color: index == remoteDevicesData.length - 1 ? const Color(0xffFC6621)  : const Color(0xffFF9E3D),
                  child: ListTile(
                      //contentPadding: const EdgeInsets.all(5),
                      //tileColor: const Color(0xffFF9E3D),
                      //selectedTileColor:const Color(0xff1122dd),
                      iconColor: const Color(0xffFFFFFF),
                      textColor: const Color(0xffFFFFFF),
                      //selectedColor:const Color(0xff1122dd),
                      //focusColor:Color.fromARGB(255, 197, 30, 30),
                      //hoverColor:Color.fromARGB(255, 185, 28, 216),
                      //splashColor: Color.fromARGB(255, 62, 204, 44),

                      isThreeLine: false,
                      title: Text(remoteDevicesData[index]["deviceName"]),
                      subtitle: Text("${remoteDevicesData[index]["lanIP"]!}",style: const TextStyle(fontSize: 12.0,color: Color.fromARGB(255, 250, 250, 250))),
                      trailing: const SizedBox(width: 120, child: Text("设为同步设备"))));
            },
          ))
      );
  }

  void addRemoteDevice() {}

  // void insertFilesLog(String fileInfoJson) async {
  //   List<String>? filesLog = prefs!.getStringList("remoteDevices") ?? [];
  //   filesLog.add(fileInfoJson);
  //   //遍历文件是否存在
  //   for(int i = 0; i < filesLog.length; i++){
  //     String fileFullPath = jsonDecode(filesLog[i])["fileFullPath"];
  //     bool fileExist = await File(fileFullPath).exists();
  //     if(fileExist == false){
  //       filesLog.removeAt(i);
  //     }
  //   }
  //   await prefs!.setStringList("remoteDevices", filesLog);
  //   // ignore: unnecessary_this
  //   this.remoteDevices = _getBaseName(filesLog);
  //   setState(() {});
  //   // 延迟500毫秒，再进行滑动
  //   Future.delayed(Duration(milliseconds: 500), () {
  //     _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  //   });
  // }

  // void delFilesLog(String filePath) async{
  //   File file = File(filePath);
  //   if (file.existsSync()) {
  //     file.deleteSync();
  //   } else {
  //     log("文件不存在",StackTrace.current);
  //   }
  //   //遍历文件是否存在
  //   List<String>? filesLog = prefs!.getStringList("remoteDevices") ?? [];
  //   for(int i = 0; i < filesLog.length; i++){
  //     String fileFullPath = jsonDecode(filesLog[i])["fileFullPath"];
  //     bool fileExist = File(filesLog[i]).existsSync();
  //     if(fileExist == false || fileFullPath == filePath){
  //       filesLog.removeAt(i);
  //     }
  //   }
  //   await prefs!.setStringList("remoteDevices", filesLog);
  //   // ignore: unnecessary_this
  //   this.remoteDevices = _getBaseName(filesLog);
  //   setState(() {});
  // }

  // void selectFilesLog() async{
  //   List<String>? filesLog = prefs!.getStringList("remoteDevices") ?? [];
  //   //遍历文件是否存在
  //   for(int i = 0; i < filesLog.length; i++){
  //     String fileFullPath = jsonDecode(filesLog[i])["fileFullPath"];
  //     bool fileExist = await File(fileFullPath).exists();
  //     if(fileExist == false){
  //       filesLog.removeAt(i);
  //     }
  //   }

  //   await prefs!.setStringList("remoteDevices", filesLog);
  //   // ignore: unnecessary_this
  //   this.remoteDevices = _getBaseName(filesLog);
  //   setState(() {});
  // }

  // List<Map<String,dynamic>> _getBaseName(List<String> filesLog){
  //   List<Map<String,dynamic>> baseNameFilesLog = [];
  //   for(int i = 0; i < filesLog.length; i++){
  //     Map<String,dynamic> fileInfoMap = jsonDecode(filesLog[i]);
  //     fileInfoMap["fileFullPath"] = fileInfoMap["fileFullPath"];
  //     baseNameFilesLog.add(fileInfoMap);
  //     //baseNameFilesLog.add(filesLog[i]);
  //   }
  //   return baseNameFilesLog;
  // }
}
