import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/utils/common_toast.dart';
import 'package:hook_up_rent/pages/utils/store.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_model/auth.dart';
import 'utils/dio_http.dart';
import 'utils/scoped_model_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showPassword = false;

  var usernameController = TextEditingController();
  var passwordController = TextEditingController();

// 登录处理函数
  _loginHandle() async {
    var username = usernameController.text;
    var password = passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      CommonToast.showToast("用户名或密码不能为空！");
      return;
    }
    // 登录地址
    // const url = '/user/login';
    const url = 'https://reqres.in/api/login';
    var params = {
      "username": username,
      "password": password,
    };

    var response = await DioHttp.of(context).post(url, params);
    var resMap = json.decode(response.toString());

    int status = resMap['status'];
    String description = resMap['description'] ?? '内部错误';
    CommonToast.showToast(description);

    if (status.toString().startsWith('2')) {
      String token = resMap['body']['token'];

      Store store = await Store.getInstance();
      await store.setString(StoreKeys.token, token);

      ScopedModelHelper.getModel<AuthModel>(context).login(token, context);

      //一秒之后回到上一个页面
      Timer(Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: SafeArea(
        minimum: const EdgeInsets.all(30),
        child: ListView(children: [
          TextField(
            controller: usernameController,
            decoration:
                const InputDecoration(labelText: '用户名', hintText: '请输入用户名'),
          ),
          const Padding(padding: EdgeInsets.all(10)),
          TextField(
            controller: passwordController,
            obscureText: !_showPassword,
            decoration: InputDecoration(
                labelText: '密码',
                hintText: '请输入密码',
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                    icon: Icon(_showPassword
                        ? Icons.visibility_off
                        : Icons.visibility))),
          ),
          const Padding(padding: EdgeInsets.all(20)),
          ElevatedButton(
              onPressed: () {
                // Todo(),
                _loginHandle();
              },
              child: const Text('登录')),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('还没有账号，'),
              TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, 'register');
                  },
                  child: const Text('去注册~'))
            ],
          ),
        ]),
      ),
    );
  }
}
