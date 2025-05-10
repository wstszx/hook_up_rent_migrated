const mongoose = require('mongoose');

const NewsItemSchema = new mongoose.Schema({
  title: { type: String, required: true },
  imageUrl: { type: String, required: true },
  source: { type: String, required: true },
  time: { type: String, required: true }, // Could be Date type for more precise sorting/filtering
  navigateUrl: { type: String },
  publishDate: { type: Date, default: Date.now } // For ordering by publish date
});

module.exports = mongoose.model('NewsItem', NewsItemSchema);