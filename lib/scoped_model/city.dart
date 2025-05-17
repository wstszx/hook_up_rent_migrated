import 'package:scoped_model/scoped_model.dart';
import '../pages/home/tab_search/filter_bar/data.dart' as file_data;

class CityModel extends Model {
  file_data.GeneralType? _city; // 改为可空类型

  set city(file_data.GeneralType? data) { // setter 的参数也改为可空
    _city = data;
    notifyListeners();
  }

  file_data.GeneralType? get city { // getter 返回类型改为可空
    return _city;
  }

  // 可选：添加一个方法来获取城市名称，处理 null 情况
  String get cityNameOrDefault {
    return _city?.name ?? '定位中...';
  }
}
