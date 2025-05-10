const mongoose = require('mongoose');

const RecommendationSchema = new mongoose.Schema({
  title: { type: String, required: true },
  subTitle: { type: String, required: true },
  imageUrl: { type: String, required: true },
  navigateUrl: { type: String, required: true }
});

module.exports = mongoose.model('Recommendation', RecommendationSchema);