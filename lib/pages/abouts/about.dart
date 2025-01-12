import 'package:flutter/material.dart';
 
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('联系我们'),
      ),
      body: const Padding(padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '一款跨平台剪切板文本同步工具\n可以在手机与手机之间\n手机与电脑之间同步剪切板文本数据\n\n您在使用中有任何问题，欢迎联系我们',
                style: TextStyle(
                  fontSize: 18.0,
                ),
            ),
            Text(
                '邮箱：admin@digitalevers.com',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold
                ),
            ),
          ])
        )
    );
  }
}