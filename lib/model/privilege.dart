import 'package:json_annotation/json_annotation.dart';

part 'privilege.g.dart';

@JsonSerializable()
class Privilege {
  final String name;
  final bool value;

  Privilege({required this.name, required this.value});

  factory Privilege.fromJson(Map<String, dynamic> json) =>
      _$PrivilegeFromJson(json);

  Map<String, dynamic> toJson() => _$PrivilegeToJson(this);
}
