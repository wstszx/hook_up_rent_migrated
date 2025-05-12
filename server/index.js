const express = require('express');
const mongoose = require('mongoose'); // Mongoose for ObjectId
const path = require('path'); // 引入 path 模块
const app = express();
const port = 3000;
const connectDB = require('./config/db'); // 引入数据库连接函数

// 引入模型用于Seeding
const User = require('./models/User');
const Room = require('./models/Room');
const Recommendation = require('./models/Recommendation'); // 引入 Recommendation 模型
const ProfileButton = require('./models/ProfileButton'); // 引入 ProfileButton 模型
const NewsItem = require('./models/NewsItem'); // 引入 NewsItem 模型
const IndexNavigatorItem = require('./models/IndexNavigatorItem'); // 引入 IndexNavigatorItem 模型
const CityOption = require('./models/CityOption');
const RentTypeOption = require('./models/RentTypeOption');
const RoomTypeOption = require('./models/RoomTypeOption');
const OrientationOption = require('./models/OrientationOption');
const FloorOption = require('./models/FloorOption');
const PriceRangeOption = require('./models/PriceRangeOption');
// const Favorite = require('./models/Favorite'); // 可选，如果要在seed中创建收藏
// const Order = require('./models/Order');    // 可选，如果要在seed中创建订单


// 引入认证路由
const authRoutes = require('./routes/auth');
const roomRoutes = require('./routes/rooms'); // 引入房源路由
const meRoutes = require('./routes/me'); // 引入用户特定操作路由
const configurationRoutes = require('./routes/configurations'); // 引入配置路由
const recommendationRoutes = require('./routes/recommendations'); // 引入推荐路由
const newsRoutes = require('./routes/news'); // 引入资讯路由

// 中间件，用于解析 JSON 请求体
app.use(express.json());

// 配置静态文件服务，用于访问上传的图片
// process.cwd() 是项目根目录 (d:/flutterProject/hook_up_rent_migrated)
// 我们希望 uploads 目录在 server 文件夹下
app.use('/uploads', express.static(path.join(process.cwd(), 'server/uploads')));
app.use('/static', express.static(path.join(process.cwd(), 'static'))); // 新增：为根目录下的 static 文件夹提供服务


// 根路由 (可选，用于测试服务器是否在线)
app.get('/', (req, res) => {
  res.send('Hello World! Backend server is running.');
});

// 使用认证路由，所有 /api/auth 下的请求都将由 authRoutes 处理
app.use('/api/auth', authRoutes);
// 使用房源路由，所有 /api/rooms 下的请求都将由 roomRoutes 处理
app.use('/api/rooms', roomRoutes);
app.use('/api/me', meRoutes); // 使用用户特定操作路由
app.use('/api/configurations', configurationRoutes); // 使用配置路由
app.use('/api/recommendations', recommendationRoutes); // 使用推荐路由
app.use('/api/news', newsRoutes); // 使用资讯路由

const seedDatabase = async () => {
    try {
        // Check if any collection has data to prevent re-seeding everything if only some parts are missing
        const userCount = await User.countDocuments();
        const roomCount = await Room.countDocuments();
        const recommendationCount = await Recommendation.countDocuments();
        const profileButtonCount = await ProfileButton.countDocuments();
        const newsItemCount = await NewsItem.countDocuments();
        const indexNavigatorItemCount = await IndexNavigatorItem.countDocuments();
        const cityOptionCount = await CityOption.countDocuments();
        const rentTypeOptionCount = await RentTypeOption.countDocuments();
        const roomTypeOptionCount = await RoomTypeOption.countDocuments();
        const orientationOptionCount = await OrientationOption.countDocuments();
        const floorOptionCount = await FloorOption.countDocuments();
        const priceRangeOptionCount = await PriceRangeOption.countDocuments();

        if (userCount > 0 && roomCount > 0 && recommendationCount > 0 && profileButtonCount > 0 && newsItemCount > 0 && indexNavigatorItemCount > 0 &&
            cityOptionCount > 0 && rentTypeOptionCount > 0 && roomTypeOptionCount > 0 && orientationOptionCount > 0 && floorOptionCount > 0 && priceRangeOptionCount > 0) {
            console.log('Database collections (Users, Rooms, Recommendations, ProfileButtons, NewsItems, IndexNavigatorItems, FilterOptions) appear to be seeded. Skipping...');
            return;
        }
        
        console.log('Seeding database with initial data...');

        // 创建用户 (only if users are missing)
        if (userCount === 0) {
            console.log('Seeding users...');
        const user1 = await User.create({ username: 'alice', password: 'password123' });
        const user2 = await User.create({ username: 'bob', password: 'password456' });
        const user3 = await User.create({ username: 'charlie_landlord', password: 'password789' });
        }
        // Re-fetch users if they were just created or to ensure IDs are available for room publishing
        const user1 = await User.findOne({ username: 'alice' });
        // const user2 = await User.findOne({ username: 'bob' }); // Not used for rooms below, but good practice if needed
        // const user3 = await User.findOne({ username: 'charlie_landlord' }); // Not used for rooms below

        // 创建房源 (only if rooms are missing)
        if (roomCount === 0 && user1) { // Ensure user1 exists before creating rooms
            console.log('Seeding rooms...');
            await Room.create([
                { title: '市中心舒适一居室', description: '交通便利，设施齐全，拎包入住。', price: 2500, city: '长沙', district: '岳麓区', address: '岳麓大道123号', rentType: '整租', roomType: '一室一厅', floor: '8/16', orientation: '朝南', images: ['/static/images/home_index_recommend_1.png'], publisher: user1._id, tags: ['近地铁', '精装修'], location: { type: 'Point', coordinates: [112.938814, 28.228209] } },
                { title: '安静小区两室套房', description: '环境优美，适合家庭居住。', price: 3200, city: '长沙', district: '雨花区', address: '雨花路45号小区', rentType: '整租', roomType: '两室一厅', floor: '5/10', orientation: '南北通透', images: ['/static/images/home_index_recommend_2.png'], publisher: user1._id, tags: ['学区房', '有电梯'], location: { type: 'Point', coordinates: [113.024069, 28.159006] } },
                // Add other rooms as in original, ensuring publisher IDs are valid
            ]);
        }

        // 创建推荐数据 (only if recommendations are missing)
        if (recommendationCount === 0) {
            console.log('Seeding recommendations...');
            await Recommendation.create([
              // 长沙的推荐数据
              {
                title: '岳麓山下好风光',
                subTitle: '长沙宜居新选择',
                imageUrl: 'static/images/home_index_recommend_1.png',
                navigateUrl: '/search?city=长沙',
                city: '长沙'
              },
              {
                title: '橘子洲头江景房',
                subTitle: '品味星城韵味',
                imageUrl: 'static/images/home_index_recommend_2.png',
                navigateUrl: '/search?city=长沙',
                city: '长沙'
              },
              // 北京的推荐数据
              {
                title: '家住回龙观',
                subTitle: '归属的感觉',
                imageUrl: 'static/images/home_index_recommend_3.png',
                navigateUrl: '/search?city=北京',
                city: '北京'
              },
              {
                title: '宜居四五环',
                subTitle: '大都市生活',
                imageUrl: 'static/images/home_index_recommend_4.png',
                navigateUrl: '/search?city=北京',
                city: '北京'
              }
            ]);
        }

        // 创建个人资料功能按钮数据 (only if profile buttons are missing)
        if (profileButtonCount === 0) {
            console.log('Seeding profile buttons...');
            await ProfileButton.create([
              { imageUrl: 'static/images/home_profile_record.png', title: "看房记录", actionType: 'NAVIGATE', actionValue: 'test', order: 1 },
              { imageUrl: 'static/images/home_profile_order.png', title: '我的订单', actionType: 'NAVIGATE', actionValue: 'orders_page', order: 2 },
              { imageUrl: 'static/images/home_profile_favor.png', title: '我的收藏', actionType: 'NAVIGATE', actionValue: 'favorites_page', order: 3 },
              { imageUrl: 'static/images/home_profile_id.png', title: '身份认证', actionType: 'NAVIGATE', actionValue: 'auth_status_page', order: 4 },
              { imageUrl: 'static/images/home_profile_message.png', title: '联系我们', actionType: 'SHOW_CONTACT_INFO', order: 5 },
              { imageUrl: 'static/images/home_profile_contract.png', title: '电子合同', actionType: 'NAVIGATE', actionValue: 'contracts_page', order: 6 },
              { imageUrl: 'static/images/home_profile_wallet.png', title: '钱包', actionType: 'NAVIGATE', actionValue: 'wallet_page', order: 7 },
              { imageUrl: 'static/images/home_profile_house.png', title: "房屋管理", actionType: 'NAVIGATE_WITH_AUTH_CHECK', actionValue: 'room_manage', fallbackActionValue: 'login', order: 8 }
            ]);
        }

        // 创建资讯数据 (only if news items are missing)
        if (newsItemCount === 0) {
            console.log('Seeding news items...');
            await NewsItem.create([
              { title: '置业选择 | 三室一厅 河间的古雅别院', imageUrl: 'https://wx2.sinaimg.cn/mw1024/005SQLxwly1g6f89l4obbj305v04fjsw.jpg', source: "新华网", time: "两天前", navigateUrl: 'login', publishDate: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000) },
              { title: '置业佳选 | 大理王宫 苍山洱海间的古雅别院', imageUrl: 'https://wx2.sinaimg.cn/mw1024/005SQLxwly1g6f89l6hnsj305v04fab7.jpg', source: "新华网", time: "一周前", navigateUrl: 'login', publishDate: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) },
              { title: '置业选择 | 安居小屋 花园洋房 清新别野', imageUrl: 'https://wx4.sinaimg.cn/mw1024/005SQLxwly1g6f89l5jlyj305v04f75q.jpg', source: "新华网", time: "一周前", navigateUrl: 'login', publishDate: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000 - 10000) }, // Slightly different time for ordering
              { title: '置业选择 | 安居小屋 花园洋房 清新别野 山清水秀', imageUrl: 'https://wx4.sinaimg.cn/mw1024/005SQLxwly1g6f89l5jlyj305v04f75q.jpg', source: "新华网", time: "一周前", navigateUrl: 'login', publishDate: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000 - 20000) },
              { title: '置业选择 | 安居小屋 花园洋房 清新别野', imageUrl: 'https://wx4.sinaimg.cn/mw1024/005SQLxwly1g6f89l5jlyj305v04f75q.jpg', source: "新华网", time: "一周前", navigateUrl: 'login', publishDate: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000 - 30000) }
            ]);
        }

        // 创建首页导航项数据 (only if index navigator items are missing)
        if (indexNavigatorItemCount === 0) {
            console.log('Seeding index navigator items...');
            await IndexNavigatorItem.create([
              { title: '整租', imageUrl: 'static/images/home_index_navigator_total.png', actionType: 'NAVIGATE_WITH_PARAMS', actionValue: '/search', params: { 'rentType': '整租' }, order: 1 },
              { title: '合租', imageUrl: 'static/images/home_index_navigator_share.png', actionType: 'NAVIGATE_WITH_PARAMS', actionValue: '/search', params: { 'rentType': '合租' }, order: 2 },
              { title: '地图找房', imageUrl: 'static/images/home_index_navigator_map.png', actionType: 'NAVIGATE', actionValue: '/map', order: 3 },
              { title: '去出租', imageUrl: 'static/images/home_index_navigator_rent.png', actionType: 'NAVIGATE_WITH_AUTH_CHECK', actionValue: '/room-add', params: { 'fallbackActionValue': 'login' }, order: 4 }
            ]);
        }

        // 创建筛选选项数据
        if (cityOptionCount === 0) {
            console.log('Seeding city options...');
            await CityOption.create([
                { name: "长沙", districts: ["不限", "岳麓区", "开福区", "雨花区", "天心区", "芙蓉区", "望城区", "长沙县", "浏阳市", "宁乡市"], order: 1 },
                { name: "北京", districts: ["不限", "朝阳区", "海淀区", "东城区", "西城区", "丰台区", "石景山区", "门头沟区", "房山区", "通州区", "顺义区", "昌平区", "大兴区", "怀柔区", "平谷区", "密云区", "延庆区"], order: 2 }
            ]);
        }
        if (rentTypeOptionCount === 0) {
            console.log('Seeding rent type options...');
            await RentTypeOption.create([
                { name: "不限", order: 1 },
                { name: "整租", order: 2 },
                { name: "合租", order: 3 }
            ]);
        }
        if (roomTypeOptionCount === 0) {
            console.log('Seeding room type options...');
            await RoomTypeOption.create([
                { name: "不限", order: 1 },
                { name: "一室", order: 2 },
                { name: "二室", order: 3 },
                { name: "三室", order: 4 },
                { name: "四室", order: 5 },
                { name: "五室及以上", order: 6 }
            ]);
        }
        if (orientationOptionCount === 0) {
            console.log('Seeding orientation options...');
            await OrientationOption.create([
                { name: "不限", order: 1 },
                { name: "东", order: 2 },
                { name: "南", order: 3 },
                { name: "西", order: 4 },
                { name: "北", order: 5 },
                { name: "东南", order: 6 },
                { name: "东北", order: 7 },
                { name: "西南", order: 8 },
                { name: "西北", order: 9 },
                { name: "南北", order: 10 }
            ]);
        }
        if (floorOptionCount === 0) {
            console.log('Seeding floor options...');
            await FloorOption.create([
                { name: "不限", order: 1 },
                { name: "低楼层", order: 2 },
                { name: "中楼层", order: 3 },
                { name: "高楼层", order: 4 }
            ]);
        }
        if (priceRangeOptionCount === 0) {
            console.log('Seeding price range options...');
            await PriceRangeOption.create([
                { label: "不限", value: "不限", order: 1 },
                { label: "1000元以下", value: "0-1000", order: 2 },
                { label: "1000-2000元", value: "1000-2000", order: 3 },
                { label: "2000-3000元", value: "2000-3000", order: 4 },
                { label: "3000-4000元", value: "3000-4000", order: 5 },
                { label: "4000-5000元", value: "4000-5000", order: 6 },
                { label: "5000元以上", value: "5000+", order: 7 }
            ]);
        }
        
        // 可选：创建收藏和订单
        // const room1 = await Room.findOne({ title: '市中心舒适一居室' });
        // const room2 = await Room.findOne({ title: '安静小区两室套房' });
        // if (room1 && room2) {
        //    await Favorite.create({ user: user2._id, room: room1._id });
        //    await Order.create({ user: user1._id, room: room2._id, publisher: room2.publisher, appointmentTime: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000) });
        // }

        console.log('Database seeded successfully!');
    } catch (error) {
        console.error('Error seeding database:', error);
    }
};


const startServer = async () => {
    try {
        await connectDB(); // 首先连接数据库
        await seedDatabase(); // 然后尝试 seeding (如果需要)

        app.listen(port, () => {
            console.log(`Server listening at http://localhost:${port}`);
            console.log('Available routes:');
            console.log('  Auth:');
            console.log('    POST /api/auth/register');
            console.log('    POST /api/auth/login');
            console.log('    PUT  /api/auth/me (requires auth)');
            console.log('  Rooms:');
            console.log('    POST /api/rooms (requires auth)');
            console.log('    GET  /api/rooms (params: city, district, rentType, priceRange, roomType, orientation, floor, minPrice, maxPrice, limit, sortBy, sortOrder, publishedSince, tags, longitude, latitude, maxDistance)');
            console.log('    GET  /api/rooms/:id');
            console.log('    PUT  /api/rooms/:id (requires auth & ownership)');
            console.log('    DELETE /api/rooms/:id (requires auth & ownership)');
            console.log('  Me (User Specific Actions - requires auth):');
            console.log('    POST /api/me/favorites (body: { roomId })');
            console.log('    GET  /api/me/favorites');
            console.log('    DELETE /api/me/favorites/:roomId');
            console.log('    --- Orders ---');
            console.log('    POST /api/me/orders (body: { roomId, appointmentTime?, notes? })');
            console.log('    GET  /api/me/orders');
            console.log('  Configurations:');
            console.log('    GET  /api/configurations/filter-options');
            console.log('  Recommendations:');
            console.log('    GET  /api/recommendations');
            console.log('  News:');
            console.log('    GET  /api/news');
        });
    } catch (error) {
        console.error("Failed to start server:", error);
        process.exit(1);
    }
};

startServer();