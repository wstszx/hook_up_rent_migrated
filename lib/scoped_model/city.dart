import 'package:scoped_model/scoped_model.dart';
import '../models/general_type.dart';

class CityModel extends Model {
  GeneralType? _city; // 改为可空类型

  set city(GeneralType? data) { // setter 的参数也改为可空
    _city = data;
    notifyListeners();
  }

  GeneralType? get city { // getter 返回类型改为可空
    return _city;
  }

  // 可选：添加一个方法来获取城市名称，处理 null 情况
  String get cityNameOrDefault {
    return _city?.name ?? '定位中...';
  }
}
