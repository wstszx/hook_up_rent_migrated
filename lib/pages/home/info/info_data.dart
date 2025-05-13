// 资讯数据准备,注意下面的格式
import 'dart:math';

class InfoItem {
  final String title;
  final String imageUrl;
  final String source;
  final String time;
  final String navigateUrl;

  const InfoItem(
      this.title, this.imageUrl, this.source, this.time, this.navigateUrl);
}

// 将 const List<InfoItem> infoData 修改为函数以动态生成数据
List<InfoItem> getGeneratedInfoData() {
  // 模拟一些基础数据
  const baseTitles = [
    '置业选择 | 三室一厅 河间的古雅别院',
    '置业佳选 | 大理王宫 苍山洱海间的古雅别院',
    '置业选择 | 安居小屋 花园洋房 清新别野',
    '最新动态 | 城市发展新规划解读',
    '房产快讯 | 本月热门楼盘推荐'
  ];
  const baseImageUrls = [
    'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1560518883-ce09059eeffa?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80'
  ];
  const sources = ["新华网", "本地快讯", "房产周刊", "财经在线"];
  final Random random = Random();

  List<InfoItem> generatedData = [];

  // 第一条资讯，设定为今天
  generatedData.add(InfoItem(
    '${baseTitles[random.nextInt(baseTitles.length)]} (今日推荐)',
    baseImageUrls[random.nextInt(baseImageUrls.length)],
    sources[random.nextInt(sources.length)],
    "今天",
    'login', // navigateUrl 可以根据实际情况修改
  ));

  // 第二条资讯，设定为昨天
  generatedData.add(InfoItem(
    '${baseTitles[random.nextInt(baseTitles.length)]} (昨日热点)',
    baseImageUrls[random.nextInt(baseImageUrls.length)],
    sources[random.nextInt(sources.length)],
    "昨天",
    'login',
  ));

  // 其他几条资讯，设定为几天前
  for (int i = 0; i < 3; i++) {
    int daysAgo = random.nextInt(5) + 2; // 2到6天前
    generatedData.add(InfoItem(
      baseTitles[random.nextInt(baseTitles.length)],
      baseImageUrls[random.nextInt(baseImageUrls.length)],
      sources[random.nextInt(sources.length)],
      "$daysAgo天前",
      'login',
    ));
  }
  return generatedData;
}

/*  原有的静态数据，可以注释或删除
const List<InfoItem> infoData = [
  InfoItem(
      '置业选择 | 三室一厅 河间的古雅别院',
      'https://wx2.sinaimg.cn/mw1024/005SQLxwly1g6f89l4obbj305v04fjsw.jpg',
      "新华网",
      "两天前",
      'login'),
  InfoItem(
      '置业佳选 | 大理王宫 苍山洱海间的古雅别院',
      'https://wx2.sinaimg.cn/mw1024/005SQLxwly1g6f89l6hnsj305v04fab7.jpg',
      "新华网",
      "一周前",
      'login'),
  InfoItem(
      '置业选择 | 安居小屋 花园洋房 清新别野',
      'https://wx4.sinaimg.cn/mw1024/005SQLxwly1g6f89l5jlyj305v04f75q.jpg',
      "新华网",
      "一周前",
      'login'),
  InfoItem(
      '置业选择 | 安居小屋 花园洋房 清新别野 山清水秀',
      'https://wx4.sinaimg.cn/mw1024/005SQLxwly1g6f89l5jlyj305v04f75q.jpg',
      "新华网",
      "一周前",
      'login'),
  InfoItem(
      '置业选择 | 安居小屋 花园洋房 清新别野',
      'https://wx4.sinaimg.cn/mw1024/005SQLxwly1g6f89l5jlyj305v04f75q.jpg',
      "新华网",
      "一周前",
      'login'),
];
*/
