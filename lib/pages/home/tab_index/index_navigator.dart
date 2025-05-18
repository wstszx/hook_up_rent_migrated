import 'package:flutter/material.dart';
import 'package:rent_share/pages/home/tab_index/index_navigator_item.dart';
import 'package:rent_share/widgets/common_image.dart';

class IndexNavigator extends StatelessWidget {
  const IndexNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: indexNavigatorItemList
            .map((item) => InkWell(
                  onTap: () {
                    item.onTap(context);
                  },
                  child: Column(
                    children: [
                      CommonImage(item.imageUrl, width: 47.5),
                      Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

