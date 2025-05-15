import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/utils/common_picker/index.dart';
import 'package:hook_up_rent/widgets/common_form_item.dart';

class CommonSelectFormItem extends StatelessWidget {
  final String label;
  final List<String>? options;
  final int? value;
  final ValueChanged<int?>? onChange;

  const CommonSelectFormItem(
      {super.key,
      required this.label,
      this.options,
      this.value,
      this.onChange});

  @override
  Widget build(BuildContext context) {
    return CommonFormItem(
      label: label,
      contentBuilder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            var result = CommonPicker.showPicker(
              context: context,
              options: options,
              value: value,
            );
            result?.then((selectedValue) => {
                  if (value != selectedValue &&
                      selectedValue != null &&
                      onChange != null)
                    onChange!(selectedValue)
                });
          },
          child: SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  () {
                    final currentOptions = options;
                    if (currentOptions != null) {
                      final currentValue = value;
                      if (currentValue != null) {
                        if (currentValue >= 0 && currentValue < currentOptions.length) {
                          return currentOptions[currentValue];
                        }
                      }
                    }
                    return '';
                  }(),
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.keyboard_arrow_right)
              ],
            ),
          ),
        );
      },
    );
  }

String _getDisplayText(List<String>? options, int? value) {
  if (options == null || value == null) {
    return ''; // Return empty string if options or value is null
  }
  // Now Dart knows options is List<String> and value is int
  if (value >= 0 && value < options.length) {
    return options[value]; // Safely access the element
  } else {
    return ''; // Return empty string if index is out of bounds
  }
}
}
