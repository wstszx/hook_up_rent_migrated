const mongoose = require('mongoose');

const RoomSchema = new mongoose.Schema({
    title: {
        type: String,
        required: [true, '房源标题为必填项'],
        trim: true
    },
    description: {
        type: String,
        default: ''
    },
    price: {
        type: Number,
        required: [true, '价格为必填项']
    },
    city: {
        type: String,
        required: [true, '城市为必填项'],
        trim: true
    },
    district: { // 行政区
        type: String,
        trim: true,
        default: ''
    },
    address: {
        type: String,
        trim: true,
        default: ''
    },
    rentType: { // 整租, 合租
        type: String,
        required: [true, '租赁类型为必填项'],
        enum: ['整租', '合租'] 
    },
    roomType: { // 例如: 三室一厅, 两室, Studio
        type: String,
        required: [true, '户型为必填项']
    },
    floor: { // 例如: 5/10, 低楼层, 高楼层
        type: String,
        default: ''
    },
    orientation: { // 朝向
        type: String,
        default: ''
    },
    images: { // 图片URL列表
        type: [String],
        default: []
    },
    // 配套设施，可以是一个字符串数组或更复杂的对象数组
    // amenities: [{ type: String }], 
    publisher: { // 发布者
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User', // 关联到 User 模型
        required: true
    },
    location: { // 地理位置信息 (用于地图找房)
        type: {
            type: String,
            enum: ['Point'], // GeoJSON type
            default: 'Point'
        },
        coordinates: { // [longitude, latitude] 顺序很重要！
            type: [Number], // Array of numbers for longitude and latitude
            default: undefined // 允许房源在创建时没有位置信息
        }
    },
    status: { // 房源状态，例如: 'available', 'rented', 'pending'
        type: String,
        default: 'available',
        enum: ['available', 'rented', 'pending', 'unavailable']
    },
    tags: [{ type: String }], // 例如: '近地铁', '精装修', '拎包入住'
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
RoomSchema.pre('save', function(next) {
    this.updatedAt = Date.now();
    next();
});

// 如果需要全文搜索，可以考虑添加文本索引
// RoomSchema.index({ title: 'text', description: 'text', address: 'text', city: 'text', district: 'text' });

// 为地理位置信息创建 2dsphere 索引
// Mongoose 会在应用启动时（模型初始化时）确保索引存在于MongoDB中
// 只有当 coordinates 字段存在且有效时，该索引才会应用于文档
RoomSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('Room', RoomSchema);