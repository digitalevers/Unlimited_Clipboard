import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tabs/sync_devices.dart';
import 'tabs/sync_history.dart';

import 'package:rabbit_clipboard/pages/modules/privacy_page.dart';
import 'package:rabbit_clipboard/services/client.dart';
import 'package:rabbit_clipboard/common/config.dart';
import 'package:rabbit_clipboard/common/func.dart';
import 'package:rabbit_clipboard/common/global_variable.dart';
//import 'package:showcaseview/showcaseview.dart';

class Tabs extends StatefulWidget {
  //final GlobalKey tabsKey;
  const Tabs({super.key});

  @override
  State<Tabs> createState() {
    return _nameState();
  }
}

// ignore: camel_case_types
class _nameState extends State<Tabs> with SingleTickerProviderStateMixin {
  //默认显示的tab index
  int _currentIndex = 0;
  // ignore: non_constant_identifier_names
  Icon _FloatingActionButtonIcon = const Icon(Icons.add, color: Colors.white);
  List<Map<String, String>> chooseFiles = [];
  String showShortFileName = '';
  final List<Widget> _pages = [
    const SyncDevices(),
    const SyncHistory(),
  ];


  //新手引导蒙层
  final GlobalKey _one = GlobalKey();

  late BuildContext myContext;

  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
    print('tabs-deactivate');
  }

  @override
  void dispose() {
    super.dispose();
    print('tabs-dispose');
  }

  @override
  Widget build(BuildContext context) {
    bool allowPrivacy = prefs?.getBool("allowPrivacy") ?? false;
    if (allowPrivacy) {
      //置于initState中只会执行一次
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          //ShowCaseWidget.of(myContext).startShowCase([_one]);
        });
      });

      return Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              if (index == 2) {
                if (chooseFiles.isNotEmpty) {
                  chooseFiles.clear();
                  _FloatingActionButtonIcon =
                      const Icon(Icons.add, color: Colors.white);
                }
              } else {
                _currentIndex = index;
              }
            });
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.devices), label: "同步设备"),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: "同步历史"),
          ],
        ),
        //新手引导蒙层只在app安装时提示一次
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      );
    } else {
      return const PrivacyPage();
    }
  }
}
