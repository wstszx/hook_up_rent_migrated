import 'package:flutter/material.dart';
import 'package:rent_share/config.dart';
import 'package:rent_share/pages/home/info/info_data.dart';

var textStyle = const TextStyle(color: Colors.black54);

class InfoItemWidget extends StatelessWidget {
  final InfoItem data;

  const InfoItemWidget({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    return InkWell(      onTap: () {
        Navigator.of(context).pushNamed('news_detail', arguments: {'data': data});
      },
      child: Container(
        height: 100,
        padding: const EdgeInsets.only(left: 10, bottom: 10, right: 10),
        child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: Image.network(
              data.imageUrl.startsWith('http')
                  ? data.imageUrl
                  : '${Config.BaseUrl}${data.imageUrl}',
              width: 120.0,
              height: 90.0,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120.0,
                  height: 90.0,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Text('暂无图片'),
                  ),
                );
              },
            ),
          ),
          const Padding(padding: EdgeInsets.only(left: 10)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data.source, style: textStyle),
                    Text(data.time, style: textStyle),
                  ],
                )
              ],
            ),
          )        ],
      ),
    ),
    );
  }
}

