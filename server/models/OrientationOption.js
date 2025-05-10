const mongoose = require('mongoose');

const OrientationOptionSchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true }, // e.g., "东", "南"
  order: { type: Number, default: 0 }
});

module.exports = mongoose.model('OrientationOption', OrientationOptionSchema);