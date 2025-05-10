const mongoose = require('mongoose');

const FavoriteSchema = new mongoose.Schema({
    user: { // 收藏者
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    room: { // 被收藏的房源
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Room',
        required: true
    },
    favoritedAt: { // 收藏时间
        type: Date,
        default: Date.now
    }
});

// 防止同一用户重复收藏同一房源
FavoriteSchema.index({ user: 1, room: 1 }, { unique: true });

module.exports = mongoose.model('Favorite', FavoriteSchema);