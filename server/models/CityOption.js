const mongoose = require('mongoose');

const CityOptionSchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true },
  districts: [{ type: String }],
  order: { type: Number, default: 0 }
});

module.exports = mongoose.model('CityOption', CityOptionSchema);