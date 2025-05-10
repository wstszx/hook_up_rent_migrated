const mongoose = require('mongoose');
const { fakerZH_CN: faker } = require('@faker-js/faker'); // 确保已安装 @faker-js/faker
const connectDB = require('./config/db');
const User = require('./models/User');
const Room = require('./models/Room');

// --- 从 rental-app/lib/generate-properties.ts 迁移的常量和函数 ---

// 房源类型 (注意：Room模型中rentType只有 '整租', '合租')
const propertyTypes = ["整租", "合租", "短租"]; // 我们会在映射时处理 "短租"

// 装修类型
const decorationTypes = ["精装修", "简装修", "豪华装修", "毛坯房", "中等装修"];

// 朝向
const orientations = ["朝南", "朝北", "朝东", "朝西", "东南", "西南", "东北", "西北", "南北通透"];

// 付款方式 (Room模型中没有此字段，如果需要可以添加)
// const paymentTypes = ["押一付一", "押一付三", "押二付三", "押一付六", "年付"];

// 标签
const tags = [
  "近地铁", "精装修", "拎包入住", "南北通透", "采光好", "近商圈", "近公园",
  "近学校", "安静", "高楼层", "电梯房", "独立卫生间", "独立阳台", "有暖气",
  "随时看房", "新上房源", "押金可分期", "有阳台", "带飘窗", "独立厨房",
  "可养宠物", "近医院", "近超市",
];

// 设施 (Room模型中没有直接的facilities字段，可以考虑将其信息合并到description或tags，或者修改模型)
// 为了简化，我们暂时不直接使用此详细列表，但可以在description中提及一些。
const facilitiesList = [
  { name: "无线网络", icon: "wifi" }, { name: "电视", icon: "tv" },
  { name: "冰箱", icon: "refrigerator" }, { name: "洗衣机", icon: "washer" },
  { name: "空调", icon: "aircon" }, { name: "热水器", icon: "waterheater" },
  { name: "床", icon: "bed" }, { name: "衣柜", icon: "wardrobe" },
  { name: "沙发", icon: "sofa" }, { name: "微波炉", icon: "microwave" },
  { name: "燃气灶", icon: "stove" }, { name: "暖气", icon: "heating" },
  { name: "宽带", icon: "broadband" }, { name: "智能门锁", icon: "smartlock" },
  { name: "电梯", icon: "elevator" }, { name: "车位", icon: "parking" },
];

// 城市和区域 (基础列表，会结合faker动态生成更多)
const baseCities = [
  { name: "北京", districts: ["朝阳区", "海淀区", "东城区", "西城区", "丰台区", "石景山区", "通州区", "昌平区"] },
  { name: "上海", districts: ["浦东新区", "徐汇区", "长宁区", "静安区", "普陀区", "虹口区", "杨浦区", "黄浦区"] },
  { name: "广州", districts: ["天河区", "越秀区", "海珠区", "荔湾区", "白云区", "黄埔区", "番禺区", "花都区"] },
  { name: "深圳", districts: ["南山区", "福田区", "罗湖区", "宝安区", "龙岗区", "盐田区", "龙华区", "坪山区"] },
  // 可以根据需要添加更多基础城市和区域
];

// 房源图片集合
const propertyImages = [
  "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
  "https://images.unsplash.com/photo-1493809842364-78817add7ffb?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
  "https://images.unsplash.com/photo-1554995207-c18c203602cb?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
  "https://images.unsplash.com/photo-1484154218962-a197022b5858?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
  "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
  // ... (可以添加更多图片URL)
  "https://images.unsplash.com/photo-1560448204-603b3fc33ddc?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
  "https://images.unsplash.com/photo-1600585152220-90363fe7e115?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
];

// 城市中心点坐标（大致位置） - 用于基础城市，faker生成的城市将使用随机坐标
const cityCenters = {
  北京: { lat: 39.9042, lng: 116.4074 },
  上海: { lat: 31.2304, lng: 121.4737 },
  广州: { lat: 23.1291, lng: 113.2644 },
  深圳: { lat: 22.5431, lng: 114.0579 },
  // 可以为更多基础城市添加中心点
};

// 生成指定城市附近的随机坐标
function generateCoordinates(cityName) {
  const center = cityCenters[cityName];
  if (center) {
    // 为基础城市生成更集中的坐标
    const lat = center.lat + (Math.random() - 0.5) * 0.15; // 调整随机范围
    const lng = center.lng + (Math.random() - 0.5) * 0.15; // 调整随机范围
    return { lat, lng };
  }
  // 对于faker生成的城市，随机生成中国范围内的坐标 (大致范围)
  // 纬度范围：中国大约在北纬18度到54度之间
  // 经度范围：中国大约在东经73度到135度之间
  const lat = faker.location.latitude({ min: 20, max: 50 }); // 调整为更合理的中国纬度范围
  const lng = faker.location.longitude({ min: 75, max: 130 }); // 调整为更合理的中国经度范围
  return { lat, lng };
}

// 生成随机房源标题
function generatePropertyTitle(rooms, district, features) {
  const roomType = rooms === 1 ? "一居室" : rooms === 2 ? "两居室" : rooms === 3 ? "三居室" : `${rooms}居室`;
  const feature = features[Math.floor(Math.random() * features.length)] || "舒适";
  const titles = [
    `${district}${roomType}，${feature}`,
    `${feature}${roomType}，${district}近地铁`,
    `精装修${roomType}，${district}${feature}`,
    `${district}高品质${roomType}，${feature}`,
    `${feature}温馨${roomType}，${district}交通便利`,
  ];
  return titles[Math.floor(Math.random() * titles.length)];
}

// 生成随机房源描述
function generatePropertyDescription(district, rooms, area, features) {
  const roomType = rooms === 1 ? "一居室" : rooms === 2 ? "两居室" : rooms === 3 ? "三居室" : `${rooms}居室`;
  const feature1 = features[0] || "环境好";
  const feature2 = features.length > 1 ? features[1] : "交通便利";

  return `这是一套位于${district}的${roomType}，总面积${area}平方米，${feature1}，${feature2}。
房屋布局合理，采光充足，通风良好。${rooms > 1 ? "主卧朝南，" : ""}客厅宽敞明亮。
小区环境优美，绿化率高。周边配套设施齐全，生活非常便利。
配备基本家具家电，拎包即可入住。欢迎随时预约看房！`;
}

// --- 核心数据生成和插入逻辑将在此处继续 ---

// --- 核心数据生成和插入逻辑 ---

// 生成随机房源并映射到Room模型
function generateRoomData(id, publisherId) {
  let selectedCityObject;
  let cityName;
  let district;

  // 调整概率，例如 60% 基础城市, 40% faker生成
  if (Math.random() < 0.6 && baseCities.length > 0) {
    selectedCityObject = baseCities[Math.floor(Math.random() * baseCities.length)];
    cityName = selectedCityObject.name;
    if (selectedCityObject.districts && selectedCityObject.districts.length > 0) {
      district = selectedCityObject.districts[Math.floor(Math.random() * selectedCityObject.districts.length)];
    } else {
      district = faker.location.county() || `${cityName}区`; // 如果基础城市没有区域，随机生成一个
    }
  } else {
    cityName = faker.location.city();
    // 为faker生成的城市随机生成一些区
    const numDistricts = Math.floor(Math.random() * 2) + 1; // 1-2个模拟区
    const districts = [];
    for (let i = 0; i < numDistricts; i++) {
        // 生成更像真实区名的名称
        districts.push(faker.location.county().replace(/市$/, '区').replace(/县$/, '区') || `${cityName}区${i+1}`);
    }
    district = districts[Math.floor(Math.random() * districts.length)];
    // selectedCityObject = { name: cityName, districts: districts }; // 用于后续, 但当前未使用
  }

  const rooms = Math.floor(Math.random() * 3) + 1; // 1到3室
  const halls = Math.floor(Math.random() * 2);   // 0到1厅
  const bathrooms = Math.floor(Math.random() * 2) + 1; // 1到2卫

  let roomTypeString = '';
  if (rooms === 1 && halls === 0 && bathrooms === 1) roomTypeString = 'Studio';
  else if (rooms > 0) {
    roomTypeString = `${rooms}室`;
    if (halls > 0) roomTypeString += `${halls}厅`;
    if (bathrooms > 0) roomTypeString += `${bathrooms}卫`;
  } else {
    roomTypeString = '未知户型';
  }


  const area = Math.floor(Math.random() * (rooms * 35 + 50)) + rooms * 20 + 30; // 面积更合理些

  const totalFloors = Math.floor(Math.random() * 28) + 3; // 3到30层
  const floorNumber = Math.floor(Math.random() * totalFloors) + 1;
  const floor = `${floorNumber}/${totalFloors}层`;

  const basePrice = 1500 + rooms * 1200 + area * 15 + (cityName === "北京" || cityName === "上海" || cityName === "深圳" || cityName === "广州" ? 1000 : 0); // 对一线城市价格做调整
  const priceVariation = basePrice * 0.25;
  const price = Math.floor(basePrice + (Math.random() * priceVariation * 2 - priceVariation));

  const tagCount = Math.floor(Math.random() * 4) + 2; // 2-5个标签
  const selectedTags = [];
  const tagsCopy = [...tags];
  for (let i = 0; i < tagCount; i++) {
    if (tagsCopy.length === 0) break;
    const index = Math.floor(Math.random() * tagsCopy.length);
    selectedTags.push(tagsCopy[index]);
    tagsCopy.splice(index, 1);
  }

  const coverImage = propertyImages[Math.floor(Math.random() * propertyImages.length)];
  const imageCount = Math.floor(Math.random() * 3) + 2; // 2-4张额外图片
  const images = [coverImage];
  for (let i = 0; i < imageCount; i++) {
    images.push(propertyImages[Math.floor(Math.random() * propertyImages.length)]);
  }
   // 确保图片不重复
  const uniqueImages = [...new Set(images)];


  const title = generatePropertyTitle(rooms, district, selectedTags);
  const community = faker.location.street() + (Math.random() > 0.5 ? "小区" : "公寓"); // 使用 faker.location.street()
  const buildingNo = Math.floor(Math.random() * 30) + 1;
  const roomNo = `${floorNumber}0${Math.floor(Math.random() * 5) + 1}`;
  const address = `${cityName}${district ? district : ''}${faker.location.streetAddress(false)}${community}${buildingNo}栋${roomNo}室`; // 修正地址格式
  const description = generatePropertyDescription(district || cityName, rooms, area, selectedTags);
  const coordinates = generateCoordinates(cityName);

  let rentType = propertyTypes[Math.floor(Math.random() * propertyTypes.length)];
  if (rentType === "短租") { // Room模型不支持短租，映射为合租或整租
    rentType = Math.random() > 0.5 ? "整租" : "合租";
  }


  return {
    // id, // Mongoose 会自动生成 _id
    title,
    description,
    price,
    city: cityName,
    district: district || cityName, // 如果没有区，则使用城市名
    address,
    rentType,
    roomType: roomTypeString,
    floor,
    orientation: orientations[Math.floor(Math.random() * orientations.length)],
    images: uniqueImages,
    publisher: publisherId,
    location: {
      type: 'Point',
      coordinates: [coordinates.lng, coordinates.lat], // 注意顺序：longitude, latitude
    },
    status: 'available', // 默认状态
    tags: selectedTags,
    // createdAt, updatedAt 会自动生成
  };
}

const seedDatabase = async () => {
  try {
    await connectDB();
    console.log('MongoDB 已连接');

    // 清理旧数据 (可选，但推荐在开发时使用)
    await Room.deleteMany({});
    // await User.deleteMany({}); // 如果需要清理用户

    // 检查或创建默认发布者用户
    let publisher = await User.findOne({ username: 'default_publisher' });
    if (!publisher) {
      console.log('创建默认发布者用户...');
      publisher = new User({
        username: 'default_publisher',
        password: 'password123', // 密码会被 UserSchema pre-save 钩子哈希
      });
      await publisher.save();
      console.log('默认发布者用户已创建:', publisher.username);
    } else {
      console.log('默认发布者用户已存在:', publisher.username);
    }

    const numberOfRooms = 1000; // 生成1000条房源数据
    const roomsToCreate = [];

    console.log(`准备生成 ${numberOfRooms} 条房源数据...`);
    for (let i = 0; i < numberOfRooms; i++) {
      roomsToCreate.push(generateRoomData(i.toString(), publisher._id));
    }

    console.log('开始插入房源数据...');
    await Room.insertMany(roomsToCreate);
    console.log(`${numberOfRooms} 条房源数据已成功插入数据库！`);

  } catch (error) {
    console.error('数据填充过程中发生错误:', error);
  } finally {
    mongoose.disconnect();
    console.log('MongoDB 连接已断开');
  }
};

seedDatabase();