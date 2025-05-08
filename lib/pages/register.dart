import 'dart:convert';

import 'package:flutter/material.dart';

import 'utils/common_toast.dart';
import 'utils/dio_http.dart';
// import 'package:hook_up_rent/pages/utils/common_toast.dart';
// import 'package:hook_up_rent/pages/utils/dio_http.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  var repeatPasswordController = TextEditingController();

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  _registerHandler() async {
    var username = usernameController.text;
    var password = passwordController.text;
    var repeatPassword = repeatPasswordController.text;

    if (username.isEmpty) {
      _showToast('用户名不能为空');
      return;
    }
    if (password.isEmpty) {
      _showToast('密码不能为空');
      return;
    }
    if (repeatPassword.isEmpty) {
      _showToast('请确认密码');
      return;
    }
    if (password != repeatPassword) {
      _showToast('两次输入的密码不一致');
      return;
    }

    // String url = 'https://example.com/api/register'; // 替换为你的注册接口地址
    String url = 'https://reqres.in/api/register';
    var params = {
      'username': username,
      'password': password,

    };
    var response =
        await DioHttp.of(context).post(url, params); // 使用 DioHttp 发送 POST 请求
    var resString = json.decode(response.toString());

    int status = resString['staus'];
    String description = resString['description'] ?? "内部错误";
    CommonToast.showToast(description);
    if (status.toString().startsWith("2")) {
      // 注册成功
      _showToast('注册成功');
      Navigator.of(context).pushReplacementNamed('login');
    } else if (status == 400) {
      // 用户名已存在
      _showToast('用户名已存在');
    } else if (status == 500) {
      // 服务器错误
      _showToast('服务器错误，请稍后再试');
    } else {
      // 其他错误
      _showToast('注册失败，请稍后再试');
    }
    // if (response.statusCode == 200) {
    //   if (response.data['code'] == 200) {
    //     _showToast('注册成功');
    //     Navigator.pushReplacementNamed(context, 'login');
    //   } else {
    //     _showToast(response.data['message']);
    //   }
    // } else {
    //   _showToast('网络异常，请稍后再试');
    // }
    // 模拟注册成功的情况
    await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求延迟
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: SafeArea(
        minimum: const EdgeInsets.all(30),
        child: ListView(children: [
          TextField(
            controller: usernameController,
            decoration: InputDecoration(labelText: '用户名', hintText: '请输入用户名'),
          ),
          const Padding(padding: EdgeInsets.all(10)),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: '密码',
              hintText: '请输入密码',
            ),
          ),
          const Padding(padding: EdgeInsets.all(10)),
          TextField(
            controller: repeatPasswordController,
            decoration: const InputDecoration(
              labelText: '确认密码',
              hintText: '请输入密码',
            ),
          ),
          const Padding(padding: EdgeInsets.all(20)),
          ElevatedButton(
              onPressed: () {
                _registerHandler();
              },
              child: const Text('注册')),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('已有账号，'),
              TextButton(
                  onPressed: () {
                    // Navigator.pushNamed(context, 'login');
                    Navigator.pushReplacementNamed(context, 'login');
                  },
                  child: const Text('去登录~'))
            ],
          ),
        ]),
      ),
    );
  }
}
