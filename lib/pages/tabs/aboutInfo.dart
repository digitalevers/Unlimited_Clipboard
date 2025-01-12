import 'package:flutter/material.dart';
import 'package:rabbit_clipboard/pages/abouts/about.dart';
import 'package:rabbit_clipboard/pages/abouts/privacy.dart';
import 'package:rabbit_clipboard/pages/abouts/userprotocol.dart';

class AboutInfo extends StatefulWidget {
  const AboutInfo({super.key});

  @override
  State<AboutInfo> createState() => _AboutInfoState();
}

class _AboutInfoState extends State<AboutInfo> {

  @override
  void initState() {
    super.initState();
    //界面build完成后执行回调函数
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   //_scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    //   log("aboutInfo渲染完成");
    // });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('隐私政策'),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const Privacy(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0), 
                        end: const Offset(0.0, 0.0),
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('用户协议'),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const Userprotocol(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0), 
                        end: const Offset(0.0, 0.0),
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('联系我们'),
            onTap: () {
              // 处理点击事件，例如显示关于页面
              Navigator.push(
                context,
                //渐隐渐显滑入
                //MaterialPageRoute(builder: (context) => AboutPage()),

                //左右滑入
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => AboutPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),    //const Offset(-1.0, 0.0) 向右滑入  正数向左滑入
                        end: const Offset(0.0, 0.0),
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
          // 可以继续添加更多的ListTile项
        ],
      );
  }
}