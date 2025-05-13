const express = require('express');
const router = express.Router();

// 引入筛选选项模型
// const CityOption = require('../models/CityOption'); // Replaced with CityDistrict
const CityDistrict = require('../models/CityDistrict'); // Added CityDistrict model
const RentTypeOption = require('../models/RentTypeOption');
// const RoomTypeOption = require('../models/RoomTypeOption'); // 不再需要
// const OrientationOption = require('../models/OrientationOption'); // 不再需要
// const FloorOption = require('../models/FloorOption'); // 不再需要
const PriceRangeOption = require('../models/PriceRangeOption');
const ProfileButton = require('../models/ProfileButton'); // 引入 ProfileButton 模型
const Room = require('../models/Room'); // <--- 引入 Room 模型
    
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

// GET /api/configurations/filter-options - 获取所有筛选条件的选项
router.get('/filter-options', async (req, res) => {
    try {
        // Fetch cities from the CityDistrict collection
        // Assuming no specific order field in CityDistrict, remove .sort({ order: 1 })
        // If sorting is needed (e.g., by name), add .sort({ name: 1 }) or similar.
        const cities = await CityDistrict.find();
        const rentTypesFromDB = await RentTypeOption.find().sort({ order: 1 });
        const priceRanges = await PriceRangeOption.find().sort({ order: 1 });

        // 从 Room 集合动态获取户型、朝向、楼层
        const roomTypes = await Room.distinct('roomType').exec();
        const orientations = await Room.distinct('orientation').exec();
        const floors = await Room.distinct('floor').exec();

        // 对楼层进行排序，尝试按数字大小（如果可能）
        // 示例排序：["低楼层", "中楼层", "高楼层"] 或 ["1/10层", "2/10层", ...]
        // 这是一个简化的排序，可能需要根据实际 floor 值的格式进行调整
        const sortFloors = (floorArray) => {
            return floorArray.sort((a, b) => {
                const floorRegex = /(\d+)\/(\d+)层/; // 匹配 "数字/数字层"
                const aMatch = a.match(floorRegex);
                const bMatch = b.match(floorRegex);

                if (aMatch && bMatch) {
                    const aCurrent = parseInt(aMatch[1]);
                    const bCurrent = parseInt(bMatch[1]);
                    if (aCurrent !== bCurrent) {
                        return aCurrent - bCurrent;
                    }
                    const aTotal = parseInt(aMatch[2]);
                    const bTotal = parseInt(bMatch[2]);
                    return aTotal - bTotal;
                }
                // 对于 "低楼层", "中楼层", "高楼层" 等非数字格式，保持原顺序或自定义排序逻辑
                if (a === "低楼层") return -1;
                if (b === "低楼层") return 1;
                if (a === "中楼层" && b === "高楼层") return -1;
                if (a === "高楼层" && b === "中楼层") return 1;
                return a.localeCompare(b); // 默认字符串排序
            });
        };
        
        const sortedFloors = sortFloors(floors.filter(f => f)); // 过滤掉 null 或 undefined 的值

        const rentTypes = rentTypesFromDB.map(item => item.name);

        const filterOptionsData = {
            cities,
            rentTypes,
            roomTypes: roomTypes.filter(rt => rt), // 过滤掉 null 或 undefined
            orientations: orientations.filter(o => o), // 过滤掉 null 或 undefined
            floors: sortedFloors,
            priceRanges
        };
        res.json(filterOptionsData);
    } catch (error) {
        console.error('Error fetching filter options from database:', error);
        res.status(500).json({ message: '获取筛选选项失败' });
    }
});
    
module.exports = router;