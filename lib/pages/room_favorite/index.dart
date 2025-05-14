import 'package:flutter/material.dart';

class RoomFavoritePage extends StatelessWidget {
  const RoomFavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('这里是我的收藏页面'),
      ),
    );
  }
}