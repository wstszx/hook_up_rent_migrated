const mongoose = require('mongoose');

const RentTypeOptionSchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true }, // e.g., "整租", "合租"
  order: { type: Number, default: 0 }
});

module.exports = mongoose.model('RentTypeOption', RentTypeOptionSchema);