import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import 'package:rabbit_clipboard/common/func.dart';
import 'package:rabbit_clipboard/common/globalVariable.dart';

//组件单独放在一个文件里则无法访问到 _syncLogState 该类为文件私有
class syncLog extends StatefulWidget {
  const syncLog({super.key});

  @override
  State<syncLog> createState() => _syncLogState();
}

// ignore: camel_case_types
class _syncLogState extends State<syncLog> {
  //读取pref获取同步记录
  List<String> syncLogData = [];

  final ScrollController _scrollController = ScrollController(); //ListView 滑动控制器

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

  }

  @override
  Widget build(BuildContext context) {
    syncLogData = GlobalVariables.prefs!.getStringList("syncLog") ?? [];
    return syncLogData.isEmpty ? syncLogIsEmpty() : syncLogNotEmpty();
  }

  Widget syncLogIsEmpty() {
    //Expanded 和 Container 结合使用可以占满剩余高度
    return Expanded(
        child: Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: const Text(
              '记录为空',
              style: TextStyle(color: Colors.black),
            )
        )
      );
  }



  Widget syncLogNotEmpty() {
    return 
    Expanded(child: 
      Column(children: [
        Expanded(child: 
          Scrollbar(
          child: 
            ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(5),
              reverse: false,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 5);
              },
              itemCount: syncLogData.length,
              itemBuilder: (BuildContext context, int index) {
                return 
                Container(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    child: ListTile(
                        //dense:false,
                        contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        //tileColor: const Color(0xffFF9E3D),
                        //selectedTileColor:const Color(0xff1122dd),
                        // leading:Icon(
                        //   getRemoteDeviceTypeIcon(syncLogData[index]["deviceType"]),
                        //   color: const Color.fromARGB(255, 126, 126, 126),
                        // ),
                        //iconColor: Color.fromARGB(255, 134, 134, 134),
                        textColor: const Color.fromARGB(255, 126, 126, 126),
                        //selectedColor:const Color(0xff1122dd),
                        //focusColor:Color.fromARGB(255, 197, 30, 30),
                        //hoverColor:Color.fromARGB(255, 185, 28, 216),
                        //splashColor: Color.fromARGB(255, 62, 204, 44),

                        isThreeLine: false,
                        title: Text(syncLogData[index]),
                        //subtitle: Text("${syncLogData[index]["lanIP"]!}",style: const TextStyle(fontSize: 12.0,color: Color.fromARGB(255, 126, 126, 126))),      
                      )
                );
              },
            )
            )
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          child:const Text("清空记录"),
          onPressed: () {
            GlobalVariables.prefs!.remove("syncLog").then((_){
              GlobalVariables.syncLogKey.currentState?.setState(() {});
              BotToast.showText(text: "记录已清空");
            });
          }
        ),
        const SizedBox(height: 10)
    ]))
    ;
  }
}

