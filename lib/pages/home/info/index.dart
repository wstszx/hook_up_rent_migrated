import 'package:flutter/material.dart';
import 'package:rent_share/pages/home/info/info_data.dart';
import 'package:rent_share/pages/home/info/item_widget.dart';
import 'package:rent_share/pages/utils/dio_http.dart'; // Import DioHttp

class Info extends StatefulWidget {
  final bool showTitle;

  const Info({super.key, this.showTitle = false});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  List<InfoItem> _infoList = [];

  @override
  void initState() {
    super.initState();
    _fetchNewsData();
  }

  Future<void> _fetchNewsData() async {
    try {
      final res = await DioHttp.of(context).get('/api/news');
      if (res.data != null && res.data is List) {
        List<InfoItem> newsItems = (res.data as List)
            .map((item) => InfoItem(
                  item['title'],
                  item['imageUrl'],
                  item['source'],
                  item['time'], // Assuming 'time' is provided by backend
                  item['navigateUrl'], // Assuming 'navigateUrl' is provided
                ))
            .toList();
        setState(() {
          _infoList = newsItems;
        });
      }
    } catch (e) {
      print('Error fetching news data: $e');
      // Handle error, maybe show a message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            if (widget.showTitle)
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  '最新资讯',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            Column(
              children: _infoList.map((item) => InfoItemWidget(data: item)).toList(),
            )
          ],
        )
      ],
    );
  }
}

