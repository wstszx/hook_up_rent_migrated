import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Add this line
import 'package:hook_up_rent/pages/utils/dio_http.dart';
import 'package:hook_up_rent/pages/utils/common_toast.dart';
import 'package:hook_up_rent/widgets/root_list_item_widget.dart'; // Corrected path
import 'package:hook_up_rent/pages/home/tab_search/data_list.dart'; // Corrected path
import 'package:hook_up_rent/config.dart'; // 需要Config来获取API Host
import 'package:hook_up_rent/pages/utils/store.dart'; // 用于获取用户token
import 'package:hook_up_rent/scoped_model/auth.dart'; // 用于获取用户信息
import 'package:scoped_model/scoped_model.dart';

// 订单数据模型 (根据后端API调整)
class OrderItemData {
  final String id;
  final RoomListItemData room; // 直接复用房源列表项数据模型
  final String status;
  final DateTime? appointmentTime;
  final String publisherUsername;
  final DateTime createdAt;

  OrderItemData({
    required this.id,
    required this.room,
    required this.status,
    this.appointmentTime,
    required this.publisherUsername,
    required this.createdAt,
  });

  factory OrderItemData.fromJson(Map<String, dynamic> json) {
    // 检查 'room' 字段是否存在且不为 null
    if (json['room'] == null) {
      // 如果 room 为 null，创建一个默认的房源数据
      print('[OrderItemData] Warning: room data is null in order ${json['_id'] ?? 'unknown'}');
      return OrderItemData(
        id: json['_id'] ?? '',
        room: RoomListItemData(
          id: '',
          title: '数据不可用',
          subTitle: '房源信息缺失',
          imageUrl: Config.DefaultImage,
          price: 0,
          tags: [],
        ),
        status: json['status'] ?? 'unknown',
        appointmentTime: json['appointmentTime'] != null ? DateTime.parse(json['appointmentTime']) : null,
        publisherUsername: json['publisher'] != null ? (json['publisher']['username'] ?? '未知房东') : '未知房东',
        createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      );
    }
    
    // 确保 room 是 Map<String, dynamic> 类型
    var roomDataJson = json['room'] as Map<String, dynamic>;
    
    // 确保 images 字段是 List<String>
    List<String> images = [];
    if (roomDataJson['images'] != null && roomDataJson['images'] is List) {
      images = List<String>.from(roomDataJson['images'].map((item) => item.toString()));
    } else if (roomDataJson['imageUrl'] != null) { // 兼容单个 imageUrl 的情况
      images = [roomDataJson['imageUrl']];
    }
    
    // 确保 tags 字段是 List<String>
    List<String> tags = [];
    if (roomDataJson['tags'] != null && roomDataJson['tags'] is List) {
      tags = List<String>.from(roomDataJson['tags'].map((item) => item.toString()));
    }


    return OrderItemData(
      id: json['_id'] ?? '',
      room: RoomListItemData(
        id: roomDataJson['_id'] ?? '',
        title: roomDataJson['title'] ?? '未知标题',
        subTitle: roomDataJson['address'] ?? roomDataJson['district'] ?? '未知位置', // 尝试使用 address 或 district
        imageUrl: images.isNotEmpty ? images[0] : Config.DefaultImage, // Use Config.DefaultImage
        price: roomDataJson['price'] ?? 0,
        tags: tags, // 确保 tags 是 List<String>
        // imageUrls: images, // RoomListItemData does not have imageUrls, only imageUrl
      ),
      status: json['status'] ?? 'unknown',
      appointmentTime: json['appointmentTime'] != null ? DateTime.parse(json['appointmentTime']) : null,
      publisherUsername: json['publisher'] != null ? (json['publisher']['username'] ?? '未知房东') : '未知房东',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({Key? key}) : super(key: key);

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<OrderItemData> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Ensure the state is still mounted
        _fetchOrders();
      }
    });
  }
 
  Future<void> _fetchOrders() async {
    print('[MyOrdersPage] _fetchOrders called');
    // It's generally safer to get the model here, or pass it if already obtained in didChangeDependencies
    var auth = ScopedModel.of<AuthModel>(context, rebuildOnChange: false); // rebuildOnChange can be false if only read once
    
    print('[MyOrdersPage] AuthModel: isLogin=${auth.isLogin}, token=${auth.token != null ? " vorhanden" : "nicht vorhanden"}');

    if (auth.isLogin && auth.token != null) {
      setState(() { // Ensure loading indicator is shown while fetching
        _isLoading = true;
      });
      try {
        print('[MyOrdersPage] Attempting to fetch orders from /me/orders');
        // Use DioHttp.of(context) instead of DioHttp.instance
        final response = await DioHttp.of(context).get(
          '/api/me/orders', // API路径需要包含 /api 前缀
          null, // params for get request
          auth.token, // token
        );
        print('[MyOrdersPage] Orders API response status: ${response.statusCode}');
        // Note: The original getRequest in my_orders was trying to use 'options' directly,
        // but the DioHttp.get method takes params and token separately.
        // If specific options (like headers) are needed beyond what DioHttp.get provides by default for token,
        // DioHttp class might need adjustment or use the post method if more complex options are a must.
        // For now, assuming the token is the main header to be set, which DioHttp.get handles.
 
        if (response.data != null && response.data is List) { // Removed null check for response itself as Dio throws on error
          List<dynamic> dataList = response.data;
          print('[MyOrdersPage] Orders data received: ${dataList.length} items');
          if (dataList.isEmpty) {
            print('[MyOrdersPage] Orders data is empty list.');
          }
          setState(() {
            _orders = dataList
                .where((item) => item != null) // Filter out null items
                .map((item) => OrderItemData.fromJson(item as Map<String, dynamic>))
                .toList();
            _isLoading = false;
            print('[MyOrdersPage] Orders loaded and UI updated. isLoading: $_isLoading');
          });
        } else {
          print('[MyOrdersPage] Failed to get orders or data format is incorrect. Response data: ${response.data}');
          CommonToast.showToast('获取订单失败或数据格式不正确');
          setState(() {
            _isLoading = false;
            print('[MyOrdersPage] isLoading set to false due to incorrect data format.');
          });
        }
      } catch (e) {
        print('[MyOrdersPage] Error fetching orders: $e');
        CommonToast.showToast('获取订单列表失败: $e');
        setState(() {
          _isLoading = false;
          print('[MyOrdersPage] isLoading set to false due to an error.');
        });
      }
    } else {
      print('[MyOrdersPage] User not logged in or token is null.');
      CommonToast.showToast('请先登录');
      setState(() {
        _isLoading = false;
        print('[MyOrdersPage] isLoading set to false because user is not logged in.');
      });
      // 可以考虑跳转到登录页
      // Navigator.of(context).pushNamed('login');
    }
  }
 
  Widget _buildOrderStatus(String status) {
    Color statusColor;
    String statusText;
    switch (status) {
      case 'pending':
        statusText = '待确认';
        statusColor = Colors.orange;
        break;
      case 'confirmed':
        statusText = '已确认';
        statusColor = Colors.green;
        break;
      case 'cancelled_by_user':
        statusText = '已取消(用户)';
        statusColor = Colors.grey;
        break;
      case 'cancelled_by_publisher':
        statusText = '已取消(房东)';
        statusColor = Colors.redAccent;
        break;
      case 'completed':
        statusText = '已完成';
        statusColor = Colors.blue;
        break;
      case 'expired':
        statusText = '已过期';
        statusColor = Colors.purple;
        break;
      default:
        statusText = '未知状态';
        statusColor = Colors.black54;
    }
    return Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的订单'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('您还没有订单'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    // 使用 RoomListItemWidget 来展示房源信息，并在其下方添加订单特定信息
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RoomListItemWidget(data: order.room), // 复用房源列表项组件
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('房东: ${order.publisherUsername}'),
                                _buildOrderStatus(order.status),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            if (order.appointmentTime != null)
                              Text('预约时间: ${order.appointmentTime!.toLocal().toString().substring(0, 16)}'),
                            Text('下单时间: ${order.createdAt.toLocal().toString().substring(0, 16)}'),
                            // TODO: 可以添加取消订单等操作按钮
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}