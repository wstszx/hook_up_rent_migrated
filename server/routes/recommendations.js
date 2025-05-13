const express = require('express');
const router = express.Router();
const Recommendation = require('../models/Recommendation'); // 引入 Recommendation 模型

// GET /api/recommendations - Get all recommendations from database
router.get('/', async (req, res) => {
  const { city } = req.query; // 获取查询参数中的 city
  console.log(`[Backend] Received request for recommendations. City parameter: ${city}`);

  try {
    let query = {}; // 默认查询条件为空，获取所有
    if (city) {
      query = { city: city }; // 如果提供了 city 参数，则按城市筛选
      console.log(`[Backend] Querying recommendations with city: ${city}`);
    } else {
      console.log('[Backend] Querying all recommendations (no city specified).');
    }

    const recommendations = await Recommendation.find(query); // 根据查询条件查找
    console.log(`[Backend] Found ${recommendations.length} recommendations for query:`, query);
    res.json(recommendations);
  } catch (error) {
    console.error(`[Backend] Error fetching recommendations from database (city: ${city || 'all'}):`, error);
    res.status(500).json({ message: '获取推荐数据失败' });
  }
});

module.exports = router;