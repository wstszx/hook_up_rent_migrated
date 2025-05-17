import 'dart:convert';
import '../config.dart';
import '../models/room.dart';
import '../utils/dio_http.dart';
import '../utils/store.dart';

class RoomService {
  // 获取用户发布的房源列表
  static Future<List<Room>> getUserRooms({String? status}) async {
    // 暂时硬编码 token 用于测试
    final token = 'test_token';
    // 实际项目中应该使用下面的代码获取 token
    // final token = await Store.getString(StoreKeys.token);
    if (token == null) {
      throw Exception('用户未登录');
    }

    final url = '/api/me/rooms';
    final params = status != null ? {'status': status} : null;
    
    // 模拟数据响应，实际项目中应该使用 DioHttp 进行网络请求
    // final response = await DioHttp.of().get(
    //   url,
    //   queryParameters: params,
    //   options: {'token': token},
    // );
    
    // 模拟数据
    await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络延迟
    
    // 模拟空置房源数据
    final availableRooms = [
      {
        '_id': '1',
        'title': '豪华两居室，近地铁站',
        'description': '精装修公寓，拥有现代化设施和舒适的生活环境',
        'price': 3500,
        'city': '北京市',
        'district': '海淀区',
        'address': '海淀区知春路附近',
        'rentType': '整租',
        'roomType': '两居室',
        'floor': '3/18层',
        'orientation': '南北',
        'images': ['/static/images/home_index_recommend_1.png'],
        'publisher': 'user123',
        'status': 'available',
        'tags': ['近地铁', '精装修', '拥有家电'],
        'createdAt': '2025-05-01T08:00:00.000Z',
        'updatedAt': '2025-05-01T08:00:00.000Z'
      },
      {
        '_id': '2',
        'title': '带阳台的三居室大户型',
        'description': '宜家宜居，安静舒适，适合家庭居住',
        'price': 4800,
        'city': '北京市',
        'district': '朝阳区',
        'address': '朝阳区建国路附近',
        'rentType': '整租',
        'roomType': '三居室',
        'floor': '6/20层',
        'orientation': '东南',
        'images': ['/static/images/home_index_recommend_2.png'],
        'publisher': 'user123',
        'status': 'available',
        'tags': ['带阳台', '安静社区', '近学校'],
        'createdAt': '2025-05-02T10:30:00.000Z',
        'updatedAt': '2025-05-02T10:30:00.000Z'
      },
    ];
    
    // 模拟已租房源数据
    final rentedRooms = [
      {
        '_id': '3',
        'title': '精致单居室，交通便利',
        'description': '带独立卫生间，设施齐全，交通便利',
        'price': 2200,
        'city': '北京市',
        'district': '西城区',
        'address': '西城区德胜门附近',
        'rentType': '合租',
        'roomType': '单间',
        'floor': '2/6层',
        'orientation': '南',
        'images': ['/static/images/home_index_recommend_3.png'],
        'publisher': 'user123',
        'status': 'rented',
        'tags': ['交通便利', '独立卫生间', '家电齐全'],
        'createdAt': '2025-04-28T14:20:00.000Z',
        'updatedAt': '2025-05-05T09:15:00.000Z'
      },
      {
        '_id': '4',
        'title': '现代风格两居室，近商场',
        'description': '装修风格现代，家具家电齐全，适合小家庭',
        'price': 3800,
        'city': '北京市',
        'district': '东城区',
        'address': '东城区朝阳门附近',
        'rentType': '整租',
        'roomType': '两居室',
        'floor': '8/15层',
        'orientation': '东',
        'images': ['/static/images/home_index_recommend_4.png'],
        'publisher': 'user123',
        'status': 'rented',
        'tags': ['近商场', '现代风格', '家电齐全'],
        'createdAt': '2025-04-20T11:40:00.000Z',
        'updatedAt': '2025-05-03T16:50:00.000Z'
      },
    ];
    
    // 根据状态参数返回相应的房源数据
    if (status == 'rented') {
      return rentedRooms.map((item) => Room.fromJson(item)).toList();
    } else if (status == 'available') {
      return availableRooms.map((item) => Room.fromJson(item)).toList();
    } else {
      // 返回所有房源
      return [...availableRooms, ...rentedRooms].map((item) => Room.fromJson(item)).toList();
    }
    
    return [];
  }

  // 更新房源状态
  static Future<bool> updateRoomStatus(String roomId, String status) async {
    // 暂时硬编码 token 用于测试
    final token = 'test_token';
    // 实际项目中应该使用下面的代码获取 token
    // final token = await Store.getString(StoreKeys.token);
    if (token == null) {
      throw Exception('用户未登录');
    }

    final url = '/api/rooms/$roomId';
    
    // 模拟数据响应，实际项目中应该使用 DioHttp 进行网络请求
    // final response = await DioHttp.of().put(
    //   url,
    //   data: jsonEncode({'status': status}),
    //   options: {'token': token},
    // );
    
    // 模拟网络延迟和成功响应
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 模拟成功响应
    return true;
  }

  // 删除房源
  static Future<bool> deleteRoom(String roomId) async {
    // 暂时硬编码 token 用于测试
    final token = 'test_token';
    // 实际项目中应该使用下面的代码获取 token
    // final token = await Store.getString(StoreKeys.token);
    if (token == null) {
      throw Exception('用户未登录');
    }

    final url = '/api/rooms/$roomId';
    
    // 模拟数据响应，实际项目中应该使用 DioHttp 进行网络请求
    // final response = await DioHttp.of().delete(
    //   url,
    //   options: {'token': token},
    // );
    
    // 模拟网络延迟和成功响应
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 模拟成功响应
    return true;
  }
}
