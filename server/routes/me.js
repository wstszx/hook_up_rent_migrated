const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const mongoose = require('mongoose');
const Favorite = require('../models/Favorite');
const Order = require('../models/Order');
const Room = require('../models/Room'); // 需要Room模型来验证roomId和获取publisher

// --- 我的收藏 ---

// POST /api/me/favorites - 添加房源到收藏 (需要认证)
router.post('/favorites', authMiddleware, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { roomId } = req.body;

        if (!roomId || !mongoose.Types.ObjectId.isValid(roomId)) {
            return res.status(400).json({ message: '无效或缺少的房源ID (roomId)' });
        }

        // 检查房源是否存在
        const roomExists = await Room.findById(roomId);
        if (!roomExists) {
            return res.status(404).json({ message: '指定的房源不存在' });
        }

        // FavoriteSchema中定义了 (user, room) 的 unique 索引，Mongoose 会自动处理重复
        const newFavorite = new Favorite({
            user: userId,
            room: roomId
        });
        await newFavorite.save();
        
        // 返回时可以 populate room 信息
        const populatedFavorite = await Favorite.findById(newFavorite._id).populate('room', 'title price city images');

        res.status(201).json({ message: '房源收藏成功', favorite: populatedFavorite });

    } catch (error) {
        console.error('Error adding to favorites:', error);
        if (error.code === 11000) { // MongoDB duplicate key error
            return res.status(400).json({ message: '该房源已在您的收藏中' });
        }
        res.status(500).json({ message: '服务器内部错误，收藏失败' });
    }
});

// GET /api/me/favorites - 获取当前用户的收藏列表 (需要认证)
router.get('/favorites', authMiddleware, async (req, res) => {
    try {
        const userId = req.user.userId;
        // 填充收藏的房源信息，只选择部分关键字段
        const favorites = await Favorite.find({ user: userId })
            .populate('room', 'title price city district images rentType roomType status') 
            .sort({ favoritedAt: -1 });
        
        res.json(favorites);

    } catch (error) {
        console.error('Error fetching favorites:', error);
        res.status(500).json({ message: '服务器内部错误，获取收藏列表失败' });
    }
});

// DELETE /api/me/favorites/:roomId - 从收藏列表中移除房源 (需要认证)
router.delete('/favorites/:roomId', authMiddleware, async (req, res) => {
    try {
        const userId = req.user.userId;
        const roomIdToRemove = req.params.roomId;

        if (!roomIdToRemove || !mongoose.Types.ObjectId.isValid(roomIdToRemove)) {
            return res.status(400).json({ message: '无效的房源ID格式' });
        }

        const result = await Favorite.findOneAndDelete({ user: userId, room: roomIdToRemove });

        if (!result) {
            return res.status(404).json({ message: '未在您的收藏中找到该房源，或已被移除' });
        }
        
        res.json({ message: '房源已从收藏中移除', roomId: roomIdToRemove });

    } catch (error) {
        console.error('Error removing from favorites:', error);
        res.status(500).json({ message: '服务器内部错误，移除收藏失败' });
    }
});

// --- 我的订单 (预约看房) ---

// POST /api/me/orders - 添加房源到预约列表 (需要认证)
router.post('/orders', authMiddleware, async (req, res) => {
    try {
        const userId = req.user.userId; // 租客ID
        const { roomId, appointmentTime, notes } = req.body;

        if (!roomId || !mongoose.Types.ObjectId.isValid(roomId)) {
            return res.status(400).json({ message: '无效或缺少的房源ID (roomId)' });
        }

        // 检查房源是否存在并获取房东ID
        const room = await Room.findById(roomId);
        if (!room) {
            return res.status(404).json({ message: '指定的房源不存在' });
        }
        if (room.publisher.toString() === userId) {
            return res.status(400).json({ message: '您不能预约自己发布的房源' });
        }


        // 可选：检查用户是否对该房源已有待处理的订单
        // const existingPendingOrder = await Order.findOne({ user: userId, room: roomId, status: 'pending' });
        // if (existingPendingOrder) {
        //     return res.status(400).json({ message: '您已对该房源有待处理的预约' });
        // }

        const newOrder = new Order({
            user: userId,
            room: roomId,
            publisher: room.publisher, // 房东ID
            appointmentTime: appointmentTime ? new Date(appointmentTime) : null,
            notes: notes || ''
            // status 默认为 'pending'
        });
        await newOrder.save();
        
        const populatedOrder = await Order.findById(newOrder._id)
            .populate('room', 'title price city district address images')
            .populate('publisher', 'username');


        res.status(201).json({ message: '预约看房成功，已添加到我的订单', order: populatedOrder });

    } catch (error) {
        console.error('Error creating order:', error);
        if (error.name === 'ValidationError') {
            const messages = Object.values(error.errors).map(val => val.message);
            return res.status(400).json({ message: messages.join(', ') });
        }
        res.status(500).json({ message: '服务器内部错误，创建订单失败' });
    }
});

// GET /api/me/orders - 获取当前用户的预约列表 (需要认证)
router.get('/orders', authMiddleware, async (req, res) => {
    try {
        const userId = req.user.userId;
        // 查找用户作为租客的订单
        const orders = await Order.find({ user: userId })
            .populate('room', 'title price city district address images rentType roomType status') // 房源信息
            .populate('publisher', 'username') // 房东信息
            .sort({ createdAt: -1 }); // 按创建时间降序
        
        res.json(orders);

    } catch (error) {
        console.error('Error fetching orders:', error);
        res.status(500).json({ message: '服务器内部错误，获取订单列表失败' });
    }
});

// TODO: PUT /api/me/orders/:orderId - 更新订单状态 (例如用户取消订单)
// router.put('/orders/:orderId', authMiddleware, async (req, res) => { ... });

// 房东可能也需要查看/管理他收到的订单
// TODO: GET /api/me/received-orders (获取作为房东收到的订单)
// router.get('/received-orders', authMiddleware, async (req, res) => {
//     const publisherId = req.user.userId;
//     const receivedOrders = await Order.find({ publisher: publisherId })
//         .populate('room', 'title')
//         .populate('user', 'username') // 预约者信息
//         .sort({ createdAt: -1 });
//     res.json(receivedOrders);
// });


module.exports = router;