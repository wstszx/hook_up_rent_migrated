import 'models/general_type.dart';

class Config {
  static const CommonIcon = 'CommonIcon';
  static const BaseUrl =
      'http://192.168.1.6:3000'; // <-- 请将 YOUR_COMPUTER_IP 替换为您的实际IP地址

  static List<GeneralType> availableCitys = [
    GeneralType('北京', 'AREA|88cff55c-aaa4-e2e0'),
    GeneralType('上海', 'AREA|dbf46d32-7e76-1196'),
    GeneralType('广州', 'AREA|88cff55c-aaa4-e2e0'),
    GeneralType('深圳', 'AREA|88cff55c-aaa4-e2e0'),
  ];
}
