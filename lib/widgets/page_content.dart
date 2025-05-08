import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/routes.dart';

class PageContent extends StatelessWidget {
  final String name;

  const PageContent({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('当前页面：$name')),
      body: Center(
        child: Text('这是 $name 页面'),
      ),
    );
  }
}
