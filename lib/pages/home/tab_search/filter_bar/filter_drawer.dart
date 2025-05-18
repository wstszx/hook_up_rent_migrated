import 'package:flutter/material.dart';
import 'package:rent_share/pages/home/tab_search/filter_bar/data.dart';
import 'package:rent_share/pages/utils/scoped_model_helper.dart';
import 'package:rent_share/scoped_model/room_filter.dart';
import 'package:rent_share/widgets/common_title.dart';

class FilterDrawer extends StatelessWidget {
  const FilterDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var model = ScopedModelHelper.getModel<FilterBarModel>(context);
    var dataList = model.dataList;

    // 获取所有筛选列表
    // var cityList = dataList['cityList'];
    // var districtList = dataList['districtList']; // 注意：这个列表可能依赖于选中的城市
    // var rentTypeList = dataList['rentTypeList']; // 移除
    // var priceList = dataList['priceList']; // 移除
    // var tagList = dataList['tagList']; // 移除
    var roomTypeList = dataList['roomTypeList'];
    var orientedList = dataList['orientedList'];
    var floorList = dataList['floorList'];

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 60.0), // 为底部的按钮留出空间
          children: [
            // 城市 (单选) - Dropdown or custom single select item
            // 暂时不实现城市和区域，因为它们通常在顶部筛选栏处理，或者需要更复杂的UI
            // const CommonTitle('城市'),
            // if (cityList != null)
            //   FilterDrawerItem(
            //     list: cityList,
            //     selectIds: model.selectedCityId != null ? [model.selectedCityId!] : [],
            //     onChange: (id) => model.selectedCityId = id,
            //   ),

            // // 区域 (单选) - Dropdown or custom single select item
            // const CommonTitle('区域'),
            // if (districtList != null && model.selectedCityId != null) // 仅当城市被选中时显示区域
            //   FilterDrawerItem(
            //     list: districtList, // 需要确保 districtList 根据 selectedCityId 更新
            //     selectIds: model.selectedDistrictId != null ? [model.selectedDistrictId!] : [],
            //     onChange: (id) => model.selectedDistrictId = id,
            //   ),

            // const CommonTitle('方式'), // 移除
            // if (rentTypeList != null) // 移除
            //   FilterDrawerItem( // 移除
            //     list: rentTypeList, // 移除
            //     // 单选时，selectIds 列表只包含选中的那个 id
            //     selectIds: model.selectedRentTypeId != null ? [model.selectedRentTypeId!] : [], // 移除
            //     onChange: (id) { // 移除
            //       // 如果当前点击的已经是选中的，则取消选中 (可选行为)
            //       // if (model.selectedRentTypeId == id) {
            //       //   model.selectedRentTypeId = null;
            //       // } else {
            //       //   model.selectedRentTypeId = id;
            //       // }
            //       model.selectedRentTypeId = id; // 直接设置为选中的ID // 移除
            //     }, // 移除
            //   ), // 移除
            
            // const CommonTitle('价格'), // 移除
            // if (priceList != null) // 移除
            //   FilterDrawerItem( // 移除
            //     list: priceList, // 移除
            //     selectIds: model.selectedPriceId != null ? [model.selectedPriceId!] : [], // 移除
            //     onChange: (id) { // 移除
            //       model.selectedPriceId = id; // 移除
            //     }, // 移除
            //   ), // 移除

            const CommonTitle('户型'),
            if (roomTypeList != null)
              FilterDrawerItem(
                list: roomTypeList,
                selectIds: model.selectedRoomTypeList.toList(),
                onChange: (id) {
                  model.toggleSelectedRoomTypeItem(id);
                },
              ),

            const CommonTitle('朝向'),
            if (orientedList != null)
              FilterDrawerItem(
                list: orientedList,
                selectIds: model.selectedOrientedList.toList(),
                onChange: (id) {
                  model.toggleSelectedOrientedItem(id);
                },
              ),

            const CommonTitle('楼层'),
            if (floorList != null)
              FilterDrawerItem(
                list: floorList,
                selectIds: model.selectedFloorList.toList(),
                onChange: (id) {
                  model.toggleSelectedFloorItem(id);
                },
              ),
            
            // const CommonTitle('标签'), // 移除
            // if (tagList != null) // 移除
            //   FilterDrawerItem( // 移除
            //     list: tagList, // 移除
            //     selectIds: model.selectedTagList.toList(), // 移除
            //     onChange: (id) { // 移除
            //       model.toggleSelectedTagItem(id); // 移除
            //     }, // 移除
            //   ), // 移除
            
            // 清除和确认按钮
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        model.clearSelections();
                      },
                      child: const Text('清除'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 获取筛选参数并关闭抽屉，触发外部的搜索逻辑
                        var filters = model.getApiFilterParams;
                        print('Selected filters: $filters');
                        Navigator.of(context).pop();
                        // TODO: 在这里可以调用一个回调函数，将 filters 传递给父组件以执行搜索
                      },
                      child: const Text('确定'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FilterDrawerItem extends StatelessWidget {
  final List<GeneralType> list; // 改为非 nullable，因为前面有 if 判断
  final List<String> selectIds; // 改为 List<String>
  final ValueChanged<String> onChange; // 改为非 nullable

  const FilterDrawerItem(
      {Key? key,
      required this.list,
      required this.selectIds,
      required this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0), // 统一使用 padding
      // margin: const EdgeInsets.only(left: 10, right: 10), // 使用 padding 代替
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: list.map((item) {
          var isActive = selectIds.contains(item.id);

          return GestureDetector(
            onTap: () {
              onChange(item.id);
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              width: (MediaQuery.of(context).size.width - 40 - 20) / 3, // 动态计算宽度，一行3个
              height: 40,
              decoration: BoxDecoration(
                  color: isActive ? Theme.of(context).primaryColor : Colors.grey[200],
                  border: Border.all(
                    width: 1,
                    color: isActive ? Theme.of(context).primaryColor : Colors.grey[400]!
                  ),
                  borderRadius: BorderRadius.circular(4.0) // 添加圆角
              ),
              child: Center(
                child: Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: isActive ? Colors.white : Colors.black87,
                      fontSize: 14.0
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

