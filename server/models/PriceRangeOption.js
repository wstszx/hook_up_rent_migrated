const mongoose = require('mongoose');

const PriceRangeOptionSchema = new mongoose.Schema({
  label: { type: String, required: true, unique: true }, // e.g., "1000元以下"
  value: { type: String, required: true, unique: true }, // e.g., "0-1000"
  order: { type: Number, default: 0 }
});

module.exports = mongoose.model('PriceRangeOption', PriceRangeOptionSchema);