import 'package:flutter/material.dart';
import 'package:rabbit_clipboard/common/globalWidget.dart';

class SyncDevices extends StatefulWidget {
  const SyncDevices({super.key});

  @override
  State<SyncDevices> createState() => _SyncDevicesState();
}

class _SyncDevicesState extends State<SyncDevices> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        getHeaderWidget()
      ],
    );
  }
}

