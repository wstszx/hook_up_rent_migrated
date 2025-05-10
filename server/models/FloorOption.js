const mongoose = require('mongoose');

const FloorOptionSchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true }, // e.g., "低楼层", "中楼层"
  order: { type: Number, default: 0 }
});

module.exports = mongoose.model('FloorOption', FloorOptionSchema);