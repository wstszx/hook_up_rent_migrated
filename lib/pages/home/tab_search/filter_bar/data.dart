// 结果数据类型
class FilterBarResult {
  final String? areaId; // 区域
  final String? priceId; // 租金
  final String? rentTypeId; // 方式
  final List<String>? moreIds; // 筛选

  FilterBarResult(
      {this.areaId,
      this.priceId,
      this.rentTypeId,
      this.moreIds,
      String? priceTypeId,
      List<String>? moreId});
}

// 通用类型
class GeneralType {
  final String name;
  final String id;

  GeneralType(this.name, this.id);
}

List<GeneralType> areaList = [
  GeneralType('不限', 'area_any'), // "不限" 选项通常是需要的
  GeneralType('开福区', 'kf'),
  GeneralType('岳麓区', 'yl'),
  GeneralType('天心区', 'tx'),
  GeneralType('雨花区', 'yh'),
  GeneralType('芙蓉区', 'fr'),
];
List<GeneralType> priceList = [
  GeneralType('不限', 'price_any'),
  GeneralType('1000及以下', '0-1000'),
  GeneralType('1000-2000', '1000-2000'),
  GeneralType('2000-3000', '2000-3000'),
  GeneralType('3000-4000', '3000-4000'),
  GeneralType('4000-5000', '4000-5000'),
  GeneralType('5000以上', '5000-'),
];
List<GeneralType> rentTypeList = [
  GeneralType('不限', 'rent_type_any'),
  GeneralType('整租', 'whole'),
  GeneralType('合租', 'share'),
];
List<GeneralType> roomTypeList = [
  GeneralType('房屋类型1', '11'),
  GeneralType('房屋类型2', '22'),
];
List<GeneralType> orientedList = [
  GeneralType('方向1', '99'),
  GeneralType('方向2', 'cc'),
];
List<GeneralType> floorList = [
  GeneralType('楼层1', 'aa'),
  GeneralType('楼层2', 'bb'),
];
