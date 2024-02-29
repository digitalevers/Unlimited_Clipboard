import 'package:flutter/material.dart';
import 'package:rabbit_clipboard/common/globalVariable.dart';
import 'package:rabbit_clipboard/common/globalWidget.dart';
import 'package:rabbit_clipboard/pages/modules/syncLog.dart';

class SyncHistory extends StatefulWidget {
  const SyncHistory({super.key});

  @override
  State<SyncHistory> createState() => _SyncHistoryState();
}

class _SyncHistoryState extends State<SyncHistory> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        headerWidget(key: GlobalVariables.headerWidgetKey),
        syncLog(key: GlobalVariables.syncLogKey)
      ],
    );
  }
}