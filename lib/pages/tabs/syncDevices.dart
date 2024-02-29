import 'package:flutter/material.dart';
import 'package:rabbit_clipboard/common/func.dart';
import 'package:rabbit_clipboard/common/globalVariable.dart';
import 'package:rabbit_clipboard/common/globalWidget.dart';
import 'package:rabbit_clipboard/pages/modules/remoteDevices.dart';



class SyncDevices extends StatefulWidget {
  const SyncDevices({super.key});

  @override
  State<SyncDevices> createState() => _SyncDevicesState();
}

class _SyncDevicesState extends State<SyncDevices> {

  @override
  void initState() {
    super.initState();
    //界面build完成后执行回调函数
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   //_scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    //   log("syncDevices渲染完成");
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        headerWidget(key: GlobalVariables.headerWidgetKey),
        RemoteDevices(GlobalVariables.remoteDevicesKey),
      ],
    );
  }
}
