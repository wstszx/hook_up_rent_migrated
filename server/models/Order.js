const mongoose = require('mongoose');

const OrderSchema = new mongoose.Schema({
    user: { // 下单用户 (租客)
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    room: { // 预约的房源
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Room',
        required: true
    },
    publisher: { // 房源发布者 (房东) - 方便房东查询自己的订单
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    status: { // 订单状态: pending (待确认), confirmed (已确认/预约成功), cancelled_by_user, cancelled_by_publisher, completed (看房完成)
        type: String,
        default: 'pending',
        enum: ['pending', 'confirmed', 'cancelled_by_user', 'cancelled_by_publisher', 'completed', 'expired']
    },
    appointmentTime: { // 预约看房时间
        type: Date,
        default: null 
    },
    notes: { // 用户备注
        type: String,
        default: ''
    },
    createdAt: {
        type: Date,
        default: Date.now
    },
    updatedAt: {
        type: Date,
        default: Date.now
    }
});

// 在每次保存前更新 updatedAt 字段
OrderSchema.pre('save', function(next) {
    this.updatedAt = Date.now();
    next();
});

// 可以考虑为 (user, room, status='pending') 创建复合索引，防止用户对同一房源重复提交待处理的预约
// OrderSchema.index({ user: 1, room: 1, status: 1 }, { unique: true, partialFilterExpression: { status: 'pending' } });


module.exports = mongoose.model('Order', OrderSchema);