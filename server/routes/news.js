const express = require('express');
const router = express.Router();
const NewsItem = require('../models/NewsItem'); // 引入 NewsItem 模型

// GET /api/news - Get all news items from database, sorted by publishDate descending
router.get('/', async (req, res) => {
  try {
    const newsItems = await NewsItem.find().sort({ publishDate: -1 });
    res.json(newsItems);
  } catch (error) {
    console.error('Error fetching news items from database:', error);
    res.status(500).json({ message: '获取资讯数据失败' });
  }
});

module.exports = router;