import 'package:json_annotation/json_annotation.dart';
part 'general_type.g.dart';

@JsonSerializable()
class GeneralType {
  @JsonKey(name: 'label')
  final String name;
  @JsonKey(name: 'value')
  final String id;

  GeneralType(this.name, this.id);
  factory GeneralType.fromJson(Map<String, dynamic> json) =>
      _$GeneralTypeFromJson(json);

  Map<String, dynamic> toJson() => _$GeneralTypeToJson(this);

  // Map<String, dynamic> toJson() {
  //   return {
  //     'name': name,
  //     'id': id,
  //   };
  // }
  //
  // factory GeneralType.fromJson(Map<String, dynamic> json) {
  //   return GeneralType(
  //     json['name'] as String,
  //     json['id'] as String,
  //   );
  // }
}
