import 'package:flutter/material.dart';
import 'package:rent_share/pages/home/tab_profile/function_button_data.dart';
import 'package:rent_share/widgets/common_image.dart';

class FunctionButtonWidget extends StatelessWidget {
  final FunctionButtonItem data;

  const FunctionButtonWidget(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (data.onTapHandle != null) {
          data.onTapHandle!(context);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 30),
        width: MediaQuery.of(context).size.width * 0.33,
        child: Column(
          children: [
            CommonImage(data.imageUrl),
            Text(data.title),
          ],
        ),
      ),
    );
  }
}

