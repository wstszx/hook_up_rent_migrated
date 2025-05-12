const mongoose = require('mongoose');

const RecommendationSchema = new mongoose.Schema({
  title: { type: String, required: true },
  subTitle: { type: String, required: true },
  imageUrl: { type: String, required: true },
  navigateUrl: { type: String, required: true },
  city: { type: String, required: true, index: true } // 添加 city 字段，并添加索引以提高查询效率
});

module.exports = mongoose.model('Recommendation', RecommendationSchema);