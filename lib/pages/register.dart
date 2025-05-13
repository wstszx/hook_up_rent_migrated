import 'dart:convert';
import 'package:dio/dio.dart'; // Import DioException

import 'package:flutter/material.dart';

import 'utils/common_toast.dart';
import 'utils/dio_http.dart';
import '../../config.dart'; // Import Config
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

    String path = '/api/auth/register'; // Path relative to Config.BaseUrl
    var params = {
      'username': username,
      'password': password,
    };
    try {
      // Updated to use named 'data' parameter for DioHttp.post
      var response =
          await DioHttp.of(context).post(path, data: params);

      // Assuming response.data is already a Map<String, dynamic> if the server returns JSON
      // And Dio is configured to parse JSON responses automatically.
      Map<String, dynamic>? resData = response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : null;

      if (resData != null) {
        // Check if the backend returns a 'status' and 'description' or similar fields.
        // The actual field names might differ based on your backend implementation.
        // For now, let's assume the backend directly returns a meaningful status code
        // in response.statusCode and a message in response.data or a specific field.

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Successful registration based on HTTP status code
          _showToast(resData['message'] ?? '注册成功'); // Prefer message from backend if available
          Navigator.of(context).pushReplacementNamed('login');
        } else {
          // Handle other status codes based on your backend's error response structure
          String errorMessage = resData['message'] ?? resData['error'] ?? '注册失败，请稍后再试';
          _showToast(errorMessage);
        }
      } else {
        // Response data is not in the expected format or is null
         _showToast('注册失败：响应格式不正确');
      }
    } catch (e) {
      print('Registration Error Details: $e'); // Print the full error object
      if (e is DioException) { // Check if it's a DioException for more details
        print('DioException Response: ${e.response}');
        print('DioException Type: ${e.type}');
        print('DioException Message: ${e.message}');
        // e.error might be the underlying error (e.g., SocketException)
        print('DioException Underlying Error: ${e.error}');
      }
      _showToast('注册请求失败，详情请查看控制台'); // Update toast message
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
