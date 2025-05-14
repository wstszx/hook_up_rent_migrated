import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/home/info/info_data.dart';

class NewsDetailPage extends StatelessWidget {
  final InfoItem data;

  const NewsDetailPage({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('资讯详情'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                data.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // 作者和时间
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    data.source,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    data.time,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            // 图片
            if (data.imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Image.network(
                    data.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            // 内容 (假设我们暂时只展示标题作为内容，后续可以从后端获取完整内容)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                data.title,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
