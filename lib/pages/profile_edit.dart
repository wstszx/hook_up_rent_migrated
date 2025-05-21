import 'package:flutter/material.dart';
import 'package:rent_share/pages/utils/common_toast.dart';
import 'package:rent_share/scoped_model/auth.dart';
import 'package:rent_share/pages/utils/scoped_model_helper.dart';
import 'package:rent_share/pages/utils/dio_http.dart';
import 'package:rent_share/models/user_info.dart';
import 'package:dio/dio.dart'; // Add this import for Options class

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({Key? key}) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // New password
  final TextEditingController _confirmPasswordController = TextEditingController();

  UserInfo? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }
  Future<void> _loadUserInfo() async {
    var userInfo = ScopedModelHelper.getModel<AuthModel>(context).userInfo;
    setState(() {
      _userInfo = userInfo;
      if (_userInfo != null) {
        _usernameController.text = _userInfo!.nickname ?? ''; // Nickname maps to username
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String newUsername = _usernameController.text;
      String currentPassword = _currentPasswordController.text;
      String newPassword = _passwordController.text;

      var auth = ScopedModelHelper.getModel<AuthModel>(context);      Map<String, dynamic> updateData = {
        'username': newUsername, // Send as username to match server expectation
        'nickname': newUsername, // Also send as nickname to update both fields
      };

      if (newPassword.isNotEmpty) {
        if (currentPassword.isEmpty) {
          CommonToast.showToast('请输入当前密码以设置新密码');
          return;
        }
        updateData['password'] = newPassword;
        updateData['currentPassword'] = currentPassword;
      }

      try {        print('[ProfileEdit] Sending update request: $updateData');
        var response = await DioHttp.of(context).put(
          '/api/auth/me',
          data: updateData,
          token: auth.token,
        );

        print('[ProfileEdit] Server response: ${response.data}');
        
        if (response.statusCode == 200 && response.data != null) {
          Map<String, dynamic> resData = response.data;
          if (resData.containsKey('user') || resData.containsKey('message')) {
            CommonToast.showToast(resData['message'] ?? '个人资料更新成功');
            await auth.refreshUserInfo(context);
            if (mounted) {
              Navigator.pop(context);
            }
          } else {
            String message = resData['message'] ?? '个人资料更新失败';
            CommonToast.showToast(message);
          }
        } else {
          CommonToast.showToast('个人资料更新失败: 服务器响应异常');
        }
      } catch (e) {
        print('[ProfileEdit] Error updating profile: $e');
        String errorMessage = '个人资料更新失败，请稍后重试';
        if (e is DioException && e.response != null && e.response!.data != null && e.response!.data['message'] != null) {
           errorMessage = e.response!.data['message'];
        } else if (e is DioException) {
           errorMessage = '个人资料更新失败: ${e.message}';
        }
        CommonToast.showToast(errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑个人资料'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: '用户名'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入用户名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _currentPasswordController,
                decoration: const InputDecoration(labelText: '当前密码 (修改密码时必填)'),
                obscureText: true,
                validator: (value) {
                  // Only validate if new password is also entered
                  if (_passwordController.text.isNotEmpty && (value == null || value.isEmpty)) {
                    return '请输入当前密码以修改新密码';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: '新密码 (留空则不修改)'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: '确认新密码'),
                obscureText: true,
                validator: (value) {
                  if (_passwordController.text.isNotEmpty && value != _passwordController.text) {
                    return '两次输入的密码不一致';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
