import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/home/tab_index/index_recommand_data.dart';
import 'package:hook_up_rent/pages/home/tab_index/index_recommand_item.dart';

class IndexRecommand extends StatelessWidget {
  final List<IndexRecommendItem> dataList;

  const IndexRecommand({super.key, this.dataList = indexRecommendData});

  @override
  Widget build(BuildContext context) {
    // 在父组件中计算 item 的宽度
    // IndexRecommand 的根 Container 有 padding: const EdgeInsets.all(10)
    // Wrap 的 spacing 是 10
    // 目标是一行显示两个 item
    final screenWidth = MediaQuery.of(context).size.width;
    // Wrap 内部的可用宽度 = screenWidth - 父Container的左右padding
    final wrapAvailableWidth = screenWidth - 2 * 10;
    // 两个 item 之间的间距是 10 (Wrap的spacing)
    // 所以每个 item 的宽度 = (wrapAvailableWidth - item之间的间距) / 2
    double itemWidth = (wrapAvailableWidth - 10) / 2;

    // 安全检查，确保 itemWidth 不为负或过小
    if (itemWidth < 0) {
      print('IndexRecommand: Calculated itemWidth is negative or zero ($itemWidth), screenWidth was $screenWidth. Setting to a default small width.');
      itemWidth = 50; // 或者一个合理的最小值，或者不渲染
    } else {
      print('IndexRecommand: screenWidth = $screenWidth, wrapAvailableWidth = $wrapAvailableWidth, calculated itemWidth = $itemWidth');
    }
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(color: Color(0x08000000)), // 稍微有点透明度的灰色背景，方便调试看边界
      child: Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '房屋推荐',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
                Text(
                  '更多',
                  style: TextStyle(color: Colors.black54),
                )
              ]),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10, // 主轴上 children 的间距
            runSpacing: 10, // 纵轴上 children 的间距
            children: dataList
                .map((item) => IndexRecommandItemWidget(data: item, width: itemWidth)) // 将计算好的宽度传递下去
                .toList(),
          ),
        ],
      ),
    );
  }
}
