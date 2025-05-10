const express = require('express');
const router = express.Router();

// 引入筛选选项模型
const CityOption = require('../models/CityOption');
const RentTypeOption = require('../models/RentTypeOption');
const RoomTypeOption = require('../models/RoomTypeOption');
const OrientationOption = require('../models/OrientationOption');
const FloorOption = require('../models/FloorOption');
const PriceRangeOption = require('../models/PriceRangeOption');
const ProfileButton = require('../models/ProfileButton'); // 引入 ProfileButton 模型
    
    // GET /api/configurations/profile-buttons - Get all profile function buttons from database
    router.get('/profile-buttons', async (req, res) => {
      try {
        const buttons = await ProfileButton.find().sort({ order: 1 }); // Fetch and sort by order
        res.json(buttons);
      } catch (error) {
        console.error('Error fetching profile function buttons from database:', error);
        res.status(500).json({ message: '获取功能按钮失败' });
      }
    });
    
    const IndexNavigatorItem = require('../models/IndexNavigatorItem'); // 引入 IndexNavigatorItem 模型
    
    // GET /api/configurations/index-navigator-items - Get all index navigator items from database
    router.get('/index-navigator-items', async (req, res) => {
      try {
        const items = await IndexNavigatorItem.find().sort({ order: 1 }); // Fetch and sort by order
        res.json(items);
      } catch (error) {
        console.error('Error fetching index navigator items from database:', error);
        res.status(500).json({ message: '获取首页导航项失败' });
      }
    });

// GET /api/configurations/filter-options - 获取所有筛选条件的选项 (从数据库读取)
router.get('/filter-options', async (req, res) => {
    try {
        const cities = await CityOption.find().sort({ order: 1 });
        const rentTypesFromDB = await RentTypeOption.find().sort({ order: 1 });
        const roomTypesFromDB = await RoomTypeOption.find().sort({ order: 1 });
        const orientationsFromDB = await OrientationOption.find().sort({ order: 1 });
        const floorsFromDB = await FloorOption.find().sort({ order: 1 });
        const priceRanges = await PriceRangeOption.find().sort({ order: 1 });

        // 将从数据库获取的数据转换为前端期望的简单数组格式 (如果适用)
        const rentTypes = rentTypesFromDB.map(item => item.name);
        const roomTypes = roomTypesFromDB.map(item => item.name);
        const orientations = orientationsFromDB.map(item => item.name);
        const floors = floorsFromDB.map(item => item.name);

        const filterOptionsData = {
            cities, // cities 已经是期望的格式 {name, districts}
            rentTypes,
            roomTypes,
            orientations,
            floors,
            priceRanges // priceRanges 已经是期望的格式 {label, value}
        };
        res.json(filterOptionsData);
    } catch (error) {
        console.error('Error fetching filter options from database:', error);
        res.status(500).json({ message: '获取筛选选项失败' });
    }
});
    
module.exports = router;