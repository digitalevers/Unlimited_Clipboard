import 'package:flutter/material.dart';
import 'package:rabbit_clipboard/common/globalWidget.dart';

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
        getHeaderWidget()
      ],
    );
  }
}