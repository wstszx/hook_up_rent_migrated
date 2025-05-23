import 'package:json_annotation/json_annotation.dart';
part 'user_info.g.dart';
//用户信息bean

@JsonSerializable()
class UserInfo {
  final String? avatar; // 改为可空
  final String? gender; // 改为可空
  final String? nickname; // 改为可空
  final String username;
  final String? phone; // 改为可空
  final String id; // 将 id 类型改为 String

  UserInfo(this.avatar, this.gender, this.nickname, this.username, this.phone, this.id); // 更新构造函数

  // factory UserInfo.formJson(Map<String, dynamic> json) => UserInfo(
  //     json['avatar'] as String,
  //     json['gender'] as String,
  //     json['nickname'] as String,
  //     json['phone'] as String,
  //     json['id'] as int);
  factory UserInfo.formJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);

  Map<String, dynamic> json() => _$UserInfoToJson(this);
}
