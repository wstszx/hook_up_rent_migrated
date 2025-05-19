import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../config.dart';
import '../models/room.dart';
import '../utils/dio_http.dart';
import '../utils/store.dart';
import '../scoped_model/auth.dart';
import '../pages/utils/scoped_model_helper.dart';

class RoomService {
  // 获取用户发布的房源列表
  static Future<List<Room>> getUserRooms({String? status, BuildContext? context}) async {
    try {
      String? token;
      
      // 从 AuthModel 获取令牌
      if (context != null) {
        final authModel = ScopedModelHelper.getModel<AuthModel>(context);
        if (authModel.isLogin) {
          token = authModel.token;
        }
      }
      
      // 如果没有有效的令牌，提前返回空列表
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          print('获取房源数据失败: 用户未登录或令牌无效');
        }
        return [];
      }
      
      if (kDebugMode) {
        print('使用令牌获取房源数据: $token');
      }

      final url = '/api/me/rooms';
      final Map<String, dynamic>? params = status != null ? {'status': status} : null;
      
      // 发送网络请求获取用户发布的房源数据，使用正确的参数格式
      final response = await DioHttp.of().get(
        url,
        queryParameters: params,
        options: {'token': token},
      );
      
      if (response.statusCode == 200 && response.data != null) {
        if (kDebugMode) {
          print('获取房源数据成功: ${response.data}');
        }
        
        // 解析返回的数据
        if (response.data is List) {
          // 如果直接返回了房源列表
          return (response.data as List)
              .map((item) => Room.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (response.data is Map && response.data['rooms'] is List) {
          // 如果返回了包含房源列表的对象
          return (response.data['rooms'] as List)
              .map((item) => Room.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      
      // 如果没有数据或格式不正确，返回空列表
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('获取房源数据失败: $e');
      }
      // 出错时返回空列表
      return [];
    }
  }

  // 更新房源状态
  static Future<bool> updateRoomStatus(String roomId, String status, {BuildContext? context}) async {
    try {
      String? token;
      
      // 从 AuthModel 获取令牌
      if (context != null) {
        final authModel = ScopedModelHelper.getModel<AuthModel>(context);
        if (authModel.isLogin) {
          token = authModel.token;
        }
      }
      
      // 如果没有有效的令牌，提前返回失败
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          print('更新房源状态失败: 用户未登录或令牌无效');
        }
        return false;
      }
      
      if (kDebugMode) {
        print('使用令牌更新房源状态: $token');
      }

      final url = '/api/rooms/$roomId';
      
      // 发送网络请求更新房源状态，使用正确的参数格式
      final response = await DioHttp.of().put(
        url,
        data: jsonEncode({'status': status}),
        options: {'token': token},
      );
      
      // 检查响应状态
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (kDebugMode) {
          print('更新房源状态成功: $roomId -> $status');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('更新房源状态失败: ${response.statusCode}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('更新房源状态出错: $e');
      }
      return false;
    }
  }

  // 删除房源
  static Future<bool> deleteRoom(String roomId, {BuildContext? context}) async {
    try {
      String? token;
      
      // 从 AuthModel 获取令牌
      if (context != null) {
        final authModel = ScopedModelHelper.getModel<AuthModel>(context);
        if (authModel.isLogin) {
          token = authModel.token;
        }
      }
      
      // 如果没有有效的令牌，提前返回失败
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          print('删除房源失败: 用户未登录或令牌无效');
        }
        return false;
      }
      
      if (kDebugMode) {
        print('使用令牌删除房源: $token');
      }

      final url = '/api/rooms/$roomId';
      
      // 发送网络请求删除房源，使用正确的参数格式
      final response = await DioHttp.of().delete(
        url,
        options: {'token': token},
      );
      
      // 检查响应状态
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (kDebugMode) {
          print('删除房源成功: $roomId');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('删除房源失败: ${response.statusCode}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('删除房源出错: $e');
      }
      return false;
    }
  }
}
