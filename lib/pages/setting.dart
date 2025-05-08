import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/utils/common_toast.dart';

import '../scoped_model/auth.dart';
import 'utils/scoped_model_helper.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          ElevatedButton(
            // style: ElevatedButton.styleFrom(primary: Colors.red),
            onPressed: () {
              //退出登录
              ScopedModelHelper.getModel<AuthModel>(context).logout();
              CommonToast.showToast('已经退出登录。');
            },
            child: const Text('退出登录'),
          )
        ],
      ),
    );
  }
}
