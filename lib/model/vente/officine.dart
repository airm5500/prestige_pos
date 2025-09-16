import 'package:json_annotation/json_annotation.dart';

part 'officine.g.dart';

@JsonSerializable()
class Officine {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final String? email;
  final String? note;

  Officine({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.email,
    this.note,
  });

  factory Officine.fromJson(Map<String, dynamic> json) =>
      _$OfficineFromJson(json);

  Map<String, dynamic> toJson() => _$OfficineToJson(this);

  factory Officine.mock() {
    return Officine(
      id: '1',
      name: 'Pharmacie Centrale',
      address: '123 Rue de la Santé, Paris',
      phone: '+33 1 23 45 67 89',
      email: 'bkkk@gamil.com',
      note: 'Merci de votre confiance',
    );
  }
}
