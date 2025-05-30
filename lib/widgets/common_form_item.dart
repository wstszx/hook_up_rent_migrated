import 'package:flutter/material.dart';

class CommonFormItem extends StatelessWidget {
  final String? label;
  final Widget Function(BuildContext context)? contentBuilder;
  final Widget? suffix;
  final String? suffixText;
  final String? hintText;
  final ValueChanged? onChanged;
  final TextEditingController? controller;
  final TextInputType? keyboardType; // Added keyboardType

  const CommonFormItem(
      {super.key,
      this.label,
      this.contentBuilder,
      this.suffix,
      this.suffixText,
      this.hintText,
      this.onChanged,
      this.controller,
      this.keyboardType}); // Added keyboardType

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: contentBuilder != null
                ? contentBuilder!(context)
                : TextField(
                    controller: controller,
                    keyboardType: keyboardType, // Used keyboardType
                    decoration: InputDecoration(
                      hintText: hintText ?? '',
                      border: InputBorder.none,
                    ),
                  ),
          ),
          if (suffix != null) suffix!,
          if (suffix == null && suffixText != null) Text(suffixText!),
        ],
      ),
    );
  }
}
