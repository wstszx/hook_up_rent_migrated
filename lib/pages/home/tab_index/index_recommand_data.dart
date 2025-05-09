class IndexRecommendItem {
  final String title;
  final String subTitle;
  final String imageUrl;
  final String navigateUrl;
  const IndexRecommendItem(
      this.title, this.subTitle, this.imageUrl, this.navigateUrl);
}

const List<IndexRecommendItem> indexRecommendData = [
  IndexRecommendItem(
      '家住回龙观', '归属的感觉', 'static/images/home_index_recommend_1.png', '/search'),
  IndexRecommendItem(
      '宜居四五环', '大都市生活', 'static/images/home_index_recommend_2.png', '/search'),
  IndexRecommendItem(
      '喧嚣三里屯', '繁华的背后', 'static/images/home_index_recommend_3.png', '/search'),
  IndexRecommendItem(
      '比邻十号线', '地铁心连心', 'static/images/home_index_recommend_4.png', '/search'),
];
