import 'package:json_annotation/json_annotation.dart';
part 'user_info.g.dart';
//用户信息bean

@JsonSerializable()
class UserInfo {
  final String avatar;
  final String gender;
  final String nickname;
  final String phone;
  final int id;

  UserInfo(this.avatar, this.gender, this.nickname, this.phone, this.id);

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
