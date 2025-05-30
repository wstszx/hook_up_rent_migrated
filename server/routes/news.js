const express = require('express');
const router = express.Router();
const NewsItem = require('../models/NewsItem'); // 引入 NewsItem 模型

// GET /api/news - Get news items from database, with optional search and sorting
router.get('/', async (req, res) => {
  try {
    const { q, limit } = req.query; // 获取搜索参数 q 和 limit
    console.log('[Backend /api/news] Received search query "q":', q); // 添加日志

    let queryConditions = {};

    // 如果提供了搜索参数 q，则进行模糊搜索
    if (q && q.trim() !== '') {
      const searchRegex = new RegExp(q.trim().replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');
      queryConditions.title = searchRegex; // 只搜索标题字段
    }
    
    console.log('[Backend /api/news] Constructed query conditions:', JSON.stringify(queryConditions)); // 添加日志

    // 查找匹配条件的资讯，并按发布日期降序排序，如果提供了 limit 参数，则限制返回数量
    let query = NewsItem.find(queryConditions).sort({ publishDate: -1 });
    if (limit) {
      const parsedLimit = parseInt(limit, 10);
      if (!isNaN(parsedLimit) && parsedLimit > 0) {
        query = query.limit(parsedLimit);
        console.log(`[Backend /api/news] Limiting results to ${parsedLimit} items.`);
      }
    }
    const newsItems = await query.exec();
    
    console.log(`[Backend /api/news] Found ${newsItems.length} matching news items.`); // 添加日志
    // console.log('[Backend /api/news] Sample results:', JSON.stringify(newsItems.slice(0, 5))); // 可选：打印部分结果

    res.json(newsItems);
  } catch (error) {
    console.error('Error fetching news items from database:', error);
    res.status(500).json({ message: '获取资讯数据失败' });
  }
});

module.exports = router;