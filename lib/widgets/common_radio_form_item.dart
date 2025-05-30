import 'package:flutter/material.dart';
import 'package:rent_share/widgets/common_form_item.dart';

class CommonRadioFormItem extends StatelessWidget {
  final String? label;
  final List<String>? options;
  final int? value;
  final ValueChanged<int?>? onChange;

  const CommonRadioFormItem(
      {super.key, this.label, this.options, this.value, this.onChange});

  @override
  Widget build(BuildContext context) {
    return CommonFormItem(
      label: label,
      contentBuilder: (context) {
        return Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              options!.length,
              (index) => Row(
                children: [
                  Radio(
                    value: index,
                    groupValue: value,
                    onChanged: onChange,
                  ),
                  Text(options![index]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

