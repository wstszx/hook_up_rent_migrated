import 'package:flutter/material.dart';

class Item extends StatelessWidget {
  final String? title;
  final bool? isActive;
  final Function(BuildContext)? onTap;

  const Item({super.key, this.title, this.isActive, this.onTap});

  @override
  Widget build(BuildContext context) {
    var color = (isActive ?? false) ? Colors.green : Colors.black87;

    return GestureDetector(
      onTap: () {
        if (onTap != null) onTap!(context);
      },
      child: Row(
        children: [
          Text(title!, style: TextStyle(color: color)),
          Icon(Icons.arrow_drop_down, size: 20, color: color)
        ],
      ),
    );
  }
}
