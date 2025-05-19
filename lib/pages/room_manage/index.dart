import 'package:flutter/material.dart';
import 'package:rent_share/models/room.dart';
import 'package:rent_share/services/room_service.dart';
import 'package:rent_share/widgets/common_floating_button.dart';
import 'package:rent_share/widgets/room_list_item_widget.dart';

class RoomManagePage extends StatefulWidget {
  const RoomManagePage({Key? key}) : super(key: key);

  @override
  State<RoomManagePage> createState() => _RoomManagePageState();
}

class _RoomManagePageState extends State<RoomManagePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Room> _rentedRooms = [];
  List<Room> _availableRooms = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _dataLoaded = false; // 添加标志避免重复加载数据

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 监听标签切换，可以在切换时重新加载数据
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // 可以在这里根据需要重新加载数据
      }
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在 didChangeDependencies 中加载数据，这样可以安全地访问 InheritedWidget
    if (!_dataLoaded) {
      _fetchRooms();
      _dataLoaded = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 获取房源数据
  Future<void> _fetchRooms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 传递 context 参数给 getUserRooms 方法
      final allRooms = await RoomService.getUserRooms(context: context);
      
      // 分类处理
      setState(() {
        _rentedRooms = allRooms.where((room) => room.status == 'rented').toList();
        _availableRooms = allRooms.where((room) => room.status == 'available').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载房源数据失败: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // 更新房源状态
  Future<void> _updateRoomStatus(Room room, String newStatus) async {
    try {
      final success = await RoomService.updateRoomStatus(room.id, newStatus, context: context);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('房源状态更新成功')),
        );
        _fetchRooms(); // 重新加载数据
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新失败: ${e.toString()}')),
      );
    }
  }

  // 删除房源
  Future<void> _deleteRoom(Room room) async {
    // 显示确认对话框
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除房源「${room.title}」吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final success = await RoomService.deleteRoom(room.id, context: context);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('房源删除成功')),
        );
        _fetchRooms(); // 重新加载数据
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: ${e.toString()}')),
      );
    }
  }

  // 构建房源列表
  Widget _buildRoomList(List<Room> rooms) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchRooms,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('暂无房源数据'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/room-add'),
              child: const Text('去发布房源'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRooms,
      child: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return RoomListItemWidget(
            room: room,
            onTap: () {
              // 跳转到房源详情页
              Navigator.pushNamed(context, 'room_detail/${room.id}');
            },
            onEdit: () {
              // 跳转到编辑页面
              Navigator.pushNamed(context, 'room_edit/${room.id}').then((_) {
                _fetchRooms(); // 编辑完成后刷新数据
              });
            },
            onDelete: () => _deleteRoom(room),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CommonFloatingActionButton(
        '发布房源',
        () => Navigator.pushNamed(context, '/room-add').then((_) {
          _fetchRooms(); // 发布完成后刷新数据
        }),
      ),
      appBar: AppBar(
        title: const Text('房屋管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '已租'),
            Tab(text: '空置'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRooms,
            tooltip: '刷新',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRoomList(_rentedRooms),
          _buildRoomList(_availableRooms),
        ],
      ),
    );
  }
}

