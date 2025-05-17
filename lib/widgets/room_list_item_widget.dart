import 'package:flutter/material.dart';
import '../models/room.dart';
import '../config.dart';

class RoomListItemWidget extends StatelessWidget {
  final Room room;
  final Function? onTap;
  final Function? onEdit;
  final Function? onDelete;

  const RoomListItemWidget({
    Key? key,
    required this.room,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String mainImage = room.images.isNotEmpty 
        ? room.images[0].startsWith('http') ? room.images[0] : '${Config.BaseUrl}${room.images[0]}' 
        : 'https://via.placeholder.com/300x200?text=No+Image';

    return GestureDetector(
      onTap: () {
        if (onTap != null) onTap!();
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1.0, color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            // 图片
            ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Image.network(
                mainImage,
                width: 120.0,
                height: 90.0,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120.0,
                    height: 90.0,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Text('暂无图片'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10.0),
            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    '${room.city} ${room.district} | ${room.roomType} | ${room.rentType}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '¥${room.price}/月',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildStatusTag(room.status),
                    ],
                  ),
                ],
              ),
            ),
            // 操作按钮
            Column(
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => onEdit!(),
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onDelete!(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color color;
    String text;

    switch (status) {
      case 'available':
        color = Colors.green;
        text = '空置中';
        break;
      case 'rented':
        color = Colors.orange;
        text = '已出租';
        break;
      case 'pending':
        color = Colors.blue;
        text = '待处理';
        break;
      case 'unavailable':
        color = Colors.grey;
        text = '已下架';
        break;
      default:
        color = Colors.grey;
        text = '未知';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12.0,
        ),
      ),
    );
  }
}
