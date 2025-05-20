const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const Room = require('../models/Room');
const mongoose = require('mongoose');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// --- Mappings from ID to Chinese Name (mirroring frontend data) ---
const roomTypeMap = {
  'room_type_any': '不限', //  '不限' should be handled by not adding the filter
  'room_type_1': '一室',
  'room_type_2': '二室',
  'room_type_3': '三室',
  'room_type_4': '四室',
  'room_type_4_plus': '四室及以上',
};

const orientationMap = {
  'orientation_any': '不限',
  'orientation_east': '东',
  'orientation_south': '南',
  'orientation_west': '西',
  'orientation_north': '北',
  'orientation_southeast': '东南',
  'orientation_southwest': '西南',
  'orientation_northeast': '东北',
  'orientation_northwest': '西北',
  'orientation_south_north': '南北',
  'orientation_east_west': '东西',
};

const floorMap = {
  'floor_any': '不限',
  'floor_1-5': '1-5层',
  'floor_6-10': '6-10层',
  'floor_11-15': '11-15层',
  'floor_15_plus': '15层以上',
};
// --- End Mappings ---

// --- Multer Configuration for Image Uploads ---
const UPLOAD_DIR_ROOMS = path.join(process.cwd(), 'server/uploads/images/rooms');

// Ensure upload directory exists
if (!fs.existsSync(UPLOAD_DIR_ROOMS)) {
    fs.mkdirSync(UPLOAD_DIR_ROOMS, { recursive: true });
    console.log(`Created directory: ${UPLOAD_DIR_ROOMS}`);
} else {
    console.log(`Upload directory already exists: ${UPLOAD_DIR_ROOMS}`);
}


const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, UPLOAD_DIR_ROOMS);
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
    }
});

const fileFilter = (req, file, cb) => {
    // Accept only image files
    if (file.mimetype.startsWith('image/')) {
        cb(null, true);
    } else {
        cb(new Error('只允许上传图片文件 (jpeg, png, gif等)!'), false);
    }
};

const upload = multer({ 
    storage: storage, 
    fileFilter: fileFilter, 
    limits: { fileSize: 1024 * 1024 * 5 } // 5MB file size limit
});
// --- End Multer Configuration ---


// POST /api/rooms - 发布新房源 (需要认证)
router.post('/', authMiddleware, (req, res, next) => {
    upload.array('roomImages', 10)(req, res, function (err) {
        if (err instanceof multer.MulterError) {
            console.error('MulterError in POST /api/rooms:', err);
            return res.status(400).json({ message: `图片上传错误: ${err.message}` });
        } else if (err) {
            console.error('FileFilter/Unknown Upload Error in POST /api/rooms:', err);
            return res.status(400).json({ message: err.message });
        }
        next();
    });
}, async (req, res) => {
    try {
        console.log('--- New Room Submission (POST /api/rooms) ---');
        console.log('req.user:', JSON.stringify(req.user, null, 2));
        console.log('req.body:', JSON.stringify(req.body, null, 2));
        console.log('req.files:', JSON.stringify(req.files, null, 2));
        
        const {
            title, description, price, city, district, address,
            rentType, roomType, floor, orientation, tags,
            longitude, latitude // 新增经纬度
        } = req.body;
        
        if (!req.user || !req.user.userId) {
            console.error('User ID not found in request after auth middleware. req.user:', req.user);
            return res.status(400).json({ message: '用户认证信息错误，无法获取用户ID' });
        }
        const publisherId = req.user.userId;

        if (!title || !price || !city || !rentType || !roomType) {
            console.error('Missing required room info. Body:', req.body);
            return res.status(400).json({ message: '缺少必要的房源信息 (标题, 价格, 城市, 租赁类型, 户型)' });
        }

        let imagePaths = [];
        if (req.files && req.files.length > 0) {
            imagePaths = req.files.map(file => `/uploads/images/rooms/${file.filename}`); // Path relative to server's public/static serving
        }
        console.log('Constructed Image Paths:', JSON.stringify(imagePaths, null, 2));

        // Convert IDs to Chinese names before saving
        const roomTypeName = roomTypeMap[roomType] || roomType; // Fallback to original if no map found
        const floorName = floorMap[floor] || floor;             // Fallback to original if no map found
        const orientationName = orientationMap[orientation] || orientation; // Fallback to original

        const newRoomData = {
            title,
            description: description || '',
            price: parseFloat(price),
            city,
            district: district || '',
            address: address || '',
            rentType, // rentType is already a Chinese string from frontend: _getRentTypeString(rentType)
            roomType: roomTypeName,
            floor: floorName || '', // Ensure floor is not undefined
            orientation: orientationName || '', // Ensure orientation is not undefined
            images: imagePaths, // Storing relative paths
            tags: tags ? (Array.isArray(tags) ? tags : (typeof tags === 'string' ? tags.split(',').map(t=>t.trim()) : [tags])) : [], // Robust tag handling
            publisher: publisherId
            // location will be added conditionally below
        };
        console.log('Initial Data for new Room() constructor (IDs converted to names, before location):', JSON.stringify(newRoomData, null, 2));

        // 处理地理位置信息
        // Add location field ONLY if valid coordinates are provided
        if (longitude !== undefined && latitude !== undefined && String(longitude).trim() !== '' && String(latitude).trim() !== '') {
            const lon = parseFloat(longitude);
            const lat = parseFloat(latitude);
            if (!isNaN(lon) && !isNaN(lat)) {
                newRoomData.location = {
                    type: 'Point',
                    coordinates: [lon, lat]
                };
                console.log('Location data added:', newRoomData.location);
            } else {
                console.warn('Received invalid longitude/latitude (parseFloat failed) for new room:', longitude, latitude);
            }
        } else {
            console.log('Longitude/Latitude not provided or empty, skipping location field.');
        }
        
        console.log('Final Data for new Room() constructor:', JSON.stringify(newRoomData, null, 2));
        const newRoom = new Room(newRoomData);
        await newRoom.save();
        console.log('Room saved successfully:', JSON.stringify(newRoom, null, 2));
        
        res.status(201).json({ message: '房源发布成功', room: newRoom });

    } catch (error) {
        console.error('Error in POST /api/rooms route handler:', error); // Log the full error
        if (error.name === 'ValidationError') {
            const messages = Object.values(error.errors).map(val => val.message);
            console.error('Mongoose ValidationError:', messages);
            return res.status(400).json({ message: messages.join(', ') });
        }
        // For other errors, send a generic 500 and include stack in dev for more details
        res.status(500).json({
            message: '服务器内部错误，发布房源失败',
            error: error.message,
            stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
        });
    }
});

// GET /api/rooms - 获取所有房源列表 (公开)
router.get('/', async (req, res) => {
    try {
        const {
            city, district, rentType, priceRange, roomType, orientation, floor,
            minPrice, maxPrice,
            limit, sortBy, sortOrder, publishedSince, tags,
            // 新增地理位置查询参数
            longitude, latitude, maxDistance, // maxDistance in meters
            q // <--- 新增 q 参数用于文本搜索
        } = req.query;
        
        console.log('[Backend /api/rooms] Received query parameters:', req.query);
        
        let queryConditions = {};

        // 文本搜索 (如果提供了 q 参数)
        if (q && q.trim() !== '') {
            // 转义正则表达式中的特殊字符，并使其不区分大小写
            const searchRegex = new RegExp(q.trim().replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');
            queryConditions.$or = [
                { title: searchRegex },
                { description: searchRegex },
                { address: searchRegex }, // 假设 address 也是一个可以搜索的文本字段
                { district: searchRegex }, // 假设 district 也是一个可以搜索的文本字段
                // 对于 tags (如果是数组), MongoDB 的 $regex 可以直接用于数组字段，它会检查数组中是否有任何元素匹配该正则
                { tags: searchRegex }
            ];
        }

        console.log('[Backend /api/rooms] Initial queryConditions after text search:', JSON.stringify(queryConditions, null, 2));

        // 地理位置查询 (如果提供了经纬度)
        if (longitude !== undefined && latitude !== undefined) {
            const lon = parseFloat(longitude);
            const lat = parseFloat(latitude);
            const dist = maxDistance ? parseFloat(maxDistance) : 2000; // 默认2公里

            if (!isNaN(lon) && !isNaN(lat)) {
                // 使用 $geoWithin 和 $centerSphere 查找指定半径内的房源
                // $centerSphere 需要半径单位为弧度，地球平均半径约为 6371 公里 或 6371000 米
                const earthRadiusInMeters = 6371000;
                const radiusInRadians = dist / earthRadiusInMeters; // 将距离（米）转换为弧度

                queryConditions.location = {
                    $geoWithin: {
                        $centerSphere: [
                            [lon, lat], // 中心点 [经度, 纬度]
                            radiusInRadians // 半径（弧度）
                        ]
                    }
                };
                console.log(`[Backend /api/rooms] Geospatial query: finding within ${dist} meters of [${lon}, ${lat}]`);
            } else {
                console.warn('[Backend /api/rooms] Received invalid longitude/latitude for geospatial query:', longitude, latitude);
            }
        } else {
             console.log('[Backend /api/rooms] No longitude/latitude provided for geospatial query.');
        }


        // 其他筛选条件
        // 如果已经进行了地理位置查询，通常不需要再按城市过滤，除非是希望在某个城市范围内进行地理位置搜索
        // 目前的逻辑是如果提供了地理位置，就优先使用地理位置过滤，否则使用城市过滤
        if (city && city.toLowerCase() !== '不限' && !queryConditions.location) {
            let cityRegex;
            // 如果城市名以“市”结尾，尝试匹配去掉“市”字后的名称
            if (city.endsWith('市') && city.length > 1) {
                const simplifiedCity = city.substring(0, city.length - 1);
                // 使用 $in 匹配原始城市名或简化城市名
                queryConditions.city = { $in: [new RegExp(`^${city}$`, 'i'), new RegExp(`^${simplifiedCity}$`, 'i')] };
            } else {
                // 否则，精确匹配城市名
                queryConditions.city = new RegExp(`^${city}$`, 'i');
            }
        }
        if (district && district.toLowerCase() !== '不限') {
            queryConditions.district = new RegExp(`^${district}$`, 'i');
        }
        if (rentType && rentType.toLowerCase() !== '不限' && ['整租', '合租'].includes(rentType)) {
            queryConditions.rentType = rentType;
        }
        
        let effectiveMinPrice = minPrice ? parseFloat(minPrice) : null;
        let effectiveMaxPrice = maxPrice ? parseFloat(maxPrice) : null;
        if (priceRange && priceRange.toLowerCase() !== '不限') {
            const parts = priceRange.split('-');
            if (parts.length === 1) { 
                if (priceRange.endsWith('+')) {
                    effectiveMinPrice = parseFloat(priceRange.slice(0, -1));
                    effectiveMaxPrice = null; 
                } else {
                    effectiveMinPrice = null; 
                    effectiveMaxPrice = parseFloat(priceRange);
                }
            } else if (parts.length === 2) { 
                effectiveMinPrice = parseFloat(parts[0]);
                effectiveMaxPrice = parseFloat(parts[1]);
            }
        }
        if (effectiveMinPrice !== null && !isNaN(effectiveMinPrice)) {
            queryConditions.price = { ...queryConditions.price, $gte: effectiveMinPrice };
        }
        if (effectiveMaxPrice !== null && !isNaN(effectiveMaxPrice)) {
            queryConditions.price = { ...queryConditions.price, $lte: effectiveMaxPrice };
        }

        if (roomType && roomType.toLowerCase() !== 'room_type_any') { // Check against 'any' ID
            const roomTypeIds = roomType.split(',').map(rt => rt.trim()).filter(rt => rt.length > 0);
            const roomTypeNames = roomTypeIds.map(id => roomTypeMap[id]).filter(name => name && name !== '不限');
            if (roomTypeNames.length > 0) {
                queryConditions.roomType = { $in: roomTypeNames };
            }
        }
        if (orientation && orientation.toLowerCase() !== 'orientation_any') { // Check against 'any' ID
            const orientationIds = orientation.split(',').map(o => o.trim()).filter(o => o.length > 0);
            const orientationNames = orientationIds.map(id => orientationMap[id]).filter(name => name && name !== '不限');
            if (orientationNames.length > 0) {
                queryConditions.orientation = { $in: orientationNames };
            }
        }
        if (floor && floor.toLowerCase() !== 'floor_any') { // Check against 'any' ID
            const floorIds = floor.split(',').map(f => f.trim()).filter(f => f.length > 0);
            const floorNames = floorIds.map(id => floorMap[id]).filter(name => name && name !== '不限');
            if (floorNames.length > 0) {
                queryConditions.floor = { $in: floorNames };
            }
        }
        if (tags) {
            const tagsArray = tags.split(',').map(tag => tag.trim()).filter(tag => tag.length > 0);
            if (tagsArray.length > 0) {
                queryConditions.tags = { $all: tagsArray };
            }
        }
        if (publishedSince) {
            const daysMatch = publishedSince.match(/^(\d+)days$/);
            if (daysMatch && daysMatch[1]) {
                const days = parseInt(daysMatch[1]);
                const sinceDate = new Date();
                sinceDate.setDate(sinceDate.getDate() - days);
                queryConditions.createdAt = { ...queryConditions.createdAt, $gte: sinceDate };
            }
        }
        
        let query = Room.find(queryConditions);

        // 排序: 如果是地理位置查询，$nearSphere 已经隐式按距离排序，其他排序可能不适用或需要调整
        if (!queryConditions.location) {
            const effectiveSortBy = sortBy || 'createdAt';
            const effectiveSortOrderVal = sortOrder === 'asc' ? 1 : -1;
            query = query.sort({ [effectiveSortBy]: effectiveSortOrderVal });
        }


        const page = req.query.page ? parseInt(req.query.page) : 1;
        const numLimit = limit ? parseInt(limit) : 0; // 默认0表示不限制
        
        if (numLimit > 0) { // 只有当 limit 大于 0 时才应用分页
            query = query.limit(numLimit);
            if (page > 0) {
                 query = query.skip((page - 1) * numLimit);
            }
        }
        // 如果 numLimit 为 0 或未提供，则不应用 .limit()，返回所有匹配的文档
        
        const resultRooms = await query.populate('publisher', 'username _id');
        const totalRooms = await Room.countDocuments(queryConditions);

        console.log(`[Backend /api/rooms] Found ${totalRooms} rooms matching criteria.`);
        // Optionally log a sample of results:
        // console.log('[Backend /api/rooms] Sample results:', JSON.stringify(resultRooms.slice(0, 5), null, 2));

        res.json({
            rooms: resultRooms,
            currentPage: page,
            totalPages: numLimit > 0 ? Math.ceil(totalRooms / numLimit) : (totalRooms > 0 ? 1 : 0), // 如果不分页，且有数据，则为1页
            totalRooms
        });

    } catch (error) {
        console.error('Error fetching rooms:', error);
        res.status(500).json({ message: '服务器内部错误，获取房源列表失败' });
    }
});

// GET /api/rooms/:id - 获取单个房源详情 (公开)
router.get('/:id', async (req, res) => {
    try {
        const roomId = req.params.id;
        if (!mongoose.Types.ObjectId.isValid(roomId)) {
            return res.status(400).json({ message: '无效的房源ID格式' });
        }
        const room = await Room.findById(roomId).populate('publisher', 'username _id'); 
        if (!room) {
            return res.status(404).json({ message: '房源未找到' });
        }
        res.json(room);
    } catch (error) {
        console.error('Error fetching room details:', error);
        res.status(500).json({ message: '服务器内部错误，获取房源详情失败' });
    }
});


// PUT /api/rooms/:id - 编辑房源 (需要认证，且房源属于该用户)
router.put('/:id', authMiddleware, (req, res, next) => {
    upload.array('roomImages', 10)(req, res, function (err) { // Max 10 new images
        if (err instanceof multer.MulterError) {
            return res.status(400).json({ message: `图片上传错误: ${err.message}` });
        } else if (err) {
            return res.status(400).json({ message: err.message });
        }
        next();
    });
}, async (req, res) => {
    try {
        const roomId = req.params.id;
        if (!mongoose.Types.ObjectId.isValid(roomId)) {
            return res.status(400).json({ message: '无效的房源ID格式' });
        }
        const currentUserId = req.user.userId;
        
        const roomToUpdate = await Room.findById(roomId);
        if (!roomToUpdate) {
            return res.status(404).json({ message: '房源未找到' });
        }
        if (roomToUpdate.publisher.toString() !== currentUserId) {
            return res.status(403).json({ message: '无权限修改此房源' });
        }

        const { 
            title, description, price, city, district, address, 
            rentType, roomType, floor, orientation, 
            imagesToKeep, // Expects a JSON string array of existing image URLs to keep. If not provided, old images might be removed if new ones are uploaded.
            tags, status,
            longitude, latitude // 新增经纬度
        } = req.body;

        // 更新文本字段
        if (title !== undefined) roomToUpdate.title = title;
        if (description !== undefined) roomToUpdate.description = description;
        if (price !== undefined) roomToUpdate.price = parseFloat(price);
        if (city !== undefined) roomToUpdate.city = city;
        if (district !== undefined) roomToUpdate.district = district;
        if (address !== undefined) roomToUpdate.address = address;
        if (rentType !== undefined) roomToUpdate.rentType = rentType;
        if (roomType !== undefined) roomToUpdate.roomType = roomType;
        if (floor !== undefined) roomToUpdate.floor = floor;
        if (orientation !== undefined) roomToUpdate.orientation = orientation;
        if (tags !== undefined) roomToUpdate.tags = Array.isArray(tags) ? tags : JSON.parse(tags); // Assuming tags might also be a JSON string array
        if (status !== undefined) roomToUpdate.status = status;

        // 处理地理位置信息
        if (longitude !== undefined && latitude !== undefined) {
            const lon = parseFloat(longitude);
            const lat = parseFloat(latitude);
            if (!isNaN(lon) && !isNaN(lat)) {
                roomToUpdate.location = {
                    type: 'Point',
                    coordinates: [lon, lat]
                };
            } else {
                console.warn('Received invalid longitude/latitude for room update:', longitude, latitude);
            }
        } else if (req.body.hasOwnProperty('longitude') && req.body.hasOwnProperty('latitude') && longitude === null && latitude === null) {
            // Explicitly clear location if longitude and latitude are provided as null
            roomToUpdate.location = undefined;
        }

        // 图片处理逻辑
        const newImagePaths = req.files && req.files.length > 0
            ? req.files.map(file => `/uploads/images/rooms/${file.filename}`)
            : [];

        let clientImagesToKeep = [];
        if (imagesToKeep) { // imagesToKeep is expected to be a JSON string array of URLs
            try {
                clientImagesToKeep = JSON.parse(imagesToKeep);
                if (!Array.isArray(clientImagesToKeep)) {
                    console.warn('imagesToKeep was not a valid JSON array, treating as empty.');
                    clientImagesToKeep = [];
                }
            } catch (e) {
                console.warn('Error parsing imagesToKeep JSON:', e);
                clientImagesToKeep = [];
            }
        }
        
        const currentDbImageUrls = roomToUpdate.images || [];
        let finalImageUrlsSet = new Set([...clientImagesToKeep, ...newImagePaths]);

        // Determine which old images to delete from the filesystem
        const imagesToDeleteFromFs = currentDbImageUrls.filter(dbUrl => !finalImageUrlsSet.has(dbUrl));

        imagesToDeleteFromFs.forEach(imageUrl => {
            const filename = path.basename(imageUrl); // Extracts filename from '/uploads/images/rooms/filename.jpg'
            const filePath = path.join(UPLOAD_DIR_ROOMS, filename);
            if (fs.existsSync(filePath)) {
                try {
                    fs.unlinkSync(filePath);
                    console.log(`Deleted image during update: ${filePath}`);
                } catch (unlinkErr) {
                    console.error(`Error deleting image ${filePath} during update:`, unlinkErr);
                }
            }
        });

        roomToUpdate.images = Array.from(finalImageUrlsSet);

        const updatedRoom = await roomToUpdate.save();
        res.json({ message: '房源更新成功', room: updatedRoom });

    } catch (error) {
        console.error('Error updating room:', error);
        if (error.name === 'ValidationError') {
            const messages = Object.values(error.errors).map(val => val.message);
            return res.status(400).json({ message: messages.join(', ') });
        }
        res.status(500).json({ message: '服务器内部错误，更新房源失败' });
    }
});

// DELETE /api/rooms/:id - 删除房源 (需要认证，且房源属于该用户)
router.delete('/:id', authMiddleware, async (req, res) => {
    try {
        const roomId = req.params.id;
        if (!mongoose.Types.ObjectId.isValid(roomId)) {
            return res.status(400).json({ message: '无效的房源ID格式' });
        }
        const currentUserId = req.user.userId;

        const roomToDelete = await Room.findById(roomId);
        if (!roomToDelete) {
            return res.status(404).json({ message: '房源未找到' });
        }
        if (roomToDelete.publisher.toString() !== currentUserId) {
            return res.status(403).json({ message: '无权限删除此房源' });
        }

        if (roomToDelete.images && roomToDelete.images.length > 0) {
            roomToDelete.images.forEach(imageUrl => {
                const filename = path.basename(imageUrl);
                const filePath = path.join(UPLOAD_DIR_ROOMS, filename);
                if (fs.existsSync(filePath)) {
                    try {
                        fs.unlinkSync(filePath);
                        console.log(`Deleted image: ${filePath}`);
                    } catch (unlinkErr) {
                        console.error(`Error deleting image ${filePath}:`, unlinkErr);
                    }
                }
            });
        }

        await Room.findByIdAndDelete(roomId);
        // TODO: Also delete associated favorites and orders
        // await Favorite.deleteMany({ room: roomId });
        // await Order.deleteMany({ room: roomId });

        res.json({ message: '房源删除成功', roomId: roomId });

    } catch (error) {
        console.error('Error deleting room:', error);
        res.status(500).json({ message: '服务器内部错误，删除房源失败' });
    }
});

module.exports = router;