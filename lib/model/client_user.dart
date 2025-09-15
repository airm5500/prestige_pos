import 'package:json_annotation/json_annotation.dart';

part 'client_user.g.dart';

@JsonSerializable()
class ClientUser {
  final String firstname;
  final String lastname;
  final String id;
  final String username;
  final String password;

  ClientUser({
    required this.firstname,
    required this.lastname,
    required this.id,
    required this.username,
    required this.password,
  });
  factory ClientUser.fromJson(Map<String, dynamic> json) =>
      _$ClientUserFromJson(json);
  Map<String, dynamic> toJson() => _$ClientUserToJson(this);
}
