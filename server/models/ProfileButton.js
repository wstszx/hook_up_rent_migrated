const mongoose = require('mongoose');

const ProfileButtonSchema = new mongoose.Schema({
  imageUrl: { type: String, required: true },
  title: { type: String, required: true },
  actionType: { type: String, required: true }, // e.g., NAVIGATE, NAVIGATE_WITH_AUTH_CHECK, SHOW_CONTACT_INFO
  actionValue: { type: String }, // Route name or other value depending on actionType
  fallbackActionValue: { type: String }, // For NAVIGATE_WITH_AUTH_CHECK
  order: { type: Number, default: 0 } // For ordering buttons if needed
});

module.exports = mongoose.model('ProfileButton', ProfileButtonSchema);