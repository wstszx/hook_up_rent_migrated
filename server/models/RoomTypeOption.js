const mongoose = require('mongoose');

const RoomTypeOptionSchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true }, // e.g., "一室", "二室"
  order: { type: Number, default: 0 }
});

module.exports = mongoose.model('RoomTypeOption', RoomTypeOptionSchema);