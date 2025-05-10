const mongoose = require('mongoose');

const IndexNavigatorItemSchema = new mongoose.Schema({
  title: { type: String, required: true },
  imageUrl: { type: String, required: true },
  actionType: { type: String, required: true }, // e.g., NAVIGATE, NAVIGATE_WITH_PARAMS, NAVIGATE_WITH_AUTH_CHECK
  actionValue: { type: String }, // Route name or other value
  params: { type: mongoose.Schema.Types.Mixed }, // For NAVIGATE_WITH_PARAMS
  order: { type: Number, default: 0 } // For ordering items
});

module.exports = mongoose.model('IndexNavigatorItem', IndexNavigatorItemSchema);