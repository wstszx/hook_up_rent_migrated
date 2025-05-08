import 'package:scoped_model/scoped_model.dart';
import '../models/general_type.dart';

class CityModel extends Model {
  late GeneralType _city;

  set city(GeneralType data) {
    _city = data;
    notifyListeners();
  }

  GeneralType get city {
    return _city;
  }
}
