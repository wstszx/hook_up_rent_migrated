const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const Room = require('../models/Room');
const mongoose = require('mongoose');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

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
            return res.status(400).json({ message: `图片上传错误: ${err.message}` });
        } else if (err) {
            return res.status(400).json({ message: err.message });
        }
        next();
    });
}, async (req, res) => {
    try {
        const { 
            title, description, price, city, district, address, 
            rentType, roomType, floor, orientation, tags,
            longitude, latitude // 新增经纬度
        } = req.body;
        
        const publisherId = req.user.userId;

        if (!title || !price || !city || !rentType || !roomType) {
            return res.status(400).json({ message: '缺少必要的房源信息 (标题, 价格, 城市, 租赁类型, 户型)' });
        }

        let imagePaths = [];
        if (req.files && req.files.length > 0) {
            imagePaths = req.files.map(file => `/uploads/images/rooms/${file.filename}`);
        }

        const newRoomData = {
            title,
            description: description || '',
            price: parseFloat(price),
            city,
            district: district || '',
            address: address || '',
            rentType,
            roomType,
            floor: floor || '',
            orientation: orientation || '',
            images: imagePaths,
            tags: tags ? (Array.isArray(tags) ? tags : tags.split(',').map(t=>t.trim())) : [],
            publisher: publisherId 
        };

        // 处理地理位置信息
        if (longitude !== undefined && latitude !== undefined) {
            const lon = parseFloat(longitude);
            const lat = parseFloat(latitude);
            if (!isNaN(lon) && !isNaN(lat)) {
                newRoomData.location = {
                    type: 'Point',
                    coordinates: [lon, lat]
                };
            } else {
                console.warn('Received invalid longitude/latitude for new room:', longitude, latitude);
            }
        }


        const newRoom = new Room(newRoomData);
        await newRoom.save();
        
        res.status(201).json({ message: '房源发布成功', room: newRoom });

    } catch (error) {
        console.error('Error publishing room:', error);
        if (error.name === 'ValidationError') {
            const messages = Object.values(error.errors).map(val => val.message);
            return res.status(400).json({ message: messages.join(', ') });
        }
        res.status(500).json({ message: '服务器内部错误，发布房源失败' });
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

        // 地理位置查询 (如果提供了经纬度)
        if (longitude !== undefined && latitude !== undefined) {
            const lon = parseFloat(longitude);
            const lat = parseFloat(latitude);
            const dist = maxDistance ? parseFloat(maxDistance) : 2000; // 默认2公里

            if (!isNaN(lon) && !isNaN(lat)) {
                queryConditions.location = {
                    $nearSphere: {
                        $geometry: {
                            type: "Point",
                            coordinates: [lon, lat]
                        },
                        $maxDistance: dist // 单位：米
                    }
                };
            }
        }


        // 其他筛选条件
        if (city && city.toLowerCase() !== '不限' && !queryConditions.location) { // 如果有地理位置查询，城市可能不是主要筛选条件
            queryConditions.city = new RegExp(`^${city}$`, 'i');
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

        if (roomType && roomType.toLowerCase() !== '不限') {
            queryConditions.roomType = { $regex: roomType, $options: 'i' };
        }
        if (orientation && orientation.toLowerCase() !== '不限') {
            queryConditions.orientation = new RegExp(`^${orientation}$`, 'i');
        }
        if (floor && floor.toLowerCase() !== '不限') {
            queryConditions.floor = { $regex: floor, $options: 'i' };
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