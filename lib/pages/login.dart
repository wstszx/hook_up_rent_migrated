import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rent_share/pages/utils/common_toast.dart';
import 'package:rent_share/pages/utils/store.dart';
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
    const url = '/api/auth/login'; // 指向您本地的后端登录接口
    var params = {
      "username": username,
      "password": password,
    };

    try {
      // Updated to use named 'data' parameter for DioHttp.post
      var response = await DioHttp.of(context).post(url, data: params);

      // Dio通常会自动解析JSON，所以response.data应该是Map<String, dynamic>?
      if (response.data != null && response.data is Map<String, dynamic>) {
        Map<String, dynamic> resMap = response.data as Map<String, dynamic>; // Type cast after check

        // 检查后端返回的 token 和 message
        if (response.statusCode == 200 && resMap.containsKey('token')) {
          String token = resMap['token'];
          String message = resMap['message'] ?? '登录成功';
          CommonToast.showToast(message);

          Store store = await Store.getInstance();
          await store.setString(StoreKeys.token, token);

          // 假设 AuthModel 的 login 方法只需要 token
          ScopedModelHelper.getModel<AuthModel>(context).login(token, context);

          //一秒之后导航到主页并移除所有之前的路由
          Timer(const Duration(seconds: 1), () {
            if (mounted) { // 检查widget是否还在树中
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            }
          });
        } else {
          // 处理登录失败的情况，例如密码错误
          String errorMessage = resMap['message'] ?? '登录失败，请检查用户名和密码';
          CommonToast.showToast(errorMessage);
        }
      } else {
        CommonToast.showToast('登录失败：响应格式不正确');
      }
    } catch (e) {
      // 处理DioException或其他网络错误
      CommonToast.showToast('登录请求失败，请稍后再试');
      print('Login Error: $e');
      // 可以在这里添加更详细的错误处理，例如根据 DioException 的类型
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

