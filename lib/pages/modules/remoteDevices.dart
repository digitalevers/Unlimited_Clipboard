import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
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
                  color: const Color.fromARGB(255, 255, 255, 255),
                  child: ListTile(
                      //dense:false,
                      contentPadding: const EdgeInsets.all(0),
                      //tileColor: const Color(0xffFF9E3D),
                      //selectedTileColor:const Color(0xff1122dd),
                      leading:Icon(
                          getRemoteDeviceTypeIcon(remoteDevicesData[index]["deviceType"]),
                          color: const Color.fromARGB(255, 126, 126, 126),
                        ),
                      //iconColor: Color.fromARGB(255, 134, 134, 134),
                      textColor: const Color.fromARGB(255, 126, 126, 126),
                      //selectedColor:const Color(0xff1122dd),
                      //focusColor:Color.fromARGB(255, 197, 30, 30),
                      //hoverColor:Color.fromARGB(255, 185, 28, 216),
                      //splashColor: Color.fromARGB(255, 62, 204, 44),

                      isThreeLine: false,
                      title: Text(remoteDevicesData[index]["deviceName"]),
                      subtitle: Text("${remoteDevicesData[index]["lanIP"]!}",style: const TextStyle(fontSize: 12.0,color: Color.fromARGB(255, 126, 126, 126))),
                      trailing: InkWell(
                                onTap:(){
                                  BotToast.showText(text: "已取消同步");
                                },
                                child:Container(
                                  width: 120,
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  //child: Text("设为同步设备",style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
                                  
                                  color:const Color(0xFFFC6621),
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      CustomPaint(
                                        painter: ArcPainter(labelTitle: "123"),
                                        size: const Size(26,26), // 调整大小以适应你的需求
                                      ),
                                      const Positioned(child: Icon(Icons.sync,size: 16,color: Colors.white)),
                                      const Center(child: Text("取消同步",style: TextStyle(color: Color(0xFFe41749))))
                                    ]
                                  )
                                )),
                                
                      ));
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

class ArcPainter extends CustomPainter {

  //标签文字
  String labelTitle;
  ArcPainter({required this.labelTitle});

  @override
  void paint(Canvas canvas, Size size) {
    double originX = 0.0 ;
    double originY = 0.0 ;

    double cx = size.width / 2;
    double cy = size.height / 2;
    Paint _paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
    //画笔是线段（默认是fill填充）
    /*..style = PaintingStyle.stroke*/;

    // canvas.drawCircle(Offset(cx,cy), 2, _paint);
    Path path = Path();
    // 绘制圆锥路径 权重越大路径越接近直角（不使用path.moveTo时，默认起点为左上角）
    path.conicTo(originX + size.width, originY, originX + size.width, originY+ size.height, 100);
    // 控制路径是否闭合，可不写
    path.close();
    canvas.drawPath(path, _paint);
    canvas.save();
    canvas.restore();

    // TextPainter textPainterCenter = TextPainter(
    //   text: TextSpan(text: labelTitle, style: TextStyle(color: Color(0xff333333),fontSize: 10)),
    //   textDirection: TextDirection.ltr,
    // );
    // textPainterCenter.layout();
    canvas.rotate(pi / 4);
    canvas.translate(- pi , -((cy - pi)  * 2));
    //textPainterCenter.paint(canvas, Offset(cx /*- textPainterCenter.size.width / 2*/,cy - textPainterCenter.size.height / 4));
    canvas.save();
    canvas.restore();
  }

  /// 度数转类似于π的那种角度
  double degToRad(double deg) => deg * (pi / 180.0);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
