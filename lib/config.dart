import 'pages/home/tab_search/filter_bar/data.dart' as file_data;

class Config {
  static const CommonIcon = 'CommonIcon';
  static const BaseUrl =
      'http://192.168.1.3:3000/'; // <-- 请将 YOUR_COMPUTER_IP 替换为您的实际IP地址
  static const DefaultImage = 'https://via.placeholder.com/150/CCCCCC/FFFFFF?Text=No+Image';


  static List<file_data.GeneralType> availableCitys = [
    file_data.GeneralType('北京市', '北京市'),
    file_data.GeneralType('上海市', '上海市'),
    file_data.GeneralType('广州市', '广州市'),
    file_data.GeneralType('深圳市', '深圳市'),
  ];
}
