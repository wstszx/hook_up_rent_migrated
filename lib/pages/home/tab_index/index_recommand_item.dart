import 'package:flutter/material.dart';
import 'package:rent_share/pages/home/tab_index/index_recommand_data.dart';
import 'package:rent_share/widgets/common_image.dart';

var textStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

class IndexRecommandItemWidget extends StatelessWidget {
  final IndexRecommendItem data;
  final double width; // 接收从父组件传递过来的宽度

  const IndexRecommandItemWidget({required this.data, required this.width, super.key});

  @override
  Widget build(BuildContext context) {
    // 不再需要在这里计算宽度或打印 screenWidth，直接使用传入的 width
    // print('IndexRecommandItemWidget: Using passed width = $width');

    return GestureDetector(
      onTap: () {
        // 使用 data.navigateUrl 进行导航到房源详情页
        Navigator.pushNamed(context, data.navigateUrl);
      },
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        width: width, // 使用从父组件传递过来的宽度
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded( // Wrap the Column with Expanded
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
                children: [
                  Text(
                    data.title,
                    style: textStyle,
                    overflow: TextOverflow.ellipsis, // Handle text overflow
                    maxLines: 1, // Optional: Limit to one line
                  ),
                  Text(
                    data.subTitle,
                    style: textStyle,
                    overflow: TextOverflow.ellipsis, // Handle text overflow
                    maxLines: 1, // Optional: Limit to one line
                  )
                ],
              ),
            ),
            const SizedBox(width: 10), // Add some spacing between text and image
            CommonImage(data.imageUrl, width: 55),
          ],
        ),
      ),
    );
  }
}

