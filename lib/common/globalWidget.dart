import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rabbit_clipboard/common/func.dart';
import 'package:rabbit_clipboard/common/globalVariable.dart';

class headerWidget extends StatefulWidget {
  const headerWidget({super.key});

  @override
  State<headerWidget> createState() => _headerWidgetState();
}

class _headerWidgetState extends State<headerWidget> {
  @override
  void initState() {
    super.initState();
    //添加监听
    //WidgetsBinding.instance.addObserver(this);
  }

  EdgeInsets paddingDiff() {
    if (Platform.isIOS || Platform.isAndroid) {
      //手机状态栏高度
      double top = MediaQueryData.fromView(window).padding.top;
      return EdgeInsets.fromLTRB(0, top, 0, 10);
    } else {
      return const EdgeInsets.fromLTRB(0, 10, 0, 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.blue,
        padding: paddingDiff(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                Icon(
                  getRemoteDeviceTypeIcon(GlobalVariables.deviceInfo['deviceType']),
                  size: 16,
                  color: Colors.white,
                ),
                Text(
                  GlobalVariables.deviceInfo['model']!,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.location_pin,
                  size: 16,
                  color: Colors.white,
                ),
                Text(
                  GlobalVariables.deviceInfo['lanIPText']!,
                  style: const TextStyle(color: Colors.white),
                )
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.wifi,
                  size: 16,
                  color: Colors.white,
                ),
                Text(
                  GlobalVariables.deviceInfo['networkText']!,
                  style: const TextStyle(color: Colors.white),
                )
              ],
            ),
          ],
        ));
  }
}

// Widget getHeaderWidget() {


//   return ;
// }
