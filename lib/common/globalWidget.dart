import 'package:flutter/material.dart';
import 'package:rabbit_clipboard/common/func.dart';
import 'package:rabbit_clipboard/common/globalVariable.dart';

Widget getHeaderWidget() {
  return Container(
      color: Colors.blue,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
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
                GlobalVariables.deviceInfo['lanIP']!,
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
      )
    );
}
