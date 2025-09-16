import 'package:json_annotation/json_annotation.dart';

part 'client_user.g.dart';

@JsonSerializable()
class ClientUser {
  final String firstname;
  final String lastname;
  final String id;
  final String? username;
  final String? password;
  final String? authorities;
  final bool? enabled;
  final bool? accountNonLocked;
  final bool? accountNonExpired;
  final bool? credentialsNonExpired;
  ClientUser({
    required this.firstname,
    required this.lastname,
    required this.id,
    this.username,
    this.password,
    this.authorities,
    this.enabled,
    this.accountNonLocked,
    this.accountNonExpired,
    this.credentialsNonExpired,
  });

  factory ClientUser.fromJson(Map<String, dynamic> json) =>
      _$ClientUserFromJson(json);

  Map<String, dynamic> toJson() => _$ClientUserToJson(this);


}
