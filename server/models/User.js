const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const UserSchema = new mongoose.Schema({
    username: {
        type: String,
        required: [true, '用户名为必填项'],
        unique: true,
        trim: true
    },
    password: {
        type: String,
        required: [true, '密码为必填项'],
        minlength: [6, '密码长度不能少于6位']
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
    // favorites: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Room' }], // 示例：如果要在User中直接引用收藏
    // orders: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Order' }] // 示例：如果要在User中直接引用订单
});

// 在保存用户之前，如果密码被修改过，则对其进行哈希加密
UserSchema.pre('save', async function(next) {
    // 仅当密码字段被修改（或新创建）时才哈希密码
    if (!this.isModified('password')) {
        return next();
    }
    try {
        const salt = await bcrypt.genSalt(10);
        this.password = await bcrypt.hash(this.password, salt);
        next();
    } catch (err) {
        next(err);
    }
});

// 实例方法：比较输入的密码和数据库中哈希过的密码
UserSchema.methods.comparePassword = async function(candidatePassword) {
    return bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', UserSchema);