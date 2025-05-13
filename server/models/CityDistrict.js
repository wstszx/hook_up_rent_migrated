const mongoose = require('mongoose');

const CityDistrictSchema = new mongoose.Schema({
  name: { 
    type: String, 
    required: true, 
    unique: true // Assuming city names should be unique
  },
  districts: [{ 
    type: String 
  }]
  // We don't need to define _id, createdAt, updatedAt, or __v in the schema,
  // Mongoose handles them automatically.
  // If you had an 'order' field or similar for sorting, you would add it here.
}, {
  // Enable timestamps if you want Mongoose to automatically manage createdAt and updatedAt
  timestamps: true 
});

// When documents are converted to JSON (e.g., for API responses),
// Mongoose by default includes a virtual 'id' getter that returns _id.toString().
// This is usually what we want for frontend compatibility.

module.exports = mongoose.model('CityDistrict', CityDistrictSchema, 'citydistricts'); 
// The third argument 'citydistricts' explicitly tells Mongoose to use the
// 'citydistricts' collection name in the database.
// If omitted, Mongoose would try to pluralize 'CityDistrict' to 'citydistricts',
// which in this case matches, but being explicit is safer.