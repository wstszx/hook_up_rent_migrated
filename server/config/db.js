const mongoose = require('mongoose');

// 默认连接到本地 MongoDB 的 'rentAppDB' 数据库
// 如果 'rentAppDB' 不存在，MongoDB 会在第一次写入数据时自动创建它
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/rentAppDB';

const connectDB = async () => {
    try {
        await mongoose.connect(MONGO_URI, {
            // useNewUrlParser 和 useUnifiedTopology 在新版 Mongoose 中已是默认行为且不再需要
            // useCreateIndex 和 useFindAndModify 也是如此，已被废弃
            // 只需确保您的 Mongoose 版本较新 (例如 v6+ )
        });
        console.log('MongoDB Connected Successfully...');
    } catch (err) {
        console.error('MongoDB Connection Error:', err.message);
        // 退出进程，如果数据库连接失败
        process.exit(1);
    }
};

module.exports = connectDB;