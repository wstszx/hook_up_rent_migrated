import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/home/tab_index/index_recommand_data.dart';
import 'package:hook_up_rent/widgets/common_image.dart';

var textStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

class IndexRecommandItemWidget extends StatelessWidget {
  final IndexRecommendItem data;

  const IndexRecommandItemWidget({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 使用 data.navigateUrl 进行导航
        // 如果 navigateUrl 只是一个简单的路由名:
        // Navigator.pushNamed(context, data.navigateUrl);

        // 假设我们想导航到搜索页，并传递标题作为参数
        // 您需要确保有一个名为 '/search' 的路由，并且它能处理参数
        Navigator.pushNamed(context, '/search', arguments: {'query': data.title});
      },
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        width: (MediaQuery.of(context).size.width - 10 * 3) / 2,
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  data.title,
                  style: textStyle,
                ),
                Text(
                  data.subTitle,
                  style: textStyle,
                )
              ],
            ),
            CommonImage(data.imageUrl, width: 55),
          ],
        ),
      ),
    );
  }
}
