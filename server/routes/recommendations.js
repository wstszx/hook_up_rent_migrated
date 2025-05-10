const express = require('express');
const router = express.Router();
const Recommendation = require('../models/Recommendation'); // 引入 Recommendation 模型

// GET /api/recommendations - Get all recommendations from database
router.get('/', async (req, res) => {
  try {
    const recommendations = await Recommendation.find();
    res.json(recommendations);
  } catch (error) {
    console.error('Error fetching recommendations from database:', error);
    res.status(500).json({ message: '获取推荐数据失败' });
  }
});

module.exports = router;