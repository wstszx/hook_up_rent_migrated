import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地图找房'),
      ),
      body: const Center(
        child: Text('地图页面，敬请期待！'),
      ),
    );
  }
}